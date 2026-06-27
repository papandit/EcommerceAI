/* Seed departments, categories, and brands. Idempotent (skips existing names).
   Run with: node src/utils/seedCatalog.js   (from admin/server) */
require('dotenv').config();
const connectDB = require('../config/db');
const Department = require('../models/department.model');
const Category = require('../models/category.model');
const Brand = require('../models/brand.model');

const departments = [
  'Women',
  'Ethnic Wear',
  'Western Wear',
  'Plus Size',
  'Maternity Wear',
  'Activewear',
  'Lingerie & Sleepwear',
  'Footwear',
  'Bags & Accessories',
  'Jewellery',
  'Beauty & Personal Care',
];

const categories = [
  { name: 'Sarees', department: 'Ethnic Wear' },
  { name: 'Kurtis', department: 'Ethnic Wear' },
  { name: 'Salwar Suits', department: 'Ethnic Wear' },
  { name: 'Lehengas', department: 'Ethnic Wear' },
  { name: 'Dresses', department: 'Western Wear' },
  { name: 'Tops', department: 'Western Wear' },
  { name: 'T-Shirts', department: 'Western Wear' },
  { name: 'Shirts', department: 'Western Wear' },
  { name: 'Jeans', department: 'Western Wear' },
  { name: 'Trousers', department: 'Western Wear' },
  { name: 'Skirts', department: 'Western Wear' },
  { name: 'Jumpsuits', department: 'Western Wear' },
  { name: 'Sports Bras', department: 'Activewear' },
  { name: 'Leggings', department: 'Activewear' },
  { name: 'Tracksuits', department: 'Activewear' },
  { name: 'Night Suits', department: 'Lingerie & Sleepwear' },
  { name: 'Bras', department: 'Lingerie & Sleepwear' },
  { name: 'Panties', department: 'Lingerie & Sleepwear' },
  { name: 'Heels', department: 'Footwear' },
  { name: 'Flats', department: 'Footwear' },
  { name: 'Sneakers', department: 'Footwear' },
  { name: 'Handbags', department: 'Bags & Accessories' },
  { name: 'Wallets', department: 'Bags & Accessories' },
  { name: 'Sunglasses', department: 'Bags & Accessories' },
  { name: 'Earrings', department: 'Jewellery' },
  { name: 'Necklaces', department: 'Jewellery' },
  { name: 'Bracelets', department: 'Jewellery' },
];

const brands = [
  'Zara', 'H&M', 'Forever 21', 'ONLY', 'Vero Moda', 'Biba', 'W', 'Aurelia',
  'Libas', 'Global Desi', 'Fabindia', 'AND', 'Allen Solly Women',
  'Van Heusen Woman', "Levi's", 'Pepe Jeans', 'Nike Women', 'Adidas Women',
  'Puma Women', 'Clovia', 'Zivame', 'Marks & Spencer Women', 'Lavie',
  'Caprese', 'Baggit', 'Mast & Harbour', 'Roadster', 'DressBerry',
  'Tokyo Talkies', 'Sassafras',
];

async function upsertByName(Model, field, value, extra = {}) {
  const existing = await Model.findOne({ [field]: value });
  if (existing) return { created: false };
  await Model.create({ [field]: value, ...extra });
  return { created: true };
}

(async () => {
  await connectDB();
  let d = 0, c = 0, b = 0;

  for (const name of departments) {
    const r = await upsertByName(Department, 'dept_name', name);
    if (r.created) d++;
  }
  for (const cat of categories) {
    const r = await upsertByName(Category, 'Name', cat.name, {
      Department: cat.department,
      Image: '',
      IsFeatured: false,
      ParentId: [],
    });
    if (r.created) c++;
  }
  for (const name of brands) {
    const r = await upsertByName(Brand, 'Name', name, {
      Image: '',
      IsFeatured: false,
      ProductsCount: 0,
    });
    if (r.created) b++;
  }

  console.log(`[seed] departments +${d}, categories +${c}, brands +${b}`);
  console.log(
    `[seed] totals: departments=${await Department.countDocuments()}, ` +
      `categories=${await Category.countDocuments()}, brands=${await Brand.countDocuments()}`
  );
  process.exit(0);
})().catch((e) => {
  console.error('[seed] error:', e);
  process.exit(1);
});
