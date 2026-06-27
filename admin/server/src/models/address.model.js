const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/**
 * Address — supports both shapes used by the apps:
 *  - storefront: one doc per user holding an Addresslist[] array
 *  - admin: individual address fields
 * Both the array and the flat fields are kept so either app reads what it needs.
 */
const addressSchema = new mongoose.Schema(
  {
    Userid: { type: String, default: '', index: true },
    Addresslist: { type: mongoose.Schema.Types.Mixed, default: [] },

    Name: { type: String, default: '' },
    PhoneNumber: { type: String, default: '' },
    Street: { type: String, default: '' },
    City: { type: String, default: '' },
    State: { type: String, default: '' },
    PostalCode: { type: String, default: '' },
    Country: { type: String, default: '' },
    SelectedAddress: { type: Boolean, default: false },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Address', addressSchema, 'addresses');
