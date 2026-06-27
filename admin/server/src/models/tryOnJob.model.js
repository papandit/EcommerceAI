const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/**
 * One customer Try-On request. Tracks ownership (so only the owner can poll) and
 * powers the per-user daily rate limit. We deliberately DO NOT store the
 * shopper's uploaded photo — forward-and-forget; only the result URLs are kept.
 */
const tryOnJobSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', index: true },
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
    brandshootJobId: { type: String, index: true },
    status: { type: String, default: 'generating' }, // generating | done | error
    resultUrls: { type: [String], default: [] },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('TryOnJob', tryOnJobSchema, 'tryonjobs');
