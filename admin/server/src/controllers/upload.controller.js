const { processAndSave } = require('../middleware/upload');
const Image = require('../models/image.model');
const { ok, fail, asyncHandler } = require('../utils/response');

// Map the route segment to a storage folder + media category.
const TYPE_FOLDER = {
  product: 'products',
  banner: 'banners',
  category: 'categories',
  profile: 'users',
  brand: 'brands',
};

/**
 * POST /api/upload/:type   (multipart, field name "file" or "image")
 * Compresses + stores the image, records metadata, returns { url, ... }.
 */
const uploadImage = asyncHandler(async (req, res) => {
  const type = req.params.type;
  const folder = TYPE_FOLDER[type];
  if (!folder) return fail(res, `Unknown upload type: ${type}`, 400);
  if (!req.file) return fail(res, 'No file uploaded (field "file").', 400);

  const baseUrl = `${req.protocol}://${req.get('host')}`;
  const saved = await processAndSave(req.file, folder, baseUrl);

  // Bookkeeping (non-fatal if it fails).
  let image = null;
  try {
    image = await Image.create({
      url: saved.url,
      folder: saved.folder,
      filename: saved.filename,
      fullPath: saved.fullPath,
      sizeBytes: req.file.size || 0,
      contentType: 'image/webp',
      mediaCategory: folder,
    });
  } catch (_) {
    /* ignore */
  }

  return ok(res, { url: saved.url, ...saved, image }, 'Uploaded');
});

module.exports = { uploadImage };
