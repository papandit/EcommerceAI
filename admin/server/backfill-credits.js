/*
 * Backfill try-on credits for EXISTING users (accounts created before the credit
 * system existed). New signups already get their free credits automatically.
 *
 *   node backfill-credits.js              # dry run — reports who would be granted
 *   node backfill-credits.js --yes        # apply, granting Settings.signupFreeCredits
 *   node backfill-credits.js --yes --amount 5   # apply, granting 5 to each
 *
 * Idempotent: only users who have never been granted credits
 * (creditsGrantedTotal is 0 or unset) are touched.
 */
require('dotenv').config();
const connectDB = require('./src/config/db');
const User = require('./src/models/user.model');
const Settings = require('./src/models/settings.model');
const CreditLedger = require('./src/models/creditLedger.model');

(async () => {
  const args = process.argv.slice(2);
  const apply = args.includes('--yes');
  const amtIdx = args.indexOf('--amount');
  const amountOverride = amtIdx >= 0 ? Number(args[amtIdx + 1]) : null;

  await connectDB();

  const s = (await Settings.findOne().lean()) || {};
  const amount = Math.max(
    0,
    Math.round(Number.isFinite(amountOverride) ? amountOverride : Number(s.signupFreeCredits || 0))
  );
  if (!amount) {
    console.log('[backfill] amount resolves to 0 — set Settings.signupFreeCredits or pass --amount N. Nothing to do.');
    process.exit(0);
  }

  const filter = {
    $or: [{ creditsGrantedTotal: { $exists: false } }, { creditsGrantedTotal: { $lte: 0 } }],
  };
  const candidates = await User.find(filter).select('Email tryonCredits creditsGrantedTotal').lean();

  console.log(
    `[backfill] ${candidates.length} user(s) eligible; granting ${amount} credit(s) each. ${
      apply ? 'APPLYING.' : 'DRY RUN (pass --yes to apply).'
    }`
  );

  if (!apply) {
    candidates.slice(0, 20).forEach((u) => console.log(`  would grant → ${u.Email}`));
    if (candidates.length > 20) console.log(`  …and ${candidates.length - 20} more`);
    process.exit(0);
  }

  let granted = 0;
  for (const u of candidates) {
    // Atomic + re-checks the guard, so a concurrent signup can't double-grant.
    const updated = await User.findOneAndUpdate(
      { _id: u._id, $or: [{ creditsGrantedTotal: { $exists: false } }, { creditsGrantedTotal: { $lte: 0 } }] },
      { $inc: { tryonCredits: amount, creditsGrantedTotal: amount } },
      { new: true }
    );
    if (!updated) continue;
    await CreditLedger.create({
      type: 'signup_grant',
      userId: updated._id,
      amount,
      balanceAfter: updated.tryonCredits,
      feature: 'signup',
      reason: 'backfill',
    });
    granted += 1;
  }

  console.log(`[backfill] done — granted ${amount} credit(s) to ${granted} user(s).`);
  process.exit(0);
})().catch((e) => {
  console.error('[backfill] error:', e);
  process.exit(1);
});
