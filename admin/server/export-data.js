/**
 * STEP 1 (run LOCALLY): export the local `ecom` database to portable JSON files.
 *
 * Writes one Extended-JSON file per collection into ./data-export/, rewriting any
 * http://localhost:4000 image/file URLs to the live origin so they resolve once
 * deployed. The companion import-data.js loads these on the server.
 *
 * Usage (from admin/server):  node export-data.js
 */
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const { EJSON } = require('bson');

const SRC_URI = process.env.SRC_URI || 'mongodb://127.0.0.1:27017/ecom';
const OLD_BASE = process.env.OLD_BASE || 'http://localhost:4000';
const NEW_BASE = (process.env.NEW_BASE || 'https://ecommai.onewebmart.cloud').replace(/\/+$/, '');
const OUT_DIR = path.join(__dirname, 'data-export');

let rewrites = 0;
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
    if (value._bsontype || value instanceof Date) return value;
    for (const k of Object.keys(value)) value[k] = rewriteUrls(value[k]);
    return value;
  }
  return value;
}

async function main() {
  fs.mkdirSync(OUT_DIR, { recursive: true });
  const src = await mongoose.createConnection(SRC_URI, { serverSelectionTimeoutMS: 10000 }).asPromise();
  console.log(`[export] connected: ${src.host}/${src.name}`);

  const names = (await src.db.listCollections().toArray())
    .map((c) => c.name)
    .filter((n) => !n.startsWith('system.'))
    .sort();

  const manifest = [];
  for (const name of names) {
    const docs = await src.db.collection(name).find({}).toArray();
    docs.forEach(rewriteUrls);
    fs.writeFileSync(path.join(OUT_DIR, `${name}.json`), EJSON.stringify(docs, { relaxed: false }));
    manifest.push({ collection: name, docs: docs.length });
    console.log(`  exported ${String(docs.length).padStart(4)}  ${name}`);
  }
  fs.writeFileSync(path.join(OUT_DIR, '_manifest.json'), JSON.stringify(manifest, null, 2));

  console.log(`\n[export] ${manifest.length} collections -> ${OUT_DIR}`);
  console.log(`[export] localhost->live URL rewrites: ${rewrites}`);
  await src.close();
  process.exit(0);
}

main().catch((e) => {
  console.error('[export] FAILED:', e.message);
  process.exit(1);
});
