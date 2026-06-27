const bcrypt = require('bcryptjs');
const User = require('../models/user.model');
const Order = require('../models/order.model');
const { ok, created, fail, asyncHandler } = require('../utils/response');

/** GET /api/users  (admin) */
const list = asyncHandler(async (req, res) => {
  const items = await User.find().sort({ createdAt: -1 });
  return ok(res, items, 'Users');
});

/** GET /api/users/:id */
const getOne = asyncHandler(async (req, res) => {
  const item = await User.findById(req.params.id);
  if (!item) return fail(res, 'User not found', 404);
  return ok(res, item);
});

/** POST /api/users  (admin) — optional password is hashed. */
const create = asyncHandler(async (req, res) => {
  const b = { ...(req.body || {}) };
  if (b.password) {
    b.passwordHash = await bcrypt.hash(b.password, 10);
    delete b.password;
  }
  if (b.Email) b.Email = String(b.Email).toLowerCase().trim();
  const item = await User.create(b);
  return created(res, item, 'User created');
});

/** PUT /api/users/:id */
const update = asyncHandler(async (req, res) => {
  const b = { ...(req.body || {}) };
  if (b.password) {
    b.passwordHash = await bcrypt.hash(b.password, 10);
    delete b.password;
  }
  const item = await User.findByIdAndUpdate(req.params.id, b, {
    new: true,
    runValidators: true,
  });
  if (!item) return fail(res, 'User not found', 404);
  return ok(res, item, 'User updated');
});

/** DELETE /api/users/:id */
const remove = asyncHandler(async (req, res) => {
  const item = await User.findByIdAndDelete(req.params.id);
  if (!item) return fail(res, 'User not found', 404);
  return ok(res, { id: req.params.id }, 'User deleted');
});

/** GET /api/users/:id/orders */
const userOrders = asyncHandler(async (req, res) => {
  const items = await Order.find({ userId: req.params.id }).sort({ createdAt: -1 });
  return ok(res, items, 'User orders');
});

module.exports = { list, getOne, create, update, remove, userOrders };
