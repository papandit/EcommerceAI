const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const ctrl = require('../controllers/aiTryon.controller');

// Base64 photos are larger than the global 5mb JSON limit, so this router parses
// its own bodies at 12mb (matching the multer upload limit).
router.use(express.json({ limit: '12mb' }));

router.get('/models', auth, ctrl.models);
router.get('/tryon/credits', auth, ctrl.balance);
router.post('/tryon/credits/request', auth, ctrl.requestCredits);
router.get('/tryon/history', auth, ctrl.history);
router.post('/tryon', auth, ctrl.tryon);
router.get('/jobs/:jobId', auth, ctrl.getJob);

module.exports = router;
