/**
 * Try-on credit helpers. All balance mutations live here so signup, the customer
 * try-on flow, the admin panel, and the backfill script share the exact same
 * atomic logic.
 *
 * The golden rule: a try-on credit is money. Deduction is a single conditional
 * `$inc` on the user document — never read-then-write — so concurrent try-on
 * requests can never double-spend the same credit.
 */
const User = require('../models/user.model');
const Settings = require('../models/settings.model');
const CreditLedger = require('../models/creditLedger.model');

/** Write a ledger row; swallow duplicate-key errors (idempotency on jobId+type). */
async function log(entry) {
  try {
    return await CreditLedger.create(entry);
  } catch (e) {
    if (e && e.code === 11000) return null; // already recorded for this jobId+type
    throw e;
  }
}

/**
 * Grant the configured free credits to a brand-new user. Idempotent: only grants
 * while `creditsGrantedTotal` is still 0, so re-login / retries never double-grant.
 * Returns the (possibly updated) user document.
 */
async function grantSignupCredits(user) {
  if (!user) return user;
  const s = await Settings.findOne().lean();
  const amount = Math.max(0, Math.round(Number((s && s.signupFreeCredits) || 0)));
  if (!amount) return user;

  const updated = await User.findOneAndUpdate(
    { _id: user._id, creditsGrantedTotal: 0 },
    { $inc: { tryonCredits: amount, creditsGrantedTotal: amount } },
    { new: true }
  );
  if (!updated) return user; // already granted
  await log({
    type: 'signup_grant',
    userId: updated._id,
    amount,
    balanceAfter: updated.tryonCredits,
    feature: 'signup',
  });
  return updated;
}

/**
 * Atomically deduct 1 credit. Returns the new balance, or null if the user had
 * no credits (or lost a concurrent race). The ledger row is written separately
 * once the BrandShoot job id is known (see logTryonConsume).
 */
async function deductOneCredit(userId) {
  const u = await User.findOneAndUpdate(
    { _id: userId, tryonCredits: { $gte: 1 } },
    { $inc: { tryonCredits: -1, creditsConsumedTotal: 1 } },
    { new: true }
  );
  return u ? u.tryonCredits : null;
}

/** Record a successful try-on consumption (call after the job started). */
function logTryonConsume({ userId, jobId = '', balanceAfter = null, feature = 'tryon' }) {
  return log({ type: 'tryon_consume', userId, amount: -1, balanceAfter, feature, jobId });
}

/** Reverse a deduction (job failed to start). Returns the new balance. */
async function refundOneCredit({ userId, jobId = '', feature = 'tryon', reason = '' }) {
  const u = await User.findOneAndUpdate(
    { _id: userId },
    { $inc: { tryonCredits: 1, creditsConsumedTotal: -1 } },
    { new: true }
  );
  if (!u) return null;
  await log({
    type: 'tryon_refund',
    userId,
    amount: 1,
    balanceAfter: u.tryonCredits,
    feature,
    reason,
    jobId,
  });
  return u.tryonCredits;
}

/** Record admin photoshoot/catalog draw against the shared pool (no user balance). */
async function recordPoolConsume({ amount, feature = '', jobId = '', createdBy = null }) {
  const n = Math.max(0, Math.round(Number(amount) || 0));
  if (!n) return null;
  return log({ type: 'pool_consume', userId: null, amount: -n, feature, jobId, createdBy });
}

/** Record a purchase of pool credits and bump Settings.purchasedCredits. */
async function recordPoolPurchase({ amount, reason = '', createdBy = null }) {
  const n = Math.max(0, Math.round(Number(amount) || 0));
  if (!n) return null;
  const s = await Settings.findOneAndUpdate(
    {},
    { $inc: { purchasedCredits: n } },
    { new: true, upsert: true }
  );
  await log({ type: 'pool_purchase', amount: n, feature: 'purchase', reason, createdBy });
  return s.purchasedCredits;
}

/**
 * Admin adjustment of a user's balance. `op` is 'set' | 'add' | 'deduct'.
 * Never drops a balance below 0. Returns { balanceAfter, ledger } or null if the
 * user is not found. Low-concurrency (single admin), so read-modify-write is fine.
 */
async function adminAdjust({ userId, op, amount, reason = '', createdBy = null }) {
  const n = Math.max(0, Math.round(Number(amount) || 0));
  const user = await User.findById(userId);
  if (!user) return null;
  const before = user.tryonCredits || 0;

  let type;
  let delta; // signed change actually applied
  if (op === 'set') {
    const target = n;
    delta = target - before;
    user.tryonCredits = target;
    if (delta > 0) user.creditsGrantedTotal = (user.creditsGrantedTotal || 0) + delta;
    type = 'admin_set';
  } else if (op === 'deduct') {
    const actual = Math.min(before, n); // clamp to 0
    delta = -actual;
    user.tryonCredits = before - actual;
    type = 'admin_deduct';
  } else {
    // default: add
    delta = n;
    user.tryonCredits = before + n;
    user.creditsGrantedTotal = (user.creditsGrantedTotal || 0) + n;
    type = 'admin_grant';
  }
  await user.save();

  const ledger = await log({
    type,
    userId: user._id,
    amount: delta,
    balanceAfter: user.tryonCredits,
    feature: 'admin',
    reason,
    createdBy,
  });
  return { balanceAfter: user.tryonCredits, ledger };
}

/** Net credits consumed (consume rows minus refunds) — for the costing dashboard. */
async function getConsumedCredits() {
  const rows = await CreditLedger.aggregate([
    { $match: { type: { $in: ['tryon_consume', 'tryon_refund', 'pool_consume'] } } },
    { $group: { _id: null, net: { $sum: '$amount' } } },
  ]);
  const net = rows.length ? rows[0].net : 0; // negative overall (more consumed than refunded)
  return Math.max(0, -net);
}

module.exports = {
  grantSignupCredits,
  deductOneCredit,
  logTryonConsume,
  refundOneCredit,
  recordPoolConsume,
  recordPoolPurchase,
  adminAdjust,
  getConsumedCredits,
};
