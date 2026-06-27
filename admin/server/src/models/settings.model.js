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
    tryonDailyLimit: { type: Number, default: 5 },
    tryonMaxUploadBytes: { type: Number, default: 6000000 },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Settings', settingsSchema, 'settings');
