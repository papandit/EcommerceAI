const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { admin } = require('../middleware/admin');
const ctrl = require('../controllers/credit.controller');

// All credit management is admin-only.
router.use(auth, admin);

router.get('/summary', ctrl.costingSummary);
router.get('/users', ctrl.listUsers);
router.get('/users/:id/ledger', ctrl.userLedger);
router.post('/users/:id/adjust', ctrl.adjustUser);
router.post('/purchase', ctrl.purchase);
router.post('/pool', ctrl.setPool);
// Shopper credit requests (admin inbox)
router.get('/requests', ctrl.listRequests);
router.post('/requests/:id', ctrl.handleRequest);
router.delete('/requests/:id', ctrl.deleteRequest);
// Bulk distribution
router.post('/grant-all', ctrl.grantAll);

module.exports = router;
