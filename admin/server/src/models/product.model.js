const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/** A BrandShoot-generated model photo the admin published to a product. */
const aiImageSchema = new mongoose.Schema(
  {
    fullUrl: { type: String, default: '' }, // our re-hosted /uploads URL
    label: { type: String, default: '' }, // "Front pose", "Model 1", ...
    source: { type: String, enum: ['photoshoot', 'catalog'], default: 'photoshoot' },
    modelId: { type: String, default: '' },
    scenarioId: { type: String, default: '' },
  },
  { _id: true, timestamps: true }
);

/** Products — mirrors the Firestore "Products" doc shape (capitalized keys). */
const productSchema = new mongoose.Schema(
  {
    SKU: { type: String, default: '' },
    Title: { type: String, default: '', index: true },
    Stock: { type: Number, default: 0 },
    Stockvalue: { type: String, default: '' },
    Price: { type: Number, default: 0 },
    SalePrice: { type: Number, default: 0 },
    Images: { type: [String], default: [] },
    Thumbnail: { type: String, default: '' },
    IsFeatured: { type: Boolean, default: false },
    CategoryId: { type: String, default: '', index: true },
    CategoryName: { type: String, default: '' },
    Brand: { type: mongoose.Schema.Types.Mixed, default: null },
    Description: { type: String, default: '' },
    Link: { type: String, default: '' },
    ProductType: { type: String, default: 'single' },
    SubCategoryName: { type: String, default: '' },
    SubCategoryId: { type: String, default: '' },
    Departmentname: { type: String, default: '' },
    // Nested arrays kept flexible to accept the existing data shapes.
    ProductAttributes: { type: mongoose.Schema.Types.Mixed, default: [] },
    ProductVariations: { type: mongoose.Schema.Types.Mixed, default: [] },
    // BrandShoot AI: show "Try it on" on this product, and the model photos the
    // admin generated + published (re-hosted to our own /uploads).
    aiTryOnEnabled: { type: Boolean, default: true },
    aiGallery: { type: [aiImageSchema], default: [] },
  },
  baseSchemaOptions
);

productSchema.index({ Title: 'text', Description: 'text' });

module.exports = mongoose.model('Product', productSchema, 'products');
