const path = require('path');
const fs = require('fs');
const multer = require('multer');
const sharp = require('sharp');

const UPLOAD_ROOT = path.resolve(
  process.cwd(),
  process.env.UPLOAD_PATH || 'uploads'
);

// Folders mirror the old Firebase Storage paths (and future Hostinger paths).
// `ai` holds re-hosted BrandShoot model photos published to a product gallery.
const VALID_TYPES = ['products', 'categories', 'banners', 'users', 'brands', 'ai', 'misc'];

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}
VALID_TYPES.forEach((t) => ensureDir(path.join(UPLOAD_ROOT, t)));

// Keep the original bytes in memory; we re-encode with sharp before writing.
const memory = multer.memoryStorage();

const IMAGE_EXT = /\.(png|jpe?g|jfif|pjpeg|jpe|webp|gif|bmp|svg|avif|heic|heif)$/i;

const upload = multer({
  storage: memory,
  limits: { fileSize: 12 * 1024 * 1024 }, // 12MB
  fileFilter: (_req, file, cb) => {
    // Flutter Web's MultipartFile sends bytes as application/octet-stream (no
    // content-type), so accept image/*, octet-stream, or a known image
    // extension. The actual bytes are validated by sharp when re-encoding.
    const okMime =
      /^image\//.test(file.mimetype) ||
      file.mimetype === 'application/octet-stream' ||
      !file.mimetype;
    const okExt = IMAGE_EXT.test(file.originalname || '');
    if (okMime || okExt) return cb(null, true);
    return cb(new Error('Only image files are allowed.'));
  },
});

function safeBase(name) {
  return (name || 'image')
    .replace(/\.[^.]+$/, '')
    .replace(/[^a-z0-9_-]+/gi, '-')
    .toLowerCase()
    .slice(0, 40) || 'image';
}

/**
 * Compress + write an uploaded buffer to uploads/<type>/<name>.webp and return
 * its public URL ({BASE_URL}/uploads/<type>/<file>).
 */
async function processAndSave(file, type, baseUrl) {
  const folder = VALID_TYPES.includes(type) ? type : 'misc';
  const dir = path.join(UPLOAD_ROOT, folder);
  ensureDir(dir);

  const stamp = Date.now() + '-' + Math.round(Math.random() * 1e6);
  const filename = `${safeBase(file.originalname)}-${stamp}.webp`;
  const outPath = path.join(dir, filename);

  await sharp(file.buffer)
    .rotate()
    .resize({ width: 1600, height: 1600, fit: 'inside', withoutEnlargement: true })
    .webp({ quality: 82 })
    .toFile(outPath);

  const base = (baseUrl || process.env.BASE_URL || '').replace(/\/$/, '');
  return {
    url: `${base}/uploads/${folder}/${filename}`,
    folder,
    filename,
    fullPath: `/uploads/${folder}/${filename}`,
  };
}

module.exports = { upload, processAndSave, UPLOAD_ROOT, VALID_TYPES };
