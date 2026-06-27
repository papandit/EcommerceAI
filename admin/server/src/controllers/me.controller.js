const Cart = require('../models/cart.model');
const Wishlist = require('../models/wishlist.model');
const Address = require('../models/address.model');
const { ok, asyncHandler } = require('../utils/response');

/**
 * Per-user (single-doc) cart / wishlist / addresses. The storefront stores one
 * document per user keyed by Userid, so these endpoints upsert by req.user.id.
 */

// ---- Cart ----
const getCart = asyncHandler(async (req, res) => {
  let doc = await Cart.findOne({ Userid: req.user.id });
  if (!doc) doc = await Cart.create({ Userid: req.user.id, Cartitems: [] });
  return ok(res, doc, 'Cart');
});

const putCart = asyncHandler(async (req, res) => {
  const items = (req.body && (req.body.Cartitems ?? req.body.items)) || [];
  const doc = await Cart.findOneAndUpdate(
    { Userid: req.user.id },
    { Userid: req.user.id, Cartitems: items },
    { new: true, upsert: true, setDefaultsOnInsert: true }
  );
  return ok(res, doc, 'Cart updated');
});

// ---- Wishlist ----
const getWishlist = asyncHandler(async (req, res) => {
  let doc = await Wishlist.findOne({ Userid: req.user.id });
  if (!doc) doc = await Wishlist.create({ Userid: req.user.id, Wishlistitems: [] });
  return ok(res, doc, 'Wishlist');
});

const putWishlist = asyncHandler(async (req, res) => {
  const items =
    (req.body && (req.body.Wishlistitems ?? req.body.items)) || [];
  const doc = await Wishlist.findOneAndUpdate(
    { Userid: req.user.id },
    { Userid: req.user.id, Wishlistitems: items },
    { new: true, upsert: true, setDefaultsOnInsert: true }
  );
  return ok(res, doc, 'Wishlist updated');
});

// ---- Addresses (single doc holding a list) ----
const getAddresses = asyncHandler(async (req, res) => {
  let doc = await Address.findOne({ Userid: req.user.id });
  if (!doc) doc = await Address.create({ Userid: req.user.id, Addresslist: [] });
  return ok(res, doc, 'Addresses');
});

const putAddresses = asyncHandler(async (req, res) => {
  const list = (req.body && (req.body.Addresslist ?? req.body.items)) || [];
  const doc = await Address.findOneAndUpdate(
    { Userid: req.user.id },
    { Userid: req.user.id, Addresslist: list },
    { new: true, upsert: true, setDefaultsOnInsert: true }
  );
  return ok(res, doc, 'Addresses updated');
});

// ---- Orders (current user) ----
const Order = require('../models/order.model');
const myOrders = asyncHandler(async (req, res) => {
  const items = await Order.find({ userId: req.user.id }).sort({ createdAt: -1 });
  return ok(res, items, 'My orders');
});

module.exports = {
  getCart,
  putCart,
  getWishlist,
  putWishlist,
  getAddresses,
  putAddresses,
  myOrders,
};
