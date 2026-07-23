/**
 * BrandShoot service — the ONLY module that knows the API key exists.
 *
 * The key spends real credits (= money), so it never leaves the server. Config
 * (base URL + key + limits) is read from the Settings singleton at call time, so
 * the admin can set/rotate it from the panel without a redeploy.
 *
 * Uses Node's global fetch (Node 18+). If you must run on Node <18, add the
 * `node-fetch` dependency and require it here.
 */
const Settings = require('../models/settings.model');

/** Tagged error so callers can show "AI not configured" cleanly. */
function notConfigured() {
  const e = new Error('BrandShoot is not configured.');
  e.status = 503;
  e.code = 'not_configured';
  return e;
}

/** Load { BASE, KEY } from Settings; throw if the key is missing. */
async function cfg() {
  const s = await Settings.findOne().lean();
  const BASE = (s && s.brandshootBase ? s.brandshootBase : '').replace(/\/$/, '');
  const KEY = s && s.brandshootKey ? s.brandshootKey : '';
  if (!BASE || !KEY) throw notConfigured();
  return { BASE, KEY };
}

/**
 * Keep the admin's view of the key in sync with reality.
 *
 * BrandShoot has no balance endpoint, so we learn from the calls we already
 * make: every response is scanned for a remaining-credit figure, and a 402
 * ("insufficient credits") flags the key as exhausted. Any successful call
 * clears that flag. Best-effort — never let this break the actual request.
 */
const CREDIT_KEYS = [
  'creditsRemaining', 'credits_remaining', 'remainingCredits', 'remaining_credits',
  'creditBalance', 'credit_balance', 'credits', 'balance',
];
const CREDIT_HEADERS = [
  'x-credits-remaining', 'x-credit-balance', 'x-credits', 'x-remaining-credits',
];

function pickNumber(obj) {
  if (!obj || typeof obj !== 'object') return null;
  for (const k of CREDIT_KEYS) {
    const v = obj[k];
    if (typeof v === 'number' && Number.isFinite(v)) return v;
  }
  return null;
}

/** Find a remaining-credit figure in a response body or headers, if present. */
function extractCredits(data, headers) {
  let n = pickNumber(data);
  if (n != null) return n;
  if (data && typeof data === 'object') {
    for (const parent of ['account', 'usage', 'meta', 'billing', 'quota']) {
      n = pickNumber(data[parent]);
      if (n != null) return n;
    }
  }
  if (headers && typeof headers.get === 'function') {
    for (const h of CREDIT_HEADERS) {
      const raw = headers.get(h);
      if (raw != null && raw !== '' && Number.isFinite(Number(raw))) return Number(raw);
    }
  }
  return null;
}

async function recordKeyStatus({ credits, depleted }) {
  try {
    const set = { brandshootCheckedAt: new Date() };
    if (credits != null) set.brandshootReportedCredits = credits;
    if (depleted != null) set.brandshootDepleted = depleted;
    await Settings.updateOne({}, { $set: set }, { upsert: true });
  } catch (_) {
    /* status tracking must never break the caller */
  }
}

/** Inspect any BrandShoot response and sync what it tells us about the key. */
async function syncFromResponse(res, data) {
  const credits = extractCredits(data, res && res.headers);
  if (res && res.status === 402) return recordKeyStatus({ credits, depleted: true });
  if (res && res.ok) return recordKeyStatus({ credits, depleted: false });
  if (credits != null) return recordKeyStatus({ credits });
}

/** BrandShoot wants RAW base64 — strip any "data:image/png;base64," prefix. */
function cleanB64(s) {
  if (!s) return s;
  return s.includes(',') ? s.split(',').pop() : s;
}

/** Our products store image URLs — fetch + base64-encode server-side. */
async function urlToB64(url) {
  if (!url) throw new Error('product has no image to send');
  const r = await fetch(url);
  if (!r.ok) throw new Error(`could not fetch product image: ${r.status}`);
  const buf = Buffer.from(await r.arrayBuffer());
  return buf.toString('base64');
}

async function post(path, body) {
  const { BASE, KEY } = await cfg();
  const r = await fetch(`${BASE}${path}`, {
    method: 'POST',
    headers: { 'X-API-Key': KEY, 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const data = await r.json().catch(() => ({}));
  await syncFromResponse(r, data); // keep the admin's key status current
  if (!r.ok) {
    const err = new Error(data.error || data.message || `BrandShoot ${r.status}`);
    err.status = r.status;
    err.body = data;
    throw err;
  }
  return data; // { jobId, feature, totalImages, scenarios? }
}

// ----- create calls -----
const startTryOn = ({ productImage, userImage, categoryId = 'Cloths' }) =>
  post('/api/v1/tryon', {
    categoryId,
    productImage: cleanB64(productImage),
    userImage: cleanB64(userImage),
  });

const startPhotoshoot = ({ productImage, modelImage, modelId, categoryId = 'Cloths' }) =>
  post('/api/v1/photoshoot', {
    categoryId,
    productImage: cleanB64(productImage),
    ...(modelImage ? { modelImage: cleanB64(modelImage) } : { modelId }),
  });

const startCatalog = ({
  productImage,
  modelImages,
  modelLabels,
  categoryId = 'Cloths',
  backgroundColor,
  backgroundLabel,
}) =>
  post('/api/v1/catalog', {
    categoryId,
    productImage: cleanB64(productImage),
    modelImages: modelImages.map(cleanB64),
    ...(modelLabels ? { modelLabels } : {}),
    ...(backgroundColor ? { backgroundColor } : {}),
    ...(backgroundLabel ? { backgroundLabel } : {}),
  });

// ----- poll -----
async function getJob(jobId) {
  const { BASE, KEY } = await cfg();
  const r = await fetch(`${BASE}/api/v1/jobs/${jobId}`, {
    headers: { 'X-API-Key': KEY },
  });
  const data = await r.json().catch(() => ({}));
  await syncFromResponse(r, data); // keep the admin's key status current
  if (!r.ok) {
    const e = new Error(data.error || `job ${r.status}`);
    e.status = r.status;
    e.body = data;
    throw e;
  }
  // turn relative "uploads/x.png" into absolute URLs the client can load
  const images = (data.images || []).map((im) => ({
    ...im,
    fullUrl: `${BASE}/${String(im.imageUrl || '').replace(/^\//, '')}`,
  }));
  return { ...data, images };
}

/** Live category list (no key needed) — populates the admin dropdown. */
async function getCategories() {
  const { BASE } = await cfg();
  const r = await fetch(`${BASE}/content/categories`);
  return r.json().catch(() => []);
}

/**
 * Preset model list (the selectable "model" cards: Indian Woman, Indian Girl…).
 * subType: 'photoshoot' (single model) or 'catalogue' (multi-pose models).
 * Returns each model with an absolute `imageFullUrl` the admin UI can render.
 */
async function getModels(subType = 'photoshoot') {
  const { BASE } = await cfg();
  const r = await fetch(`${BASE}/content/models?sub_type=${encodeURIComponent(subType)}`);
  const data = await r.json().catch(() => []);
  return (Array.isArray(data) ? data : []).map((m) => ({
    ...m,
    imageFullUrl: m.image_url
      ? `${BASE}/${String(m.image_url).replace(/^\//, '')}`
      : '',
  }));
}

/** Download a (BrandShoot) image URL to a Buffer — used for re-hosting. */
async function downloadToBuffer(url) {
  const r = await fetch(url);
  if (!r.ok) throw new Error(`could not download image: ${r.status}`);
  return Buffer.from(await r.arrayBuffer());
}

module.exports = {
  cleanB64,
  urlToB64,
  startTryOn,
  startPhotoshoot,
  startCatalog,
  getJob,
  getCategories,
  getModels,
  downloadToBuffer,
};
