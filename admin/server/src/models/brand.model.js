const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/** Brands — Firestore "Brands" shape. */
const brandSchema = new mongoose.Schema(
  {
    Name: { type: String, default: '' },
    Image: { type: String, default: '' },
    IsFeatured: { type: Boolean, default: false },
    ProductsCount: { type: Number, default: 0 },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Brand', brandSchema, 'brands');
