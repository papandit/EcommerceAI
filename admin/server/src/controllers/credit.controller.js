const Settings = require('../models/settings.model');
const CreditLedger = require('../models/creditLedger.model');
const CreditRequest = require('../models/creditRequest.model');
const User = require('../models/user.model');
const credits = require('../utils/credits');
const { ok, fail, asyncHandler } = require('../utils/response');

/**
 * Admin-only try-on credit management. Costing is tracked internally (BrandShoot
 * exposes no balance API): Purchased comes from Settings, Consumed is summed from
 * the ledger, Remaining = Purchased − Consumed.
 */

// GET /api/admin/credits/summary
const costingSummary = asyncHandler(async (_req, res) => {
  const s = (await Settings.findOne().lean()) || {};
  const purchased = Number(s.purchasedCredits || 0);
  const costPerCredit = Number(s.costPerCredit || 0);
  const currency = s.currency || 'INR';
  const consumed = await credits.getConsumedCredits();

  // If BrandShoot ever reports a live figure, trust it over the manually
  // entered total — that is the closest thing to a real sync available.
  const reported = s.brandshootReportedCredits;
  const hasReported = typeof reported === 'number' && Number.isFinite(reported);
  const remaining = hasReported ? reported : purchased - consumed;

  // User-side aggregates so the dashboard reflects real distribution, not just
  // the pool: how many credits are sitting in shopper balances right now, how
  // many were ever handed out, and the average per user.
  const agg = await User.aggregate([
    {
      $group: {
        _id: null,
        totalUsers: { $sum: 1 },
        allocated: { $sum: { $ifNull: ['$tryonCredits', 0] } },
        grantedTotal: { $sum: { $ifNull: ['$creditsGrantedTotal', 0] } },
        usedTotal: { $sum: { $ifNull: ['$creditsConsumedTotal', 0] } },
      },
    },
  ]);
  const a = agg[0] || { totalUsers: 0, allocated: 0, grantedTotal: 0, usedTotal: 0 };
  const avgPerUser = a.totalUsers ? a.allocated / a.totalUsers : 0;

  return ok(
    res,
    {
      purchased,
      consumed,
      remaining,
      costPerCredit,
      currency,
      estConsumedCost: consumed * costPerCredit,
      estRemainingValue: remaining * costPerCredit,
      // distribution
      totalUsers: a.totalUsers,
      allocated: a.allocated,
      grantedTotal: a.grantedTotal,
      usedTotal: a.usedTotal,
      avgPerUser,
      estAllocatedCost: a.allocated * costPerCredit,
      // live BrandShoot key status (auto-synced from real API calls)
      brandshootConfigured: !!s.brandshootKey,
      brandshootReportedCredits: hasReported ? reported : null,
      brandshootDepleted: !!s.brandshootDepleted,
      brandshootCheckedAt: s.brandshootCheckedAt || null,
      remainingIsLive: hasReported,
    },
    'Credit costing'
  );
});

// GET /api/admin/credits/users/:id/ledger — a user's credit history (newest first)
const userLedger = asyncHandler(async (req, res) => {
  const rows = await CreditLedger.find({ userId: req.params.id })
    .sort({ createdAt: -1 })
    .limit(200)
    .lean();
  return ok(res, rows, 'Credit history');
});

// POST /api/admin/credits/users/:id/adjust  body: { op: 'set'|'add'|'deduct', amount, reason }
const adjustUser = asyncHandler(async (req, res) => {
  const { op = 'add', amount, reason = '' } = req.body || {};
  const n = Number(amount);
  if (!Number.isFinite(n) || n < 0) {
    return fail(res, 'A non-negative amount is required.', 400);
  }
  if (!['set', 'add', 'deduct'].includes(op)) {
    return fail(res, "op must be 'set', 'add' or 'deduct'.", 400);
  }
  const result = await credits.adminAdjust({
    userId: req.params.id,
    op,
    amount: n,
    reason,
    createdBy: req.user.id,
  });
  if (!result) return fail(res, 'User not found.', 404);
  return ok(res, { tryonCredits: result.balanceAfter, entry: result.ledger }, 'Credits updated');
});

// POST /api/admin/credits/purchase  body: { amount, reason } — record a pool top-up
const purchase = asyncHandler(async (req, res) => {
  const n = Number((req.body || {}).amount);
  if (!Number.isFinite(n) || n <= 0) {
    return fail(res, 'A positive amount is required.', 400);
  }
  const purchasedCredits = await credits.recordPoolPurchase({
    amount: n,
    reason: (req.body || {}).reason || '',
    createdBy: req.user.id,
  });
  return ok(res, { purchasedCredits }, 'Purchase recorded');
});

// POST /api/admin/credits/pool  body: { purchasedCredits?, costPerCredit?, currency? }
// Set the pool to the credits the BrandShoot key actually carries (e.g. 10000)
// and the price per credit. Used by the Credit pool card on the Credits page.
const setPool = asyncHandler(async (req, res) => {
  const b = req.body || {};
  const update = {};
  if (b.purchasedCredits != null) {
    const n = Number(b.purchasedCredits);
    if (!Number.isFinite(n) || n < 0) {
      return fail(res, 'purchasedCredits must be 0 or more.', 400);
    }
    update.purchasedCredits = Math.round(n);
  }
  if (b.costPerCredit != null) {
    const c = Number(b.costPerCredit);
    if (!Number.isFinite(c) || c < 0) {
      return fail(res, 'costPerCredit must be 0 or more.', 400);
    }
    update.costPerCredit = c;
  }
  if (b.currency != null) update.currency = String(b.currency).trim() || 'INR';
  if (!Object.keys(update).length) return fail(res, 'Nothing to update.', 400);

  const doc = await Settings.findOneAndUpdate({}, { $set: update }, { new: true, upsert: true });
  return ok(
    res,
    {
      purchasedCredits: doc.purchasedCredits,
      costPerCredit: doc.costPerCredit,
      currency: doc.currency,
    },
    'Credit pool updated'
  );
});

// GET /api/admin/credits/users?search= — every user with their credit balance,
// for the admin "distribute credits" section.
const listUsers = asyncHandler(async (req, res) => {
  const search = String(req.query.search || '').trim();
  const filter = search
    ? {
        $or: [
          { Email: { $regex: search, $options: 'i' } },
          { FirstName: { $regex: search, $options: 'i' } },
          { LastName: { $regex: search, $options: 'i' } },
        ],
      }
    : {};
  const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 200, 1), 500);
  const rows = await User.find(filter)
    .select('FirstName LastName Email ProfilePicture Role tryonCredits creditsGrantedTotal creditsConsumedTotal')
    .sort({ createdAt: -1 })
    .limit(limit)
    .lean();
  return ok(res, rows, 'Users with credits');
});

// GET /api/admin/credits/requests?status=pending|approved|rejected|all
const listRequests = asyncHandler(async (req, res) => {
  const status = String(req.query.status || 'all');
  const filter = ['pending', 'approved', 'rejected'].includes(status) ? { status } : {};
  const items = await CreditRequest.find(filter).sort({ createdAt: -1 }).limit(200).lean();
  const pendingCount = await CreditRequest.countDocuments({ status: 'pending' });
  return ok(res, { items, pendingCount }, 'Credit requests');
});

// POST /api/admin/credits/requests/:id  body: { action:'approve'|'reject', amount?, note? }
const handleRequest = asyncHandler(async (req, res) => {
  const { action, amount, note = '' } = req.body || {};
  if (!['approve', 'reject'].includes(action)) {
    return fail(res, "action must be 'approve' or 'reject'.", 400);
  }
  const doc = await CreditRequest.findById(req.params.id);
  if (!doc) return fail(res, 'Request not found.', 404);
  if (doc.status !== 'pending') return fail(res, 'This request was already handled.', 409);

  let balanceAfter = null;
  if (action === 'approve') {
    const give = Math.max(1, Math.round(Number(amount) || doc.amount));
    const result = await credits.adminAdjust({
      userId: doc.userId,
      op: 'add',
      amount: give,
      reason: note || 'credit request approved',
      createdBy: req.user.id,
    });
    if (!result) return fail(res, 'User not found.', 404);
    balanceAfter = result.balanceAfter;
    doc.grantedAmount = give;
  }
  doc.status = action === 'approve' ? 'approved' : 'rejected';
  doc.adminNote = String(note || '').slice(0, 500);
  doc.handledBy = req.user.id;
  doc.handledAt = new Date();
  await doc.save();

  return ok(
    res,
    { request: doc, balanceAfter },
    action === 'approve' ? 'Credits granted' : 'Request rejected'
  );
});

// DELETE /api/admin/credits/requests/:id
const deleteRequest = asyncHandler(async (req, res) => {
  const doc = await CreditRequest.findByIdAndDelete(req.params.id);
  if (!doc) return fail(res, 'Request not found.', 404);
  return ok(res, { id: req.params.id }, 'Request deleted');
});

// POST /api/admin/credits/grant-all  body: { amount, onlyUngranted? }
// Bulk-distribute credits: to everyone, or only to users who never got any.
const grantAll = asyncHandler(async (req, res) => {
  const b = req.body || {};
  const n = Math.round(Number(b.amount) || 0);
  if (!(n > 0)) return fail(res, 'A positive amount is required.', 400);
  const fn = b.onlyUngranted ? credits.grantToAllUngranted : credits.grantToEveryone;
  const granted = await fn({
    amount: n,
    reason: b.reason || 'admin bulk distribution',
    createdBy: req.user.id,
  });
  return ok(res, { granted, amount: n }, `Granted ${n} credit(s) to ${granted} user(s)`);
});

module.exports = {
  costingSummary,
  userLedger,
  adjustUser,
  purchase,
  setPool,
  listUsers,
  listRequests,
  handleRequest,
  deleteRequest,
  grantAll,
};
