const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/** Wishlist — one doc per user (Firestore "Wishlist" shape). */
const wishlistSchema = new mongoose.Schema(
  {
    Userid: { type: String, default: '', index: true },
    Wishlistitems: { type: mongoose.Schema.Types.Mixed, default: [] },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Wishlist', wishlistSchema, 'wishlists');
