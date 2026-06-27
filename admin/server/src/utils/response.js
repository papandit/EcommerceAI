/** Standard JSON envelope helpers: { success, message, data }. */

function ok(res, data = null, message = 'OK', status = 200) {
  return res.status(status).json({ success: true, message, data });
}

function created(res, data = null, message = 'Created') {
  return ok(res, data, message, 201);
}

function fail(res, message = 'Error', status = 400, extra = {}) {
  return res.status(status).json({ success: false, message, ...extra });
}

/** Wrap an async route handler so thrown errors hit the central error middleware. */
const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

module.exports = { ok, created, fail, asyncHandler };
