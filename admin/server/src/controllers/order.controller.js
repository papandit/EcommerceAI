const Order = require('../models/order.model');
const { ok, created, fail, asyncHandler } = require('../utils/response');
const { sendOrderEmail } = require('../utils/mailer');

/** GET /api/orders?userId=&status=  (admin lists all; supports filters) */
const list = asyncHandler(async (req, res) => {
  const filter = {};
  if (req.query.userId) filter.userId = req.query.userId;
  if (req.query.status) filter.status = req.query.status;
  const items = await Order.find(filter).sort({ createdAt: -1 });
  return ok(res, items, 'Orders');
});

const getOne = asyncHandler(async (req, res) => {
  const item = await Order.findById(req.params.id);
  if (!item) return fail(res, 'Order not found', 404);
  return ok(res, item);
});

const create = asyncHandler(async (req, res) => {
  const body = { ...(req.body || {}) };
  // Always stamp the authenticated user's id so the order links to them and
  // shows up under /me/orders — never trust a blank/foreign client value.
  if (req.user && req.user.id) body.userId = req.user.id;
  const item = await Order.create(body);
  // Best-effort confirmation email. Fire-and-forget: never block the response
  // and swallow any failure so order creation always succeeds.
  sendOrderEmail(item).catch(() => {});
  return created(res, item, 'Order created');
});

const update = asyncHandler(async (req, res) => {
  const item = await Order.findByIdAndUpdate(req.params.id, req.body || {}, {
    new: true,
    runValidators: true,
  });
  if (!item) return fail(res, 'Order not found', 404);
  return ok(res, item, 'Order updated');
});

const remove = asyncHandler(async (req, res) => {
  const item = await Order.findByIdAndDelete(req.params.id);
  if (!item) return fail(res, 'Order not found', 404);
  return ok(res, { id: req.params.id }, 'Order deleted');
});

module.exports = { list, getOne, create, update, remove };
