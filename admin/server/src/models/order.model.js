const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/**
 * Orders — union of the admin + storefront order shapes. Nested address/items/
 * coupon are Mixed to accept both apps' structures. `status` is stored as a
 * clean value (pending|processing|shipped|delivered).
 */
const orderSchema = new mongoose.Schema(
  {
    userId: { type: String, default: '', index: true },
    email: { type: String, default: '' },
    Orderid: { type: String, default: '' },
    devicetoken: { type: String, default: '' },
    status: { type: String, default: 'pending' },
    subtotal: { type: mongoose.Schema.Types.Mixed, default: 0 },
    totalAmount: { type: Number, default: 0 },
    shippingCost: { type: Number, default: 0 },
    taxCost: { type: Number, default: 0 },
    orderDate: { type: Date, default: Date.now },
    deliveryDate: { type: Date, default: null },
    paymentMethod: { type: String, default: '' },
    billingAddressSameAsShipping: { type: Boolean, default: true },
    shippingAddress: { type: mongoose.Schema.Types.Mixed, default: null },
    billingAddress: { type: mongoose.Schema.Types.Mixed, default: null },
    coupanModel: { type: mongoose.Schema.Types.Mixed, default: null },
    items: { type: mongoose.Schema.Types.Mixed, default: [] },
    trackingNumber: { type: String, default: '' },
    trackingUrl: { type: String, default: '' },
    paymentStatus: { type: String, default: 'unpaid' },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('Order', orderSchema, 'orders');
