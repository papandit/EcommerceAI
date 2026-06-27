/* Seed (or update) an admin user. Run with: npm run seed */
require('dotenv').config();
const bcrypt = require('bcryptjs');
const connectDB = require('../config/db');
const User = require('../models/user.model');

(async () => {
  await connectDB();
  const email = (process.env.SEED_ADMIN_EMAIL || 'admin@ecom.com').toLowerCase();
  const password = process.env.SEED_ADMIN_PASSWORD || 'admin123';
  const name = process.env.SEED_ADMIN_NAME || 'App Admin';

  const passwordHash = await bcrypt.hash(password, 10);
  const existing = await User.findOne({ Email: email });
  if (existing) {
    existing.passwordHash = passwordHash;
    existing.Role = 'admin';
    existing.status = 'active';
    existing.Verifyotp = true;
    if (!existing.FirstName) existing.FirstName = name;
    await existing.save();
    console.log(`[seed] updated admin: ${email} / ${password}`);
  } else {
    await User.create({
      Email: email,
      passwordHash,
      FirstName: name,
      Role: 'admin',
      authProvider: 'local',
      status: 'active',
      Verifyotp: true,
    });
    console.log(`[seed] created admin: ${email} / ${password}`);
  }
  process.exit(0);
})().catch((e) => {
  console.error('[seed] error:', e);
  process.exit(1);
});
