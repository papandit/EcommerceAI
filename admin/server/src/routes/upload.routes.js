const express = require('express');
const router = express.Router();
const { upload } = require('../middleware/upload');
const { uploadImage } = require('../controllers/upload.controller');
const { auth } = require('../middleware/auth');

// Accept the file under either "file" or "image" field name.
const single = upload.fields([
  { name: 'file', maxCount: 1 },
  { name: 'image', maxCount: 1 },
]);

// Normalize req.files -> req.file for the controller.
function pickFile(req, _res, next) {
  if (req.files) {
    req.file = (req.files.file && req.files.file[0]) || (req.files.image && req.files.image[0]) || null;
  }
  next();
}

// POST /api/upload/:type  (product|banner|category|profile|brand)
router.post('/:type', auth, single, pickFile, uploadImage);

module.exports = router;
