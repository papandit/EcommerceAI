const bs = require('../services/brandshoot');
const Product = require('../models/product.model');
const TryOnJob = require('../models/tryOnJob.model');
const Settings = require('../models/settings.model');
const User = require('../models/user.model');
const CreditRequest = require('../models/creditRequest.model');
const credits = require('../utils/credits');
const { ok, created, fail, asyncHandler } = require('../utils/response');

/** Shopper-facing error mapping — never expose credit/key problems to shoppers. */
function bsMessage(status) {
  const map = {
    503: 'Try-on is temporarily unavailable.', // not configured
    402: 'Try-on is temporarily unavailable.', // out of credits — alert ops
    401: 'Try-on is temporarily unavailable.', // key misconfig — alert ops
    403: 'Try-on is temporarily unavailable.',
    429: "We're busy right now, please try again in a moment.",
  };
  return map[status] || 'Something went wrong, please try again.';
}

function handleBsError(e, res) {
  if ([402, 401, 403, 503].includes(e.status)) {
    console.error('[BrandShoot ALERT]', e.status, e.code || '', e.body || e.message);
  }
  return fail(res, bsMessage(e.status), e.status || 500, { error: e.code || 'error' });
}

// Curated model picker for shoppers: women/girl models only (Indian +
// International), excluding men/boys/babies.
// Match women/girls; the women pattern already excludes men/boys, so we only
// need to drop "Baby Girl" (note: /man/ would wrongly match "woman").
const WOMEN_RE = /woman|girl|female/i;
const EXCLUDE_RE = /baby/i;

// GET /api/ai/models — the models a shopper can try the product on.
// If the admin has curated a selection (Settings.tryonEnabledModelIds), only
// those are shown; otherwise we fall back to the default women-only filter.
const models = asyncHandler(async (_req, res) => {
  try {
    const all = await bs.getModels('photoshoot');
    const s = await Settings.findOne().select('tryonEnabledModelIds').lean();
    const picked = (s && s.tryonEnabledModelIds) || [];

    let list;
    if (picked.length) {
      const allow = new Set(picked.map(String));
      list = (all || []).filter((m) => allow.has(String(m.id)));
    } else {
      list = (all || []).filter(
        (m) => WOMEN_RE.test(m.name || '') && !EXCLUDE_RE.test(m.name || '')
      );
    }
    return ok(res, list, 'Models');
  } catch (e) {
    return handleBsError(e, res);
  }
});

// POST /api/ai/tryon
// body: { productId, userImage(base64) }  — shopper's own photo, OR
//       { productId, modelId }            — render the product on a preset model
const tryon = asyncHandler(async (req, res) => {
  const { productId, userImage, modelId } = req.body || {};
  if (!productId || (!userImage && !modelId)) {
    return fail(res, 'productId and (userImage or modelId) are required.', 400);
  }

  const settings = await Settings.findOne().lean();
  const maxBytes = Number(settings?.tryonMaxUploadBytes || 6000000);

  // base64 length is ~1.37x the byte size; guard generously at 1.4x.
  if (userImage && userImage.length > maxBytes * 1.4) {
    return fail(res, 'That photo is too large. Please use a smaller image.', 400);
  }

  const product = await Product.findById(productId).lean();
  if (!product || product.aiTryOnEnabled === false) {
    return fail(res, 'This product is not available for try-on.', 404);
  }

  // Prepare the product image + the "person" image BEFORE spending a credit, so
  // a prep failure never charges the shopper.
  let productImage;
  let personImage = userImage;
  try {
    // Look the product image up server-side — never trust the client for this.
    productImage = await bs.urlToB64(product.Thumbnail || (product.Images || [])[0]);

    // The "person" is either the shopper's uploaded photo or a preset model
    // (we fetch the chosen model's image server-side and use it as the photo).
    if (!personImage && modelId) {
      // Respect the admin's curated selection, if there is one.
      const picked = (settings && settings.tryonEnabledModelIds) || [];
      if (picked.length && !picked.map(String).includes(String(modelId))) {
        return fail(res, 'That model is not available. Please pick another.', 400);
      }
      const allModels = await bs.getModels('photoshoot');
      const chosen = (allModels || []).find((m) => String(m.id) === String(modelId));
      if (!chosen || !chosen.imageFullUrl) {
        return fail(res, 'That model is not available. Please pick another.', 400);
      }
      personImage = await bs.urlToB64(chosen.imageFullUrl);
    }
  } catch (e) {
    return handleBsError(e, res);
  }

  // Each try-on spends 1 credit (= money). Deduct atomically FIRST so a burst of
  // concurrent requests can never double-spend the same credit; refund below if
  // the job fails to start.
  const balanceAfter = await credits.deductOneCredit(req.user.id);
  if (balanceAfter === null) {
    return fail(res, "You're out of try-on credits.", 402, { error: 'out_of_credits' });
  }

  try {
    const job = await bs.startTryOn({ productImage, userImage: personImage, categoryId: 'Cloths' });

    await TryOnJob.create({
      userId: req.user.id,
      productId,
      brandshootJobId: job.jobId,
    });

    await credits.logTryonConsume({
      userId: req.user.id,
      jobId: job.jobId,
      balanceAfter,
      feature: 'tryon',
    });

    return ok(
      res,
      { jobId: job.jobId, totalImages: job.totalImages, credits: balanceAfter },
      'Try-on started'
    );
  } catch (e) {
    // The job never started — give the credit back before reporting the error.
    await credits.refundOneCredit({ userId: req.user.id, feature: 'tryon', reason: 'start_failed' });
    return handleBsError(e, res);
  }
});

// GET /api/ai/tryon/credits — the shopper's remaining credits + any open request.
const balance = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id).select('tryonCredits').lean();
  const pending = await CreditRequest.findOne({ userId: req.user.id, status: 'pending' })
    .select('amount createdAt')
    .lean();
  return ok(
    res,
    {
      credits: user ? user.tryonCredits || 0 : 0,
      pendingRequest: pending ? { amount: pending.amount, createdAt: pending.createdAt } : null,
    },
    'Credits'
  );
});

// POST /api/ai/tryon/credits/request  body: { amount?, message? }
// Shopper asks the admin for more credits; lands in the admin Credits inbox.
const requestCredits = asyncHandler(async (req, res) => {
  const b = req.body || {};
  const amount = Math.max(1, Math.min(100, Math.round(Number(b.amount) || 10)));
  const message = String(b.message || '').trim().slice(0, 500);

  const existing = await CreditRequest.findOne({ userId: req.user.id, status: 'pending' });
  if (existing) {
    return fail(res, "You already have a request pending — the admin will review it soon.", 409, {
      error: 'request_pending',
    });
  }

  const user = await User.findById(req.user.id).select('FirstName LastName Email').lean();
  const doc = await CreditRequest.create({
    userId: req.user.id,
    userName: user ? `${user.FirstName || ''} ${user.LastName || ''}`.trim() : '',
    userEmail: user ? user.Email : '',
    amount,
    message,
  });

  return created(
    res,
    { id: String(doc._id), status: doc.status, amount: doc.amount },
    'Your request has been sent to the admin.'
  );
});

// GET /api/ai/jobs/:jobId  — only the owner can poll their own job.
const getJob = asyncHandler(async (req, res) => {
  const local = await TryOnJob.findOne({
    brandshootJobId: req.params.jobId,
    userId: req.user.id,
  });
  if (!local) return fail(res, 'Job not found.', 404);

  try {
    const job = await bs.getJob(req.params.jobId);
    const images = job.images.map((i) => i.fullUrl);

    if (job.status === 'done') {
      local.status = 'done';
      local.resultUrls = images;
      await local.save();
    } else if (job.status === 'error') {
      local.status = 'error';
      await local.save();
    }

    return ok(res, { status: job.status, images }, 'Job status');
  } catch (e) {
    return handleBsError(e, res);
  }
});

// GET /api/ai/tryon/history — the signed-in shopper's completed try-on
// creations (with result image URLs to view/download), newest first.
const history = asyncHandler(async (req, res) => {
  const jobs = await TryOnJob.find({
    userId: req.user.id,
    status: 'done',
    resultUrls: { $exists: true, $ne: [] },
  })
    .sort({ createdAt: -1 })
    .limit(200)
    .lean();

  const productIds = [
    ...new Set(jobs.map((j) => String(j.productId)).filter(Boolean)),
  ];
  const products = await Product.find({ _id: { $in: productIds } })
    .select('Title Thumbnail Images')
    .lean();
  const pmap = {};
  products.forEach((p) => {
    pmap[String(p._id)] = p;
  });

  const items = jobs.map((j) => {
    const p = pmap[String(j.productId)] || {};
    return {
      jobId: j.brandshootJobId,
      productId: String(j.productId || ''),
      productName: p.Title || 'Product',
      productThumbnail: p.Thumbnail || (p.Images || [])[0] || '',
      images: j.resultUrls || [],
      createdAt: j.createdAt,
    };
  });

  return ok(res, { total: items.length, items }, 'Try-on history');
});

module.exports = { tryon, getJob, models, history, balance, requestCredits };
