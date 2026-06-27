const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/auth.controller');
const { auth } = require('../middleware/auth');
const { authLimiter } = require('../middleware/rateLimit');

router.post('/register', authLimiter, ctrl.register);
router.post('/login', authLimiter, ctrl.login);
router.post('/google-login', authLimiter, ctrl.googleLogin);
router.post('/refresh-token', ctrl.refresh);
router.post('/forgot-password', authLimiter, ctrl.forgotPassword);
router.post('/reset-password', authLimiter, ctrl.resetPassword);
router.post('/logout', ctrl.logout);
router.get('/me', auth, ctrl.me);
router.put('/me', auth, ctrl.updateMe);

module.exports = router;
