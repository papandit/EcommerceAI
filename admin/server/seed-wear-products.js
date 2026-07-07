/*
 * Seed Upperware (tops) + Lowerware (bottoms) products from the
 * "upperware photo/" and "lowerware photo/" folders.
 *
 *   node seed-wear-products.js        # create (idempotent — skips existing titles)
 *
 * Each image becomes one product: sizes S/M/L/XL, 5 wardrobe colours, a rotating
 * real brand, placed in an "Upperware" or "Lowerware" category (category page)
 * and alternated between the "Trending" and "Popular" home rails so both fill.
 */
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const connectDB = require('./src/config/db');
const Product = require('./src/models/product.model');
const Category = require('./src/models/category.model');
const { processAndSave } = require('./src/middleware/upload');

const ROOT = path.resolve(__dirname, '..', '..');
const BASE_URL = (process.env.BASE_URL || 'http://localhost:4000').replace(/\/$/, '');
const IMAGE_EXT = /\.(png|jpe?g|jfif|webp|gif|bmp|avif|heic|heif)$/i;

// Five versatile wardrobe colours as decimal ARGB integer strings (opaque). The
// storefront detail page does Color(int.parse(value)) — decimal ints only.
const COLORS = [
  '4278190080', // Black  0xFF000000
  '4294967295', // White  0xFFFFFFFF
  '4288585374', // Grey   0xFF9E9E9E
  '4282339765', // Navy   0xFF3F51B5
  '4291998860', // Beige  0xFFD2B48C
];
const SIZES = ['S', 'M', 'L', 'XL'];

// Rotate through real apparel brands already in the DB.
const BRANDS = [
  { Id: '6a30f54a08dc9dc22d78a878', Name: 'Sassafras', Image: '' },
  { Id: '6a30f54a08dc9dc22d78a875', Name: 'Tokyo Talkies', Image: '' },
  { Id: '6a30f54a08dc9dc22d78a872', Name: 'DressBerry', Image: '' },
  { Id: '6a30f54a08dc9dc22d78a86f', Name: 'Roadster', Image: '' },
  { Id: '6a30f54a08dc9dc22d78a86c', Name: 'Mast & Harbour', Image: '' },
  { Id: '6a30f54a08dc9dc22d78a860', Name: 'Marks & Spencer Women', Image: '' },
];

const GROUPS = [
  {
    folder: 'upperware photo',
    category: 'Upperware',
    tags: ['top', 'shirt', 'tshirt', 'casual'],
    names: [
      'Classic Red Stripe Shirt',
      'Everyday Cotton Crew Tee',
      'Cute Ruffle Crop Top',
      'Boyfriend Oversized Shirt',
      'Pastel Basic T-Shirt',
      'Chic Puff-Sleeve Blouse',
      'Casual Linen Button-Up',
      'Graphic Print Tee',
      'Off-Shoulder Summer Top',
      'Minimal White Shirt',
    ],
    prices: [699, 899, 599, 1199, 749, 1099, 1299, 649, 999, 799],
  },
  {
    folder: 'lowerware photo',
    category: 'Lowerware',
    tags: ['bottom', 'jeans', 'trouser', 'casual'],
    names: [
      'High-Waist Slim Jeans',
      'Smart Casual Trousers',
      'Pleated Midi Skirt',
      'Wide-Leg Culottes',
      'Everyday Denim Jeans',
      'Clean-Girl Tailored Pants',
    ],
    prices: [1299, 1499, 999, 1199, 899, 1699],
  },
];

const OFF = [0, 10, 15, 20]; // rotating % discount

async function ensureCategory(name) {
  let c = await Category.findOne({ Name: name });
  if (!c) {
    c = await Category.create({
      Name: name,
      Department: 'Western Wear',
      IsFeatured: true,
      ParentId: [],
    });
    console.log(`[seed] created category "${name}" (${c._id})`);
  } else {
    console.log(`[seed] category "${name}" already exists (${c._id})`);
  }
  return c;
}

(async () => {
  await connectDB();
  let gi = 0; // global counter → alternates Trending / Popular
  let created = 0;
  let skipped = 0;

  for (const g of GROUPS) {
    const dir = path.join(ROOT, g.folder);
    if (!fs.existsSync(dir)) {
      console.error(`[seed] folder not found: ${dir} — skipping`);
      continue;
    }
    const category = await ensureCategory(g.category);
    const files = fs.readdirSync(dir).filter((f) => IMAGE_EXT.test(f)).sort();
    console.log(`[seed] ${g.category}: ${files.length} image(s).`);

    let firstThumb = '';
    for (let i = 0; i < files.length; i++) {
      const title = g.names[i] || `${g.category} Style #${i + 1}`;
      if (await Product.findOne({ Title: title })) {
        skipped += 1;
        console.log(`  skip (exists): ${title}`);
        gi += 1;
        continue;
      }

      let url;
      try {
        const buffer = fs.readFileSync(path.join(dir, files[i]));
        const saved = await processAndSave({ buffer, originalname: files[i] }, 'products', BASE_URL);
        url = saved.url;
      } catch (e) {
        console.error(`  ! could not process ${files[i]}: ${e.message}`);
        gi += 1;
        continue;
      }
      if (!firstThumb) firstThumb = url;

      const brand = BRANDS[gi % BRANDS.length];
      const dept = gi % 2 === 0 ? 'Trending' : 'Popular';
      const price = g.prices[i] || 999;
      const off = OFF[gi % OFF.length];

      await Product.create({
        SKU: `${g.category.slice(0, 3).toUpperCase()}-${String(i + 1).padStart(3, '0')}`,
        Title: title,
        Stock: 30,
        Stockvalue: 'InStock',
        Price: price,
        SalePrice: off, // percent discount
        Images: [url],
        Thumbnail: url,
        IsFeatured: gi % 3 === 0,
        CategoryId: String(category._id),
        CategoryName: g.category,
        Brand: brand,
        Description:
          `${title} by ${brand.Name} — an everyday ${g.category.toLowerCase()} essential. ` +
          `Available in sizes S–XL and five colours.`,
        ProductType: 'single',
        Departmentname: dept, // "Trending" or "Popular" home rail
        ProductAttributes: [
          { Name: 'Sizes', Values: [...SIZES] },
          { Name: 'Colors', Values: [...COLORS] },
          { Name: 'Tags', Values: [...g.tags, dept.toLowerCase()] },
        ],
        ProductVariations: [],
        aiTryOnEnabled: true,
      });
      created += 1;
      console.log(`  + ${title}  (${brand.Name}, ₹${price}, ${off}% off, ${dept})`);
      gi += 1;
    }

    if (firstThumb && !category.Image) {
      category.Image = firstThumb;
      await category.save();
      console.log(`[seed] set ${g.category} category cover image.`);
    }
  }

  console.log(`\n[seed] done — created ${created}, skipped ${skipped}. Categories + Trending/Popular ready.`);
  process.exit(0);
})().catch((e) => {
  console.error('[seed] error:', e);
  process.exit(1);
});
