const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/** LuxeEdit promo hero — singleton (Firestore "LuxeEdit/main"). tiles is Mixed. */
const luxeEditSchema = new mongoose.Schema(
  {
    backgroundImage: { type: String, default: '' },
    title: { type: String, default: '' },
    subtitle: { type: String, default: '' },
    buttonText: { type: String, default: '' },
    buttonLink: { type: String, default: '' },
    active: { type: Boolean, default: false },
    tiles: { type: mongoose.Schema.Types.Mixed, default: [] },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('LuxeEdit', luxeEditSchema, 'luxeedit');
