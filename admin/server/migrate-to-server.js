/**
 * One-shot data migration: local MongoDB  ->  live server MongoDB.
 *
 * Copies every collection from the local `ecom` database into the live
 * `e-commerce` database, rewriting any `http://localhost:4000` image/file URLs
 * to the live origin so images resolve on the deployed site.
 *
 * The destination connection string is read from an env var (never hard-coded)
 * so the credentials stay out of source control. Put it in `.env.migrate`:
 *
 *     DEST_URI=mongodb://USER:PASS@YOUR_SERVER_HOST:27017/e-commerce?authSource=admin
 *
 * Usage (from admin/server):
 *     node migrate-to-server.js            # DRY RUN — reports only, writes nothing
 *     node migrate-to-server.js --yes      # ACTUALLY migrate (drops + replaces dest collections)
 *
 * Optional env overrides:
 *     SRC_URI   (default mongodb://127.0.0.1:27017/ecom)
 *     OLD_BASE  (default http://localhost:4000)
 *     NEW_BASE  (default https://ecommai.onewebmart.cloud)
 *     ONLY      (comma list of collections to migrate; default = all)
 *     SKIP      (comma list of collections to skip)
 */
require('dotenv').config({ path: require('path').join(__dirname, '.env.migrate') });
const mongoose = require('mongoose');

const SRC_URI = process.env.SRC_URI || 'mongodb://127.0.0.1:27017/ecom';
const DEST_URI = process.env.DEST_URI || process.env.MONGODB_URI_PROD;
const OLD_BASE = process.env.OLD_BASE || 'http://localhost:4000';
const NEW_BASE = (process.env.NEW_BASE || 'https://ecommai.onewebmart.cloud').replace(/\/+$/, '');
const APPLY = process.argv.includes('--yes');
const ONLY = (process.env.ONLY || '').split(',').map((s) => s.trim()).filter(Boolean);
const SKIP = (process.env.SKIP || '').split(',').map((s) => s.trim()).filter(Boolean);

let rewrites = 0;

/** Deep-rewrite OLD_BASE -> NEW_BASE in every string the document contains. */
function rewriteUrls(value) {
  if (typeof value === 'string') {
    if (value.includes(OLD_BASE)) {
      rewrites += 1;
      return value.split(OLD_BASE).join(NEW_BASE);
    }
    return value;
  }
  if (Array.isArray(value)) return value.map(rewriteUrls);
  if (value && typeof value === 'object') {
    // Leave special BSON types (ObjectId, Date, etc.) untouched.
    if (value._bsontype || value instanceof Date) return value;
    for (const k of Object.keys(value)) value[k] = rewriteUrls(value[k]);
    return value;
  }
  return value;
}

function redact(uri) {
  return String(uri || '').replace(/\/\/([^@]+)@/, '//****:****@');
}

async function main() {
  if (!DEST_URI) {
    console.error(
      '\n[migrate] DEST_URI is not set.\n' +
        '  Create admin/server/.env.migrate with a line like:\n' +
        '  DEST_URI=mongodb://USER:PASS@YOUR_SERVER_HOST:27017/e-commerce?authSource=admin\n'
    );
    process.exit(1);
  }

  console.log(`[migrate] mode      : ${APPLY ? 'APPLY (will write)' : 'DRY RUN (no writes)'}`);
  console.log(`[migrate] source    : ${redact(SRC_URI)}`);
  console.log(`[migrate] dest      : ${redact(DEST_URI)}`);
  console.log(`[migrate] url rewrite: ${OLD_BASE}  ->  ${NEW_BASE}\n`);

  const src = await mongoose.createConnection(SRC_URI, { serverSelectionTimeoutMS: 10000 }).asPromise();
  console.log(`[migrate] connected source: ${src.host}/${src.name}`);
  const dest = await mongoose.createConnection(DEST_URI, { serverSelectionTimeoutMS: 15000 }).asPromise();
  console.log(`[migrate] connected dest  : ${dest.host}/${dest.name}\n`);

  let collections = (await src.db.listCollections().toArray())
    .map((c) => c.name)
    .filter((n) => !n.startsWith('system.'));
  if (ONLY.length) collections = collections.filter((n) => ONLY.includes(n));
  if (SKIP.length) collections = collections.filter((n) => !SKIP.includes(n));
  collections.sort();

  const summary = [];
  for (const name of collections) {
    const docs = await src.db.collection(name).find({}).toArray();
    docs.forEach(rewriteUrls);

    const destCol = dest.db.collection(name);
    const before = await destCol.countDocuments().catch(() => 0);

    if (APPLY) {
      if (before > 0) await destCol.deleteMany({}); // full replace
      if (docs.length) await destCol.insertMany(docs, { ordered: false });
      const after = await destCol.countDocuments();
      summary.push({ collection: name, copied: docs.length, destBefore: before, destAfter: after });
    } else {
      summary.push({ collection: name, copied: docs.length, destBefore: before, destAfter: '(dry)' });
    }
    console.log(`  ${APPLY ? 'migrated' : 'would copy'} ${String(docs.length).padStart(4)}  ${name}`);
  }

  console.log('\n[migrate] summary:');
  console.table(summary);
  console.log(`[migrate] total localhost->live URL rewrites: ${rewrites}`);
  if (!APPLY) {
    console.log('\n[migrate] DRY RUN complete — nothing was written.');
    console.log('[migrate] Re-run with  --yes  to perform the migration.');
  } else {
    console.log('\n[migrate] DONE. Verify at https://ecommai.onewebmart.cloud/api/products');
  }

  await src.close();
  await dest.close();
  process.exit(0);
}

main().catch((err) => {
  console.error('[migrate] FAILED:', err.message);
  process.exit(1);
});
