const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/**
 * A shopper's request to the admin for more try-on credits. The admin sees these
 * in the panel's Credits inbox and can approve (which grants the credits) or
 * reject. One pending request per user at a time (enforced in the controller).
 */
const creditRequestSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    userName: { type: String, default: '' }, // denormalised for the admin list
    userEmail: { type: String, default: '' },
    amount: { type: Number, default: 10 }, // how many the shopper asked for
    message: { type: String, default: '' }, // shopper's note to the admin
    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected'],
      default: 'pending',
      index: true,
    },
    grantedAmount: { type: Number, default: 0 }, // what the admin actually gave
    adminNote: { type: String, default: '' },
    handledBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
    handledAt: { type: Date, default: null },
  },
  baseSchemaOptions
);

creditRequestSchema.index({ status: 1, createdAt: -1 });

module.exports = mongoose.model('CreditRequest', creditRequestSchema, 'creditrequests');
