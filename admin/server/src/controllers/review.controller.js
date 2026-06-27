const Review = require('../models/review.model');
const { ok, created, fail, asyncHandler } = require('../utils/response');

/** GET /api/reviews?productId=  — public. Lists reviews (optionally by product). */
const list = asyncHandler(async (req, res) => {
  const filter = {};
  if (req.query.productId) filter.productId = String(req.query.productId);
  const items = await Review.find(filter).sort({ createdAt: -1 });
  return ok(res, items, 'Review list');
});

/** POST /api/reviews — anyone (optionalAuth). Stamps the user when logged in. */
const create = asyncHandler(async (req, res) => {
  const b = req.body || {};
  const ratingNum = Number(b.rating) || 0;
  const doc = await Review.create({
    productId: String(b.productId || ''),
    rating: ratingNum < 0 ? 0 : ratingNum > 5 ? 5 : ratingNum,
    comment: b.comment || b.message || '',
    message: b.message || b.comment || '',
    images: Array.isArray(b.images) ? b.images : [],
    name: b.name || '',
    email: b.email || '',
    phonenumber: b.phonenumber || b.phoneNumber || '',
    userid: (req.user && req.user.id) || b.userid || '',
  });
  return created(res, doc, 'Review submitted');
});

/** PUT /api/reviews/:id — admin. */
const update = asyncHandler(async (req, res) => {
  const item = await Review.findByIdAndUpdate(req.params.id, req.body || {}, {
    new: true,
  });
  if (!item) return fail(res, 'Review not found', 404);
  return ok(res, item, 'Review updated');
});

/** DELETE /api/reviews/:id — admin. */
const remove = asyncHandler(async (req, res) => {
  await Review.findByIdAndDelete(req.params.id);
  return ok(res, null, 'Review deleted');
});

module.exports = { list, create, update, remove };
