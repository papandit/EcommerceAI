const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/** Coupons — Firestore "Coupan" shape (kept spelling-compatible in the API). */
const couponSchema = new mongoose.Schema(
  {
    name: { type: String, default: '' },
    percentage: { type: mongoose.Schema.Types.Mixed, default: 0 },
    isActive: { type: Boolean, default: true },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Coupon', couponSchema, 'coupons');
