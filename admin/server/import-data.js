/**
 * STEP 2 (run ON THE SERVER, inside admin/server): import the exported JSON files
 * into the live database.
 *
 * It reads the destination connection string from the server's OWN environment
 * (the same MONGODB_URI the backend already uses) — so no credentials need to be
 * shared or typed anywhere new. It full-replaces each collection.
 *
 * Usage (on the server, from admin/server):
 *     node import-data.js            # DRY RUN — reports only, writes nothing
 *     node import-data.js --yes      # ACTUALLY import (drops + replaces collections)
 *
 * Optional: DEST_URI env var overrides MONGODB_URI if you want a different target.
 */
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const { EJSON } = require('bson');

const DEST_URI = process.env.DEST_URI || process.env.MONGODB_URI;
const APPLY = process.argv.includes('--yes');
const DATA_DIR = path.join(__dirname, 'data-export');

function redact(uri) {
  return String(uri || '').replace(/\/\/([^@]+)@/, '//****:****@');
}

async function main() {
  if (!DEST_URI) {
    console.error('[import] No MONGODB_URI / DEST_URI in environment. Aborting.');
    process.exit(1);
  }
  if (!fs.existsSync(DATA_DIR)) {
    console.error(`[import] data-export folder not found at ${DATA_DIR}. Did you upload it?`);
    process.exit(1);
  }

  const files = fs.readdirSync(DATA_DIR).filter((f) => f.endsWith('.json') && f !== '_manifest.json');
  console.log(`[import] mode : ${APPLY ? 'APPLY (will write)' : 'DRY RUN (no writes)'}`);
  console.log(`[import] dest : ${redact(DEST_URI)}`);
  console.log(`[import] files: ${files.length} collections from ${DATA_DIR}\n`);

  const dest = await mongoose.createConnection(DEST_URI, { serverSelectionTimeoutMS: 15000 }).asPromise();
  console.log(`[import] connected: ${dest.host}/${dest.name}\n`);

  const summary = [];
  for (const file of files.sort()) {
    const name = path.basename(file, '.json');
    const docs = EJSON.parse(fs.readFileSync(path.join(DATA_DIR, file), 'utf8'));
    const col = dest.db.collection(name);
    const before = await col.countDocuments().catch(() => 0);

    if (APPLY) {
      if (before > 0) await col.deleteMany({});
      if (docs.length) await col.insertMany(docs, { ordered: false });
      const after = await col.countDocuments();
      summary.push({ collection: name, imported: docs.length, before, after });
    } else {
      summary.push({ collection: name, imported: docs.length, before, after: '(dry)' });
    }
    console.log(`  ${APPLY ? 'imported' : 'would import'} ${String(docs.length).padStart(4)}  ${name}`);
  }

  console.log('\n[import] summary:');
  console.table(summary);
  if (!APPLY) {
    console.log('\n[import] DRY RUN complete — nothing written. Re-run with  --yes  to import.');
  } else {
    console.log('\n[import] DONE. Verify: curl https://ecommai.onewebmart.cloud/api/products');
  }
  await dest.close();
  process.exit(0);
}

main().catch((e) => {
  console.error('[import] FAILED:', e.message);
  process.exit(1);
});
