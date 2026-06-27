const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/** Cart — one doc per user (Firestore "Cart" shape: Userid + Cartitems[]). */
const cartSchema = new mongoose.Schema(
  {
    Userid: { type: String, default: '', index: true },
    Cartitems: { type: mongoose.Schema.Types.Mixed, default: [] },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Cart', cartSchema, 'carts');
