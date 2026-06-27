const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { admin } = require('../middleware/admin');
const ctrl = require('../controllers/adminAi.controller');

// Base64 model photos exceed the global 5mb JSON limit; parse at 12mb here.
router.use(express.json({ limit: '12mb' }));

// All admin AI routes require an authenticated admin.
router.use(auth, admin);

router.get('/categories', ctrl.categories);
router.get('/models', ctrl.models);
router.post('/photoshoot', ctrl.photoshoot);
router.post('/catalog', ctrl.catalog);
router.get('/jobs/:jobId', ctrl.getJob);
router.post('/jobs/:jobId/save', ctrl.save);
router.post('/rehost', ctrl.rehost);

module.exports = router;
