const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/**
 * Categories — Firestore "Categories" shape. ParentId holds the list of
 * sub-categories ([{id,name}]) the storefront reads, so it's kept Mixed.
 */
const categorySchema = new mongoose.Schema(
  {
    Name: { type: String, default: '' },
    Image: { type: String, default: '' },
    ParentId: { type: mongoose.Schema.Types.Mixed, default: [] },
    IsFeatured: { type: Boolean, default: false },
    // Department this category belongs to (e.g. "Ethnic Wear").
    Department: { type: String, default: '' },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Category', categorySchema, 'categories');
