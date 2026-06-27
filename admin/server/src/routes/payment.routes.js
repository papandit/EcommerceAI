const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/payment.controller');
const { auth } = require('../middleware/auth');

router.post('/razorpay/order', auth, ctrl.razorpayOrder);
router.post('/razorpay/verify', auth, ctrl.razorpayVerify);
router.post('/stripe/session', auth, ctrl.stripeSession);

module.exports = router;
