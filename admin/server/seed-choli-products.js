/*
 * Seed Chaniya Choli / Navratri products from the "choli photo/" folder.
 *
 *   node seed-choli-products.js            # create (idempotent — skips existing titles)
 *
 * Each image becomes one product with sizes S/M/L/XL and 5 festive colours,
 * placed in a "Chaniya Choli" category (category page) and a "Navratri"
 * department (home "Navratri" section). Images are compressed to webp and hosted
 * under /uploads/products, matching how the admin panel stores product images.
 */
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const connectDB = require('./src/config/db');
const Product = require('./src/models/product.model');
const Category = require('./src/models/category.model');
const Department = require('./src/models/department.model');
const { processAndSave } = require('./src/middleware/upload');

const CHOLI_DIR = path.resolve(__dirname, '..', '..', 'choli photo');
const BASE_URL = (process.env.BASE_URL || 'http://localhost:4000').replace(/\/$/, '');
const IMAGE_EXT = /\.(png|jpe?g|jfif|webp|gif|bmp|avif|heic|heif)$/i;

// Five vibrant festive colours as decimal ARGB integer strings (opaque, alpha
// FF). The storefront detail page does Color(int.parse(value)), which only
// accepts decimal ints — hex/0x/named strings crash it. See product_colors.dart.
const COLORS = [
  '4293467747', // Rani Pink  0xFFE91E63
  '4294901760', // Red        0xFFFF0000
  '4294951175', // Marigold   0xFFFFC107
  '4281236786', // Emerald    0xFF2E7D32
  '4282339765', // Royal Blue 0xFF3F51B5
];
const SIZES = ['S', 'M', 'L', 'XL'];
const TAGS = ['navratri', 'chaniya choli', 'garba', 'lehenga', 'festive'];

// Curated names + prices (INR). Assigned to images in sorted filename order.
const CATALOG = [
  { name: 'Rani Pink Mirror-Work Chaniya Choli', price: 2799, off: 20 },
  { name: 'Wine Cotton Garba Chaniya Choli', price: 1999, off: 15 },
  { name: 'Floral Print Navratri Lehenga Choli', price: 2499, off: 10 },
  { name: 'Royal Blue Gota-Work Chaniya Choli', price: 3099, off: 25 },
  { name: 'Indo-Western Draped Lehenga Choli', price: 3299, off: 18 },
  { name: 'Emerald Green Mirror Lehenga Choli', price: 2899, off: 12 },
  { name: 'Ivory Boho Bridal Lehenga Choli', price: 3499, off: 22 },
  { name: 'Sunshine Marigold Garba Chaniya Choli', price: 1799, off: 10 },
  { name: 'Red Bandhani Navratri Chaniya Choli', price: 2299, off: 15 },
  { name: 'Peach Embroidered Lehenga Choli', price: 2599, off: 0 },
  { name: 'Teal Mirror-Work Garba Choli', price: 2199, off: 14 },
  { name: 'Magenta Thread-Work Chaniya Choli', price: 2699, off: 20 },
  { name: 'Orange Festive Lehenga Choli', price: 1899, off: 8 },
  { name: 'Purple Sequin Navratri Choli', price: 2999, off: 16 },
  { name: 'Multicolor Patola Chaniya Choli', price: 3199, off: 24 },
];

(async () => {
  if (!fs.existsSync(CHOLI_DIR)) {
    console.error(`[seed] folder not found: ${CHOLI_DIR}`);
    process.exit(1);
  }
  await connectDB();

  // 1) Ensure the "Chaniya Choli" category exists.
  let category = await Category.findOne({ Name: 'Chaniya Choli' });
  if (!category) {
    category = await Category.create({
      Name: 'Chaniya Choli',
      Department: 'Ethnic Wear',
      IsFeatured: true,
      ParentId: [],
    });
    console.log(`[seed] created category "Chaniya Choli" (${category._id})`);
  } else {
    console.log(`[seed] category "Chaniya Choli" already exists (${category._id})`);
  }

  // 2) Ensure the "Navratri" department exists (drives the home Navratri section).
  let dept = await Department.findOne({ dept_name: 'Navratri' });
  if (!dept) {
    dept = await Department.create({ dept_name: 'Navratri', last_name: '' });
    console.log(`[seed] created department "Navratri" (${dept._id})`);
  } else {
    console.log(`[seed] department "Navratri" already exists (${dept._id})`);
  }

  // 3) Gather images.
  const files = fs
    .readdirSync(CHOLI_DIR)
    .filter((f) => IMAGE_EXT.test(f))
    .sort();
  console.log(`[seed] ${files.length} image(s) found in "choli photo/".`);

  const brand = { Id: '', Name: 'OneWebMart', Image: '', IsFeatured: false };
  let created = 0;
  let skipped = 0;
  let firstThumb = '';

  for (let i = 0; i < files.length; i++) {
    const meta = CATALOG[i % CATALOG.length];
    // Keep names unique if there are more images than curated names.
    const title = i < CATALOG.length ? meta.name : `${meta.name} #${i + 1}`;

    const exists = await Product.findOne({ Title: title });
    if (exists) {
      skipped += 1;
      console.log(`  skip (exists): ${title}`);
      continue;
    }

    const buffer = fs.readFileSync(path.join(CHOLI_DIR, files[i]));
    let url;
    try {
      const saved = await processAndSave({ buffer, originalname: files[i] }, 'products', BASE_URL);
      url = saved.url;
    } catch (e) {
      console.error(`  ! could not process ${files[i]}: ${e.message}`);
      continue;
    }
    if (!firstThumb) firstThumb = url;

    await Product.create({
      SKU: `CHOLI-${String(i + 1).padStart(3, '0')}`,
      Title: title,
      Stock: 25,
      Stockvalue: 'InStock',
      Price: meta.price,
      SalePrice: meta.off, // percent discount (storefront treats SalePrice as %)
      Images: [url],
      Thumbnail: url,
      IsFeatured: i < 6, // feature the first few
      CategoryId: String(category._id),
      CategoryName: 'Chaniya Choli',
      Brand: brand,
      Description:
        `${title} — a handcrafted Navratri chaniya choli perfect for Garba and ` +
        `festive nights. Available in sizes S–XL and five vibrant colours.`,
      ProductType: 'single',
      Departmentname: 'Navratri',
      ProductAttributes: [
        { Name: 'Sizes', Values: [...SIZES] },
        { Name: 'Colors', Values: [...COLORS] },
        { Name: 'Tags', Values: [...TAGS] },
      ],
      ProductVariations: [],
      aiTryOnEnabled: true,
    });
    created += 1;
    console.log(`  + ${title}  (₹${meta.price}, ${meta.off}% off)`);
  }

  // Give the category a cover image if it has none.
  if (firstThumb && !category.Image) {
    category.Image = firstThumb;
    await category.save();
    console.log('[seed] set Chaniya Choli category cover image.');
  }

  console.log(`\n[seed] done — created ${created}, skipped ${skipped}. Category & Navratri section ready.`);
  process.exit(0);
})().catch((e) => {
  console.error('[seed] error:', e);
  process.exit(1);
});
