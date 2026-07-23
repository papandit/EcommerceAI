const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/** Settings — singleton (Firestore "Settings/GLOBAL_SETTINGS"). */
const settingsSchema = new mongoose.Schema(
  {
    appName: { type: String, default: '' },
    appLogo: { type: String, default: '' },
    razorpaykey: { type: String, default: '' },
    razorpaysecret: { type: String, default: '' },
    stripepublishable: { type: String, default: '' },
    stripesecret: { type: String, default: '' },
    stripewebhooksecret: { type: String, default: '' },
    smtphost: { type: String, default: '' },
    smtpport: { type: String, default: '' },
    smtpuser: { type: String, default: '' },
    smtppass: { type: String, default: '' },
    smtpfrom: { type: String, default: '' },
    shiprocket: { type: String, default: '' },
    taxRate: { type: Number, default: 0 },
    shippingCost: { type: Number, default: 0 },
    freeShippingThreshold: { type: Number, default: 0 },
    // BrandShoot AI imagery (try-on + photoshoot/catalog). The key spends real
    // credits = real money, so it lives server-side only and is redacted from
    // the client-facing GET /settings (see settings.controller.js).
    brandshootBase: { type: String, default: 'https://brandshoot.onewebmart.cloud' },
    brandshootKey: { type: String, default: '' },
    tryonDailyLimit: { type: Number, default: 5 }, // legacy — no longer enforced (credits gate try-on)
    tryonMaxUploadBytes: { type: Number, default: 6000000 },
    // Try-on credit pool + costing. The admin buys credits from BrandShoot and
    // records the running total here; `costPerCredit` (in `currency`) lets the
    // costing dashboard estimate spend. `signupFreeCredits` is granted to each
    // new user on signup. Consumption is tracked in the CreditLedger.
    purchasedCredits: { type: Number, default: 0 },
    costPerCredit: { type: Number, default: 0 },
    currency: { type: String, default: 'INR' },
    signupFreeCredits: { type: Number, default: 10 },
    // --- Live BrandShoot key status (auto-synced, never hand-edited) ---
    // BrandShoot publishes no balance endpoint, so we learn about the key from
    // the calls we already make: if any response ever carries a remaining-credit
    // figure we store it here, and a 402 tells us the key is exhausted.
    brandshootReportedCredits: { type: Number, default: null }, // null = never reported
    brandshootDepleted: { type: Boolean, default: false }, // last call said "out of credits"
    brandshootCheckedAt: { type: Date, default: null }, // last time we heard from BrandShoot
    // BrandShoot model ids the admin has published to the shopper try-on picker.
    // Empty = fall back to the default women-only filter (see aiTryon.controller).
    tryonEnabledModelIds: { type: [String], default: [] },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Settings', settingsSchema, 'settings');
