const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/** An admin photoshoot/catalog generation job (one product, N model photos). */
const aiJobSchema = new mongoose.Schema(
  {
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', index: true },
    feature: { type: String, enum: ['photoshoot', 'catalog'], default: 'photoshoot' },
    brandshootJobId: { type: String, index: true },
    status: { type: String, default: 'generating' }, // generating | done | error
    totalImages: { type: Number, default: 0 },
    images: {
      type: [
        {
          fullUrl: { type: String, default: '' },
          label: { type: String, default: '' },
          scenarioId: { type: String, default: '' },
        },
      ],
      default: [],
    },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('AiJob', aiJobSchema, 'aijobs');
