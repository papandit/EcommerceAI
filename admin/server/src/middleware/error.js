const { fail } = require('../utils/response');

/** 404 for unmatched routes. */
function notFound(req, res) {
  return fail(res, `Route not found: ${req.method} ${req.originalUrl}`, 404);
}

/** Central error handler. Normalizes common Mongoose/JWT errors. */
// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, next) {
  let status = err.statusCode || err.status || 500;
  let message = err.message || 'Internal Server Error';

  if (err.name === 'ValidationError') {
    status = 400;
    message = Object.values(err.errors).map((e) => e.message).join(', ');
  } else if (err.name === 'CastError') {
    status = 400;
    message = `Invalid ${err.path}: ${err.value}`;
  } else if (err.code === 11000) {
    status = 409;
    const field = Object.keys(err.keyValue || {})[0] || 'field';
    message = `Duplicate value for ${field}.`;
  } else if (err.name === 'MulterError') {
    status = 400;
  }

  if (status >= 500) console.error('[error]', err);
  return fail(res, message, status);
}

module.exports = { notFound, errorHandler };
