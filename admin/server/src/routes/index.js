const express = require('express');
const router = express.Router();

const { auth, optionalAuth } = require('../middleware/auth');
const { admin } = require('../middleware/admin');
const { crudController } = require('../controllers/crud.factory');
const { singletonController } = require('../controllers/singleton.controller');

// Models
const Category = require('../models/category.model');
const Banner = require('../models/banner.model');
const Brand = require('../models/brand.model');
const Department = require('../models/department.model');
const Order = require('../models/order.model');
const Coupon = require('../models/coupon.model');
const Review = require('../models/review.model');
const Cart = require('../models/cart.model');
const Wishlist = require('../models/wishlist.model');
const Address = require('../models/address.model');
const Settings = require('../models/settings.model');
const LuxeEdit = require('../models/luxeEdit.model');

/**
 * Mount a CRUD resource. By default: GET public, writes require auth+admin.
 * Override `read`/`write` middleware arrays per resource.
 */
function resource(path, Model, opts = {}) {
  const c = crudController(Model, { label: opts.label || path });
  const read = opts.read || [];
  const write = opts.write || [auth, admin];
  const r = express.Router();
  r.get('/', ...read, c.list);
  r.get('/:id', ...read, c.getOne);
  r.post('/', ...write, c.create);
  r.put('/:id', ...write, c.update);
  r.delete('/:id', ...write, c.remove);
  router.use(path, r);
}

// Custom routers
router.use('/auth', require('./auth.routes'));
router.use('/products', require('./product.routes'));
router.use('/upload', require('./upload.routes'));
router.use('/payments', require('./payment.routes'));
// BrandShoot AI: customer try-on (/api/ai) + admin photoshoot/catalog (/api/admin/ai)
router.use('/ai', require('./aiTryon.routes'));
router.use('/admin/ai', require('./adminAi.routes'));
// Try-on credits: costing summary + per-user grant/adjust (admin only)
router.use('/admin/credits', require('./credit.routes'));

// Images (media library): list by category, delete. Records are created on upload.
(() => {
  const Image = require('../models/image.model');
  const { ok, asyncHandler } = require('../utils/response');
  const r = express.Router();
  r.get('/', auth, asyncHandler(async (req, res) => {
    const filter = {};
    if (req.query.category) filter.mediaCategory = req.query.category;
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 0, 0), 200);
    const skip = Math.max(parseInt(req.query.skip, 10) || 0, 0);
    let q = Image.find(filter).sort({ createdAt: -1 });
    if (skip) q = q.skip(skip);
    if (limit) q = q.limit(limit);
    return ok(res, await q.exec(), 'Images');
  }));
  r.delete('/:id', auth, admin, asyncHandler(async (req, res) => {
    await Image.findByIdAndDelete(req.params.id);
    return ok(res, { id: req.params.id }, 'Image deleted');
  }));
  router.use('/images', r);
})();

// Catalog (admin-managed): public read, admin write
resource('/categories', Category, { label: 'Category' });
resource('/banners', Banner, { label: 'Banner' });
resource('/brands', Brand, { label: 'Brand' });
resource('/departments', Department, { label: 'Department' });
resource('/coupons', Coupon, { label: 'Coupon' });

// Users (admin-managed). Never leaks passwordHash (select:false on the model).
(() => {
  const c = require('../controllers/user.controller');
  const r = express.Router();
  r.get('/', auth, admin, c.list);
  r.get('/:id', auth, c.getOne);
  r.get('/:id/orders', auth, c.userOrders);
  r.post('/', auth, admin, c.create);
  r.put('/:id', auth, c.update);
  r.delete('/:id', auth, admin, c.remove);
  router.use('/users', r);
})();

// Orders: list/update/delete admin; create by any authenticated user; getOne authed
(() => {
  const c = require('../controllers/order.controller');
  const r = express.Router();
  r.get('/', auth, admin, c.list);
  r.get('/:id', auth, c.getOne);
  r.post('/', auth, c.create);
  r.put('/:id', auth, admin, c.update);
  r.delete('/:id', auth, admin, c.remove);
  router.use('/orders', r);
})();

// Reviews: public read (per product), anyone can submit, admin manages.
(() => {
  const c = require('../controllers/review.controller');
  const r = express.Router();
  r.get('/', c.list); // public — supports ?productId=
  r.post('/', optionalAuth, c.create);
  r.put('/:id', auth, admin, c.update);
  r.delete('/:id', auth, admin, c.remove);
  router.use('/reviews', r);
})();

// Per-user resources (storefront): require auth
resource('/carts', Cart, { label: 'Cart', read: [auth], write: [auth] });
resource('/wishlists', Wishlist, { label: 'Wishlist', read: [auth], write: [auth] });
resource('/addresses', Address, { label: 'Address', read: [auth], write: [auth] });

// Current-user single-doc cart/wishlist/addresses + my orders.
(() => {
  const c = require('../controllers/me.controller');
  const r = express.Router();
  r.get('/cart', auth, c.getCart);
  r.put('/cart', auth, c.putCart);
  r.get('/wishlist', auth, c.getWishlist);
  r.put('/wishlist', auth, c.putWishlist);
  r.get('/addresses', auth, c.getAddresses);
  r.put('/addresses', auth, c.putAddresses);
  r.get('/orders', auth, c.myOrders);
  router.use('/me', r);
})();

// Others (header/footer/policy content): public read, admin write.
resource('/others', require('../models/other.model'), { label: 'Other' });

// Singletons
(() => {
  // Settings uses a dedicated controller so the BrandShoot key is redacted on
  // read and preserved when the admin saves the form without re-entering it.
  const s = require('../controllers/settings.controller');
  router.get('/settings', s.get);
  router.put('/settings', auth, admin, s.update);
})();
(() => {
  const s = singletonController(LuxeEdit, 'LuxeEdit');
  router.get('/luxeedit', s.get);
  router.put('/luxeedit', auth, admin, s.update);
})();

module.exports = router;
