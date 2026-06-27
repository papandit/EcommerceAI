const { ok, asyncHandler } = require('../utils/response');

/**
 * Build GET/PUT handlers for a singleton document (Settings, LuxeEdit).
 * GET returns the single doc (creating an empty one on first access).
 * PUT upserts the single doc.
 */
function singletonController(Model, label = 'Config') {
  const get = asyncHandler(async (_req, res) => {
    let doc = await Model.findOne();
    if (!doc) doc = await Model.create({});
    return ok(res, doc, label);
  });

  const update = asyncHandler(async (req, res) => {
    let doc = await Model.findOne();
    if (!doc) doc = await Model.create(req.body || {});
    else {
      Object.assign(doc, req.body || {});
      await doc.save();
    }
    return ok(res, doc, `${label} updated`);
  });

  return { get, update };
}

module.exports = { singletonController };
