const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/** Banners — Firestore "Banners" shape (lowercase keys, as the models expect). */
const bannerSchema = new mongoose.Schema(
  {
    imageUrl: { type: String, default: '' },
    active: { type: Boolean, default: true },
    targetScreen: { type: String, default: '' },
    title: { type: String, default: '' },
    subtitle: { type: String, default: '' },
    buttonText: { type: String, default: '' },
    buttonLink: { type: String, default: '' },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Banner', bannerSchema, 'banners');
