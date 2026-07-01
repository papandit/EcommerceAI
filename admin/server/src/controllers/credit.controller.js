const Settings = require('../models/settings.model');
const CreditLedger = require('../models/creditLedger.model');
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
  const remaining = purchased - consumed;
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

module.exports = { costingSummary, userLedger, adjustUser, purchase };
