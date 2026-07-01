const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { admin } = require('../middleware/admin');
const ctrl = require('../controllers/credit.controller');

// All credit management is admin-only.
router.use(auth, admin);

router.get('/summary', ctrl.costingSummary);
router.get('/users/:id/ledger', ctrl.userLedger);
router.post('/users/:id/adjust', ctrl.adjustUser);
router.post('/purchase', ctrl.purchase);

module.exports = router;
