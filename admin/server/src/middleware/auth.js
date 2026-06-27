const { verifyAccessToken } = require('../utils/jwt');
const { fail } = require('../utils/response');

/**
 * Require a valid JWT. Reads "Authorization: Bearer <token>".
 * On success attaches { id, role, email } to req.user.
 */
function auth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return fail(res, 'Authentication required.', 401);
  try {
    const decoded = verifyAccessToken(token);
    req.user = { id: decoded.sub, role: decoded.role, email: decoded.email };
    return next();
  } catch (err) {
    return fail(res, 'Invalid or expired token.', 401);
  }
}

/** Optional auth: attaches req.user if a valid token is present, else continues. */
function optionalAuth(req, _res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (token) {
    try {
      const decoded = verifyAccessToken(token);
      req.user = { id: decoded.sub, role: decoded.role, email: decoded.email };
    } catch (_) {
      /* ignore */
    }
  }
  return next();
}

module.exports = { auth, optionalAuth };
