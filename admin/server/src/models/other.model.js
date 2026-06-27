const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/**
 * "Others" — header/footer/policy content the storefront renders
 * (HeaderFooterModel: name, about, category, image, subcategory). Kept flexible.
 */
const otherSchema = new mongoose.Schema(
  {
    name: { type: String, default: '' },
    about: { type: String, default: '' },
    category: { type: String, default: '' },
    subcategory: { type: String, default: '' },
    image: { type: String, default: '' },
  },
  { ...baseSchemaOptions, strict: false }
);

module.exports = mongoose.model('Other', otherSchema, 'others');
