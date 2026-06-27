const Product = require('../models/product.model');
const { ok, created, fail, asyncHandler } = require('../utils/response');

/**
 * GET /api/products
 * Query: page, limit, q (search), categoryId, brandId, minPrice, maxPrice,
 *        featured, sort (newest|price_asc|price_desc|title)
 * Returns a plain array (admin/front read data as a list). When paginated,
 * pagination metadata is included in the message-less envelope via `data.items`
 * only if `paged=1`; default returns the array directly for drop-in compatibility.
 */
const list = asyncHandler(async (req, res) => {
  const { q, categoryId, brandId, featured, sort, paged } = req.query;
  const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
  const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 0, 0), 200);
  const minPrice = parseFloat(req.query.minPrice);
  const maxPrice = parseFloat(req.query.maxPrice);

  const filter = {};
  if (q && q.trim()) {
    filter.$or = [
      { Title: { $regex: q.trim(), $options: 'i' } },
      { Description: { $regex: q.trim(), $options: 'i' } },
      { SKU: { $regex: q.trim(), $options: 'i' } },
    ];
  }
  if (categoryId) filter.CategoryId = categoryId;
  if (brandId) filter['Brand.Id'] = brandId;
  if (featured === 'true' || featured === '1') filter.IsFeatured = true;
  if (!Number.isNaN(minPrice) || !Number.isNaN(maxPrice)) {
    filter.Price = {};
    if (!Number.isNaN(minPrice)) filter.Price.$gte = minPrice;
    if (!Number.isNaN(maxPrice)) filter.Price.$lte = maxPrice;
  }

  const sortMap = {
    newest: { createdAt: -1 },
    price_asc: { Price: 1 },
    price_desc: { Price: -1 },
    title: { Title: 1 },
  };
  const sortBy = sortMap[sort] || { createdAt: -1 };

  let query = Product.find(filter).sort(sortBy);
  if (limit > 0) query = query.skip((page - 1) * limit).limit(limit);
  const items = await query.exec();

  if (paged === '1' || paged === 'true') {
    const total = await Product.countDocuments(filter);
    return ok(res, { items, total, page, limit, pages: limit ? Math.ceil(total / limit) : 1 }, 'Products');
  }
  return ok(res, items, 'Products');
});

const getOne = asyncHandler(async (req, res) => {
  const item = await Product.findById(req.params.id);
  if (!item) return fail(res, 'Product not found', 404);
  return ok(res, item);
});

const create = asyncHandler(async (req, res) => {
  const item = await Product.create(req.body || {});
  return created(res, item, 'Product created');
});

const update = asyncHandler(async (req, res) => {
  const item = await Product.findByIdAndUpdate(req.params.id, req.body || {}, {
    new: true,
    runValidators: true,
  });
  if (!item) return fail(res, 'Product not found', 404);
  return ok(res, item, 'Product updated');
});

const remove = asyncHandler(async (req, res) => {
  const item = await Product.findByIdAndDelete(req.params.id);
  if (!item) return fail(res, 'Product not found', 404);
  return ok(res, { id: req.params.id }, 'Product deleted');
});

module.exports = { list, getOne, create, update, remove };
