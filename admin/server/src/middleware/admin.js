const { fail } = require('../utils/response');

/** Require the authenticated user to have an admin role. Use after auth(). */
function admin(req, res, next) {
  const role = (req.user && req.user.role ? String(req.user.role) : '').toLowerCase();
  if (role !== 'admin') return fail(res, 'Admin access required.', 403);
  return next();
}

module.exports = { admin };
