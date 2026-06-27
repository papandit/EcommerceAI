const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/** Reviews / contact messages — Firestore "Review" shape. */
const reviewSchema = new mongoose.Schema(
  {
    userid: { type: String, default: '' },
    name: { type: String, default: '' },
    email: { type: String, default: '' },
    message: { type: String, default: '' },
    phonenumber: { type: String, default: '' },
    // Product review fields
    productId: { type: String, default: '' },
    rating: { type: Number, default: 0 },
    comment: { type: String, default: '' },
    images: { type: [String], default: [] },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Review', reviewSchema, 'reviews');
