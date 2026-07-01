const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/**
 * Append-only audit log of every try-on credit event. This is the single source
 * of truth for the costing dashboard (how much of the purchased BrandShoot pool
 * has been consumed) and for a user's credit history.
 *
 * `amount` is SIGNED: positive = credits added (grant/refund/purchase),
 * negative = consumed (customer try-on, admin photoshoot/catalog pool draw).
 * `userId` is null for pool-level events (purchases, admin generations) that are
 * not tied to a specific shopper.
 */
const creditLedgerSchema = new mongoose.Schema(
  {
    type: {
      type: String,
      required: true,
      enum: [
        'signup_grant', // free credits when a user account is created
        'admin_grant', // admin added credits to a user
        'admin_set', // admin set a user's balance to an exact value
        'admin_deduct', // admin removed credits from a user
        'tryon_consume', // a customer try-on spent 1 credit
        'tryon_refund', // a failed try-on refunded 1 credit
        'pool_purchase', // admin recorded a purchase of pool credits
        'pool_consume', // admin photoshoot/catalog drew from the pool
      ],
    },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null, index: true },
    amount: { type: Number, required: true }, // signed
    balanceAfter: { type: Number, default: null }, // user balance after (null for pool events)
    feature: { type: String, default: '' }, // tryon | photoshoot | catalog | signup | admin | purchase
    jobId: { type: String, default: '', index: true }, // BrandShoot job id (traceability + idempotency)
    reason: { type: String, default: '' }, // free-text admin note
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null }, // admin who acted
  },
  baseSchemaOptions
);

creditLedgerSchema.index({ userId: 1, createdAt: -1 });
// Prevent double-counting a consume/refund for the same BrandShoot job.
creditLedgerSchema.index(
  { jobId: 1, type: 1 },
  { unique: true, partialFilterExpression: { jobId: { $gt: '' } } }
);

module.exports = mongoose.model('CreditLedger', creditLedgerSchema, 'creditledgers');
