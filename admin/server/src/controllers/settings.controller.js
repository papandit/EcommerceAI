const Settings = require('../models/settings.model');
const { ok, asyncHandler } = require('../utils/response');

/**
 * Settings is a singleton. The BrandShoot API key spends real credits, so it is
 * NEVER returned to any client — GET replaces it with an empty string and adds a
 * `brandshootConfigured` boolean instead. The admin can set/rotate it via PUT;
 * sending an empty `brandshootKey` leaves the stored key untouched.
 */

function redact(doc) {
  const obj = typeof doc.toJSON === 'function' ? doc.toJSON() : { ...doc };
  obj.brandshootConfigured = !!obj.brandshootKey;
  obj.brandshootKey = '';
  return obj;
}

const get = asyncHandler(async (_req, res) => {
  let doc = await Settings.findOne();
  if (!doc) doc = await Settings.create({});
  return ok(res, redact(doc), 'Settings');
});

const update = asyncHandler(async (req, res) => {
  const body = { ...(req.body || {}) };
  // Empty/whitespace-only key from the admin form means "keep the existing key".
  if (body.brandshootKey == null || String(body.brandshootKey).trim() === '') {
    delete body.brandshootKey;
  }
  let doc = await Settings.findOne();
  if (!doc) doc = await Settings.create(body);
  else {
    Object.assign(doc, body);
    await doc.save();
  }
  return ok(res, redact(doc), 'Settings updated');
});

module.exports = { get, update };
