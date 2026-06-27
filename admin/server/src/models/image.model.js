const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/** Image metadata (Firestore "Images") — bookkeeping for the media library. */
const imageSchema = new mongoose.Schema(
  {
    url: { type: String, default: '' },
    folder: { type: String, default: '' },
    filename: { type: String, default: '' },
    fullPath: { type: String, default: '' },
    sizeBytes: { type: Number, default: 0 },
    contentType: { type: String, default: '' },
    mediaCategory: { type: String, default: '', index: true },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Image', imageSchema, 'images');
