const bcrypt = require('bcryptjs');
const User = require('../models/user.model');
const { ok, created, fail, asyncHandler } = require('../utils/response');
const { issueTokens, verifyRefreshToken } = require('../utils/jwt');
const { verifyIdToken } = require('../config/firebaseAdmin');
const { sendMail } = require('../utils/mailer');

function genOtp() {
  return String(Math.floor(100000 + Math.random() * 900000)); // 6 digits
}

function publicUser(userDoc) {
  const u = userDoc.toJSON ? userDoc.toJSON() : userDoc;
  delete u.passwordHash;
  return u;
}

/** POST /api/auth/register  { email, password, firstName?, lastName?, phone?, name? } */
const register = asyncHandler(async (req, res) => {
  const b = req.body || {};
  const email = (b.email || b.Email || '').toLowerCase().trim();
  const password = b.password || b.Password || '';
  if (!email || !password) return fail(res, 'Email and password are required.', 400);
  if (password.length < 6) return fail(res, 'Password must be at least 6 characters.', 400);

  const exists = await User.findOne({ Email: email });
  if (exists) return fail(res, 'An account with this email already exists.', 409);

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await User.create({
    Email: email,
    passwordHash,
    FirstName: b.firstName || b.FirstName || b.name || b.Name || '',
    LastName: b.lastName || b.LastName || '',
    UserName: b.userName || b.UserName || '',
    PhoneNumber: b.phone || b.PhoneNumber || '',
    Role: b.role || b.Role || 'user',
    authProvider: 'local',
    Verifyotp: true,
  });

  const tokens = issueTokens(user);
  return created(res, { ...tokens, user: publicUser(user) }, 'Registered');
});

/** POST /api/auth/login  { email, password } */
const login = asyncHandler(async (req, res) => {
  const b = req.body || {};
  const email = (b.email || b.Email || '').toLowerCase().trim();
  const password = b.password || b.Password || '';
  if (!email || !password) return fail(res, 'Email and password are required.', 400);

  const user = await User.findOne({ Email: email }).select('+passwordHash');
  if (!user || !user.passwordHash) return fail(res, 'Invalid email or password.', 401);

  const match = await bcrypt.compare(password, user.passwordHash);
  if (!match) return fail(res, 'Invalid email or password.', 401);
  if (user.status && user.status !== 'active')
    return fail(res, 'This account is disabled.', 403);

  const tokens = issueTokens(user);
  return ok(res, { ...tokens, user: publicUser(user) }, 'Logged in');
});

/**
 * POST /api/auth/google-login  { idToken }
 * Verifies the Firebase ID token, upserts the user, returns our JWT.
 * Requires firebase-admin credentials (storefront phase).
 */
const googleLogin = asyncHandler(async (req, res) => {
  const idToken = (req.body && (req.body.idToken || req.body.token)) || '';
  if (!idToken) return fail(res, 'idToken is required.', 400);

  const decoded = await verifyIdToken(idToken); // throws 501 if not configured
  const email = (decoded.email || '').toLowerCase();
  if (!email) return fail(res, 'Google account has no email.', 400);

  let user = await User.findOne({ Email: email });
  if (!user) {
    user = await User.create({
      Email: email,
      FirstName: decoded.name || (decoded.email || '').split('@')[0],
      ProfilePicture: decoded.picture || '',
      Role: 'user',
      authProvider: 'google',
      firebaseUid: decoded.uid || '',
      Verifyotp: true,
    });
  } else if (!user.firebaseUid && decoded.uid) {
    user.firebaseUid = decoded.uid;
    user.authProvider = user.authProvider || 'google';
    await user.save();
  }

  const tokens = issueTokens(user);
  return ok(res, { ...tokens, user: publicUser(user) }, 'Logged in with Google');
});

/** POST /api/auth/refresh-token  { refreshToken } */
const refresh = asyncHandler(async (req, res) => {
  const rt = (req.body && (req.body.refreshToken || req.body.token)) || '';
  if (!rt) return fail(res, 'refreshToken is required.', 400);
  let decoded;
  try {
    decoded = verifyRefreshToken(rt);
  } catch (_) {
    return fail(res, 'Invalid or expired refresh token.', 401);
  }
  const user = await User.findById(decoded.sub);
  if (!user) return fail(res, 'User not found.', 401);
  const tokens = issueTokens(user);
  return ok(res, { ...tokens, user: publicUser(user) }, 'Token refreshed');
});

/** GET /api/auth/me  (requires auth) */
const me = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id);
  if (!user) return fail(res, 'User not found.', 404);
  return ok(res, publicUser(user));
});

/** PUT /api/auth/me — update the current user's own profile (name/phone/photo). */
const updateMe = asyncHandler(async (req, res) => {
  const b = req.body || {};
  const update = {};
  if (b.FirstName != null || b.firstName != null || b.name != null) {
    update.FirstName = b.FirstName ?? b.firstName ?? b.name;
  }
  if (b.LastName != null || b.lastName != null) update.LastName = b.LastName ?? b.lastName;
  if (b.PhoneNumber != null || b.phone != null) update.PhoneNumber = b.PhoneNumber ?? b.phone;
  if (b.UserName != null || b.userName != null) update.UserName = b.UserName ?? b.userName;
  if (b.ProfilePicture != null || b.profilePicture != null) {
    update.ProfilePicture = b.ProfilePicture ?? b.profilePicture;
  }
  const user = await User.findByIdAndUpdate(req.user.id, update, { new: true });
  if (!user) return fail(res, 'User not found.', 404);
  return ok(res, publicUser(user), 'Profile updated');
});

/**
 * POST /api/auth/forgot-password  { email }
 * Generates a 6-digit OTP (valid 10 min) and emails it. Always responds the
 * same way whether or not the email exists (no account enumeration). If SMTP
 * isn't configured, the OTP is returned as `devOtp` in non-production so the
 * flow is testable — configure SMTP in admin Settings for real delivery.
 */
const forgotPassword = asyncHandler(async (req, res) => {
  const b = req.body || {};
  const email = (b.email || b.Email || '').toLowerCase().trim();
  if (!email) return fail(res, 'Email is required.', 400);

  const user = await User.findOne({ Email: email });
  if (!user) {
    // Don't reveal that the email isn't registered.
    return ok(res, { sent: true }, 'If an account exists, a reset code has been sent.');
  }

  const otp = genOtp();
  user.resetOtp = otp;
  user.resetOtpExpires = new Date(Date.now() + 10 * 60 * 1000);
  await user.save();

  let emailed = false;
  try {
    emailed = await sendMail({
      to: email,
      subject: 'Your password reset code',
      text: `Your password reset code is ${otp}. It expires in 10 minutes.\n\nIf you didn't request this, you can ignore this email.`,
    });
  } catch (e) {
    console.error('[password reset email failed]', e.message);
  }
  // Always log in dev so the OTP is recoverable without SMTP.
  console.log(`[password reset] OTP for ${email}: ${otp} (emailed=${emailed})`);

  const payload = { sent: emailed };
  if (!emailed && process.env.NODE_ENV !== 'production') {
    payload.devOtp = otp; // dev convenience only — never set in production
  }
  return ok(
    res,
    payload,
    emailed ? 'A reset code has been sent to your email.' : 'Reset code generated.'
  );
});

/**
 * POST /api/auth/reset-password  { email, otp, newPassword }
 * Verifies the OTP, sets the new password, and signs the user in.
 */
const resetPassword = asyncHandler(async (req, res) => {
  const b = req.body || {};
  const email = (b.email || b.Email || '').toLowerCase().trim();
  const otp = String(b.otp || b.code || '').trim();
  const newPassword = b.newPassword || b.password || '';

  if (!email || !otp || !newPassword) {
    return fail(res, 'Email, code and new password are required.', 400);
  }
  if (newPassword.length < 6) {
    return fail(res, 'Password must be at least 6 characters.', 400);
  }

  const user = await User.findOne({ Email: email }).select(
    '+resetOtp +resetOtpExpires +passwordHash'
  );
  if (!user || !user.resetOtp) return fail(res, 'Invalid or expired code.', 400);
  if (user.resetOtp !== otp) return fail(res, 'Incorrect code.', 400);
  if (!user.resetOtpExpires || user.resetOtpExpires.getTime() < Date.now()) {
    return fail(res, 'This code has expired. Please request a new one.', 400);
  }

  user.passwordHash = await bcrypt.hash(newPassword, 10);
  user.resetOtp = '';
  user.resetOtpExpires = undefined;
  await user.save();

  const tokens = issueTokens(user);
  return ok(res, { ...tokens, user: publicUser(user) }, 'Password reset successfully.');
});

/** POST /api/auth/logout — stateless JWT, so this is a client-side no-op. */
const logout = asyncHandler(async (_req, res) => ok(res, null, 'Logged out'));

module.exports = {
  register,
  login,
  googleLogin,
  refresh,
  me,
  updateMe,
  logout,
  forgotPassword,
  resetPassword,
};
