const { ok, created, fail, asyncHandler } = require('../utils/response');

/**
 * Build standard CRUD handlers for a Mongoose model.
 * Options:
 *  - defaultSort: sort object (default { createdAt: -1 })
 *  - label: human name for messages
 */
function crudController(Model, { defaultSort = { createdAt: -1 }, label = 'Item' } = {}) {
  const list = asyncHandler(async (req, res) => {
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 0, 0), 200);
    let query = Model.find().sort(defaultSort);
    if (limit > 0) query = query.skip((page - 1) * limit).limit(limit);
    const items = await query.exec();
    return ok(res, items, `${label} list`);
  });

  const getOne = asyncHandler(async (req, res) => {
    const item = await Model.findById(req.params.id);
    if (!item) return fail(res, `${label} not found`, 404);
    return ok(res, item);
  });

  const create = asyncHandler(async (req, res) => {
    const item = await Model.create(req.body || {});
    return created(res, item, `${label} created`);
  });

  const update = asyncHandler(async (req, res) => {
    const item = await Model.findByIdAndUpdate(req.params.id, req.body || {}, {
      new: true,
      runValidators: true,
    });
    if (!item) return fail(res, `${label} not found`, 404);
    return ok(res, item, `${label} updated`);
  });

  const remove = asyncHandler(async (req, res) => {
    const item = await Model.findByIdAndDelete(req.params.id);
    if (!item) return fail(res, `${label} not found`, 404);
    return ok(res, { id: req.params.id }, `${label} deleted`);
  });

  return { list, getOne, create, update, remove };
}

module.exports = { crudController };
