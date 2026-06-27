const bs = require('../services/brandshoot');
const Product = require('../models/product.model');
const AiJob = require('../models/aiJob.model');
const { processAndSave } = require('../middleware/upload');
const { ok, fail, asyncHandler } = require('../utils/response');

/** Admin SHOULD see the real reason (credits, quota, key) so they can act. */
function adminErr(e, res) {
  const messages = {
    503: 'BrandShoot is not configured — add the API key in Settings.',
    402: 'Out of BrandShoot credits — top up the account.',
    429:
      e.body && e.body.error === 'quota_exceeded'
        ? 'Monthly image quota reached.'
        : 'Rate limited — wait a moment.',
    401: 'BrandShoot key invalid/misconfigured — check Settings.',
  };
  return fail(res, messages[e.status] || e.message || 'BrandShoot error.', e.status || 500, {
    error: e.code || 'error',
  });
}

const productImage = async (productId) => {
  const product = await Product.findById(productId).lean();
  if (!product) {
    const e = new Error('product not found');
    e.status = 404;
    throw e;
  }
  return bs.urlToB64(product.Thumbnail || (product.Images || [])[0]);
};

// GET /api/admin/ai/categories — for the category dropdown
const categories = asyncHandler(async (_req, res) => {
  try {
    return ok(res, await bs.getCategories(), 'Categories');
  } catch (e) {
    return adminErr(e, res);
  }
});

// GET /api/admin/ai/models?sub_type=photoshoot — selectable preset model cards
const models = asyncHandler(async (req, res) => {
  try {
    const subType = (req.query.sub_type || 'photoshoot').toString();
    return ok(res, await bs.getModels(subType), 'Models');
  } catch (e) {
    return adminErr(e, res);
  }
});

// POST /api/admin/ai/photoshoot
// body: { productId?|productImage?(base64), modelId?|modelImage?(base64), categoryId }
// productImage is sent directly when creating a NEW product (no productId yet);
// otherwise the product image is looked up server-side by productId.
const photoshoot = asyncHandler(async (req, res) => {
  const {
    productId,
    productImage: productImageB64,
    modelId,
    modelImage,
    categoryId = 'Cloths',
  } = req.body || {};
  if (!productId && !productImageB64) {
    return fail(res, 'productId or productImage is required.', 400);
  }
  if (!modelId && !modelImage) return fail(res, 'modelId or modelImage is required.', 400);

  try {
    const img = productImageB64 ? productImageB64 : await productImage(productId);
    const job = await bs.startPhotoshoot({ productImage: img, modelId, modelImage, categoryId });
    const doc = await AiJob.create({
      ...(productId ? { productId } : {}),
      feature: 'photoshoot',
      brandshootJobId: job.jobId,
      totalImages: job.totalImages,
      createdBy: req.user.id,
    });
    return ok(
      res,
      { jobId: job.jobId, totalImages: job.totalImages, scenarios: job.scenarios, _id: doc._id },
      'Photoshoot started'
    );
  } catch (e) {
    return adminErr(e, res);
  }
});

// POST /api/admin/ai/catalog
// body: { productId, modelImages:[base64], modelLabels?, categoryId, backgroundColor?, backgroundLabel? }
const catalog = asyncHandler(async (req, res) => {
  const {
    productId,
    modelImages,
    modelLabels,
    categoryId = 'Cloths',
    backgroundColor,
    backgroundLabel,
  } = req.body || {};
  if (!productId || !Array.isArray(modelImages) || !modelImages.length) {
    return fail(res, 'productId and modelImages[] are required.', 400);
  }

  try {
    const img = await productImage(productId);
    const job = await bs.startCatalog({
      productImage: img,
      modelImages,
      modelLabels,
      categoryId,
      backgroundColor,
      backgroundLabel,
    });
    const doc = await AiJob.create({
      productId,
      feature: 'catalog',
      brandshootJobId: job.jobId,
      totalImages: job.totalImages,
      createdBy: req.user.id,
    });
    return ok(
      res,
      { jobId: job.jobId, totalImages: job.totalImages, scenarios: job.scenarios, _id: doc._id },
      'Catalog started'
    );
  } catch (e) {
    return adminErr(e, res);
  }
});

// GET /api/admin/ai/jobs/:jobId — poll; caches images into the AiJob when done.
const getJob = asyncHandler(async (req, res) => {
  try {
    const job = await bs.getJob(req.params.jobId);
    if (job.status === 'done') {
      await AiJob.updateOne(
        { brandshootJobId: req.params.jobId },
        {
          status: 'done',
          images: job.images.map((i, idx) => ({
            fullUrl: i.fullUrl,
            label: (job.scenarios && job.scenarios[idx] && job.scenarios[idx].label) || `Image ${idx + 1}`,
            scenarioId: job.scenarios && job.scenarios[idx] ? job.scenarios[idx].id : '',
          })),
        }
      );
    }
    return ok(res, job, 'Job status');
  } catch (e) {
    return adminErr(e, res);
  }
});

// POST /api/admin/ai/jobs/:jobId/save  body: { selectedUrls:[...] }
// Re-host the chosen BrandShoot images to our own /uploads, then publish them to
// the product gallery (these render on the storefront). Re-hosting protects us
// from BrandShoot URLs that may expire.
const save = asyncHandler(async (req, res) => {
  const { selectedUrls } = req.body || {};
  if (!Array.isArray(selectedUrls) || !selectedUrls.length) {
    return fail(res, 'selectedUrls[] is required.', 400);
  }

  const aiJob = await AiJob.findOne({ brandshootJobId: req.params.jobId });
  if (!aiJob) return fail(res, 'Job not found.', 404);

  const baseUrl = `${req.protocol}://${req.get('host')}`;
  const chosen = aiJob.images.filter((im) => selectedUrls.includes(im.fullUrl));

  const picks = [];
  for (const im of chosen) {
    try {
      const buffer = await bs.downloadToBuffer(im.fullUrl);
      const saved = await processAndSave(
        { buffer, originalname: `ai-${aiJob.feature}-${im.scenarioId || 'img'}.webp` },
        'ai',
        baseUrl
      );
      picks.push({
        fullUrl: saved.url, // our durable URL, not BrandShoot's
        label: im.label,
        source: aiJob.feature,
        scenarioId: im.scenarioId,
      });
    } catch (e) {
      console.error('[BrandShoot re-host failed]', im.fullUrl, e.message);
    }
  }

  if (!picks.length) {
    return fail(res, 'Could not save the selected images. Please try again.', 502);
  }

  await Product.updateOne({ _id: aiJob.productId }, { $push: { aiGallery: { $each: picks } } });
  return ok(res, { added: picks.length }, 'Published to product');
});

// POST /api/admin/ai/rehost  body: { selectedUrls:[...] }
// Re-host chosen BrandShoot images to our own /uploads and return the durable
// URLs. Used by the Create-Product flow, where there is no product to push to
// yet — the UI adds the returned URLs to the new product's images.
const rehost = asyncHandler(async (req, res) => {
  const { selectedUrls } = req.body || {};
  if (!Array.isArray(selectedUrls) || !selectedUrls.length) {
    return fail(res, 'selectedUrls[] is required.', 400);
  }
  const baseUrl = `${req.protocol}://${req.get('host')}`;
  const urls = [];
  for (const u of selectedUrls) {
    try {
      const buffer = await bs.downloadToBuffer(u);
      const saved = await processAndSave(
        { buffer, originalname: 'ai-photoshoot.webp' },
        'ai',
        baseUrl
      );
      urls.push(saved.url);
    } catch (e) {
      console.error('[BrandShoot re-host failed]', u, e.message);
    }
  }
  if (!urls.length) return fail(res, 'Could not save the selected images. Please try again.', 502);
  return ok(res, { urls }, 'Re-hosted');
});

module.exports = { categories, models, photoshoot, catalog, getJob, save, rehost };
