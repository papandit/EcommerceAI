# BrandShoot Integration — Build Document

Integrating BrandShoot AI imagery into the clothing e-commerce site.

**Two things we are building:**

1. **Customer "Try it on"** — a button on every clothing card. Shopper uploads or takes a photo, and the product is rendered onto their photo. (BrandShoot **Try-On**, 1 credit.)
2. **Admin "Generate model photos"** — admin picks a product + a model (preset or uploaded), and BrandShoot returns the model wearing the product across poses. Admin publishes the good ones to the product gallery. (BrandShoot **Photoshoot** / **Catalog**, N credits.)

---

## 0. The one rule that drives the whole design

> The BrandShoot API key spends **real credits = real money**. Anyone who has the key can drain the account.

So:

- The key lives **only on our backend** (env var). It is **never** sent to the browser, the Flutter web build, or any client a shopper can open DevTools on.
- The browser/admin panel talks **only to our own backend**. Our backend is the only thing that holds `X-API-Key` and talks to BrandShoot.
- The product image is **looked up server-side by `productId`** — we don't let the client send arbitrary product images (that would let anyone burn credits on anything).

```
  CUSTOMER (browser / app)            OUR BACKEND  (Node/Express)            BRANDSHOOT
  ───────────────────────            ─────────────────────────────         ──────────────
  Tap "Try it on"        ─────────►  POST /api/ai/tryon                ───►  POST /api/v1/tryon
   { productId, userPhoto }           (auth + rate-limit + key)               202 { jobId }
                                       saves TryOnJob, returns jobId
  poll every 2.5s        ─────────►  GET  /api/ai/jobs/:jobId          ───►  GET  /api/v1/jobs/:id
                                       (verify owner, build full URLs)        { status, images[] }
  show result image      ◄─────────  { status, images:[fullUrl] }

  ADMIN PANEL
  ───────────
  Pick product + model   ─────────►  POST /api/admin/ai/photoshoot     ───►  POST /api/v1/photoshoot
                                      POST /api/admin/ai/catalog              POST /api/v1/catalog
  poll                   ─────────►  GET  /api/admin/ai/jobs/:jobId    ───►  GET  /api/v1/jobs/:id
  pick + publish images  ─────────►  POST /api/admin/ai/jobs/:id/save        (writes to product.aiGallery)
```

---

## 1. Environment & config

`.env` (backend only):

```env
BRANDSHOOT_BASE=https://brandshoot.onewebmart.cloud
BRANDSHOOT_KEY=bsk_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
TRYON_DAILY_LIMIT_PER_USER=5      # protect credits from abuse
TRYON_MAX_UPLOAD_BYTES=6000000    # ~6 MB
```

Never commit `.env`. If the key ever leaks, **rotate** it from the BrandShoot dashboard (the old one dies immediately).

---

## 2. Backend — BrandShoot service module

A single file that wraps all BrandShoot calls. Everything else uses this; nothing else knows the key exists.

`services/brandshoot.js`

```js
const BASE = process.env.BRANDSHOOT_BASE;
const KEY  = process.env.BRANDSHOOT_KEY;
const HEADERS = { "X-API-Key": KEY, "Content-Type": "application/json" };

// BrandShoot wants RAW base64 — strip any "data:image/png;base64," prefix.
function cleanB64(s) {
  if (!s) return s;
  return s.includes(",") ? s.split(",").pop() : s;
}

// Our products are stored as image URLs — fetch + encode server-side.
async function urlToB64(url) {
  const r = await fetch(url);
  if (!r.ok) throw new Error(`could not fetch product image: ${r.status}`);
  const buf = Buffer.from(await r.arrayBuffer());
  return buf.toString("base64");
}

async function post(path, body) {
  const r = await fetch(`${BASE}${path}`, {
    method: "POST",
    headers: HEADERS,
    body: JSON.stringify(body),
  });
  const data = await r.json().catch(() => ({}));
  if (!r.ok) {
    const err = new Error(data.error || data.message || `BrandShoot ${r.status}`);
    err.status = r.status;
    err.body = data;
    throw err;
  }
  return data; // { jobId, feature, totalImages, scenarios? }
}

// ----- create calls -----
const startTryOn = ({ productImage, userImage, categoryId = "Cloths" }) =>
  post("/api/v1/tryon", {
    categoryId,
    productImage: cleanB64(productImage),
    userImage:    cleanB64(userImage),
  });

const startPhotoshoot = ({ productImage, modelImage, modelId, categoryId = "Cloths" }) =>
  post("/api/v1/photoshoot", {
    categoryId,
    productImage: cleanB64(productImage),
    ...(modelImage ? { modelImage: cleanB64(modelImage) } : { modelId }),
  });

const startCatalog = ({ productImage, modelImages, modelLabels, categoryId = "Cloths",
                        backgroundColor, backgroundLabel }) =>
  post("/api/v1/catalog", {
    categoryId,
    productImage: cleanB64(productImage),
    modelImages: modelImages.map(cleanB64),
    ...(modelLabels ? { modelLabels } : {}),
    ...(backgroundColor ? { backgroundColor } : {}),
    ...(backgroundLabel ? { backgroundLabel } : {}),
  });

// ----- poll -----
async function getJob(jobId) {
  const r = await fetch(`${BASE}/api/v1/jobs/${jobId}`, { headers: HEADERS });
  const data = await r.json().catch(() => ({}));
  if (!r.ok) { const e = new Error(data.error || `job ${r.status}`); e.status = r.status; throw e; }
  // turn relative "uploads/x.png" into absolute URLs the client can load
  const images = (data.images || []).map((im) => ({
    ...im,
    fullUrl: `${BASE}/${im.imageUrl}`,
  }));
  return { ...data, images };
}

// fetch the live category list (no key needed) — used to populate admin dropdown
async function getCategories() {
  const r = await fetch(`${BASE}/content/categories`);
  return r.json();
}

module.exports = {
  cleanB64, urlToB64,
  startTryOn, startPhotoshoot, startCatalog,
  getJob, getCategories,
};
```

> **Note on the URL:** `imageUrl` comes back as `uploads/....png` (relative). Full URL = `BASE + "/" + imageUrl`. Don't double the slash.

---

## 3. Data model (Mongoose)

### 3.1 Product — add AI fields

```js
const aiImageSchema = new mongoose.Schema({
  fullUrl:    String,                              // stored absolute URL
  label:      String,                              // "Front pose", "Model 1", ...
  source:     { type: String, enum: ["photoshoot", "catalog"] },
  modelId:    String,
  scenarioId: String,
}, { _id: true, timestamps: true });

// inside Product schema:
aiTryOnEnabled: { type: Boolean, default: true },   // show "Try it on" on this product?
aiGallery:      [aiImageSchema],                     // admin-published model photos
```

### 3.2 TryOnJob — per-shopper, for ownership + rate limiting

```js
const tryOnJobSchema = new mongoose.Schema({
  userId:         { type: mongoose.Schema.Types.ObjectId, ref: "User", index: true },
  productId:      { type: mongoose.Schema.Types.ObjectId, ref: "Product" },
  brandshootJobId:{ type: String, index: true },
  status:         { type: String, default: "generating" },  // generating | done | error
  resultUrls:     [String],
}, { timestamps: true });
```

### 3.3 AiJob — admin photoshoot/catalog jobs

```js
const aiJobSchema = new mongoose.Schema({
  productId:      { type: mongoose.Schema.Types.ObjectId, ref: "Product", index: true },
  feature:        { type: String, enum: ["photoshoot", "catalog"] },
  brandshootJobId:{ type: String, index: true },
  status:         { type: String, default: "generating" },
  totalImages:    Number,
  images:         [{ fullUrl: String, label: String, scenarioId: String }],
  createdBy:      { type: mongoose.Schema.Types.ObjectId, ref: "User" }, // admin
}, { timestamps: true });
```

> **Important:** we **only host the URLs BrandShoot returns**. For long-term durability you can later download each `fullUrl` and re-upload it to your own storage/CDN, then store *that* URL. (See §9, optional re-hosting.)

---

## 4. Backend — Customer Try-On routes

`routes/aiTryon.js` (mount under `/api/ai`, behind shopper auth)

```js
const router = require("express").Router();
const bs = require("../services/brandshoot");
const Product = require("../models/Product");
const TryOnJob = require("../models/TryOnJob");

// --- daily rate limit per user (protects credits) ---
async function underDailyLimit(userId) {
  const since = new Date(Date.now() - 24 * 3600 * 1000);
  const count = await TryOnJob.countDocuments({ userId, createdAt: { $gte: since } });
  return count < Number(process.env.TRYON_DAILY_LIMIT_PER_USER || 5);
}

// POST /api/ai/tryon   body: { productId, userImage(base64) }
router.post("/tryon", async (req, res) => {
  try {
    const { productId, userImage } = req.body;
    if (!productId || !userImage) return res.status(400).json({ error: "productId and userImage required" });

    // size guard (base64 length ~= bytes * 1.37)
    if (userImage.length > Number(process.env.TRYON_MAX_UPLOAD_BYTES) * 1.4)
      return res.status(400).json({ error: "image too large" });

    if (!(await underDailyLimit(req.user.id)))
      return res.status(429).json({ error: "daily_try_on_limit_reached" });

    const product = await Product.findById(productId).lean();
    if (!product || !product.aiTryOnEnabled) return res.status(404).json({ error: "product not available for try-on" });

    // look the product image up server-side — never trust client for this
    const productImage = await bs.urlToB64(product.mainImageUrl);

    const job = await bs.startTryOn({ productImage, userImage, categoryId: "Cloths" });

    await TryOnJob.create({
      userId: req.user.id,
      productId,
      brandshootJobId: job.jobId,
    });

    res.json({ jobId: job.jobId, totalImages: job.totalImages });
  } catch (e) {
    handleBsError(e, res);
  }
});

// GET /api/ai/jobs/:jobId  — only the owner can poll their own job
router.get("/jobs/:jobId", async (req, res) => {
  try {
    const local = await TryOnJob.findOne({ brandshootJobId: req.params.jobId, userId: req.user.id });
    if (!local) return res.status(404).json({ error: "job not found" });

    const job = await bs.getJob(req.params.jobId);

    if (job.status === "done") {
      local.status = "done";
      local.resultUrls = job.images.map((i) => i.fullUrl);
      await local.save();
    }
    res.json({ status: job.status, images: job.images.map((i) => i.fullUrl) });
  } catch (e) {
    handleBsError(e, res);
  }
});

// shared error mapping
function handleBsError(e, res) {
  const map = {
    402: { code: "unavailable", msg: "Try-on is temporarily unavailable." }, // out of credits — don't expose to shopper
    429: { code: "busy",        msg: "We're busy right now, please try again in a moment." },
    401: { code: "unavailable", msg: "Try-on is temporarily unavailable." }, // key misconfig — alert ops
    403: { code: "unavailable", msg: "Try-on is temporarily unavailable." },
  };
  const m = map[e.status] || { code: "error", msg: "Something went wrong, please try again." };
  if ([402, 401, 403].includes(e.status)) console.error("[BrandShoot ALERT]", e.status, e.body); // ops alert / log
  res.status(e.status || 500).json({ error: m.code, message: m.msg });
}

module.exports = router;
```

---

## 5. Backend — Admin routes

`routes/adminAi.js` (mount under `/api/admin/ai`, behind **admin** auth)

```js
const router = require("express").Router();
const bs = require("../services/brandshoot");
const Product = require("../models/Product");
const AiJob = require("../models/AiJob");

// GET /api/admin/ai/categories — for the dropdown
router.get("/categories", async (_req, res) => res.json(await bs.getCategories()));

// POST /api/admin/ai/photoshoot
// body: { productId, modelId? , modelImage?(base64), categoryId }
router.post("/photoshoot", async (req, res) => {
  try {
    const { productId, modelId, modelImage, categoryId = "Cloths" } = req.body;
    if (!productId) return res.status(400).json({ error: "productId required" });
    if (!modelId && !modelImage) return res.status(400).json({ error: "modelId or modelImage required" });

    const product = await Product.findById(productId).lean();
    if (!product) return res.status(404).json({ error: "product not found" });
    const productImage = await bs.urlToB64(product.mainImageUrl);

    const job = await bs.startPhotoshoot({ productImage, modelId, modelImage, categoryId });
    const doc = await AiJob.create({
      productId, feature: "photoshoot", brandshootJobId: job.jobId,
      totalImages: job.totalImages, createdBy: req.user.id,
    });
    res.json({ jobId: job.jobId, totalImages: job.totalImages, scenarios: job.scenarios, _id: doc._id });
  } catch (e) { adminErr(e, res); }
});

// POST /api/admin/ai/catalog
// body: { productId, modelImages:[base64], modelLabels?, categoryId, backgroundColor?, backgroundLabel? }
router.post("/catalog", async (req, res) => {
  try {
    const { productId, modelImages, modelLabels, categoryId = "Cloths",
            backgroundColor, backgroundLabel } = req.body;
    if (!productId || !Array.isArray(modelImages) || !modelImages.length)
      return res.status(400).json({ error: "productId and modelImages[] required" });

    const product = await Product.findById(productId).lean();
    if (!product) return res.status(404).json({ error: "product not found" });
    const productImage = await bs.urlToB64(product.mainImageUrl);

    const job = await bs.startCatalog({ productImage, modelImages, modelLabels, categoryId, backgroundColor, backgroundLabel });
    await AiJob.create({
      productId, feature: "catalog", brandshootJobId: job.jobId,
      totalImages: job.totalImages, createdBy: req.user.id,
    });
    res.json({ jobId: job.jobId, totalImages: job.totalImages, scenarios: job.scenarios });
  } catch (e) { adminErr(e, res); }
});

// GET /api/admin/ai/jobs/:jobId — poll; caches images into AiJob when done
router.get("/jobs/:jobId", async (req, res) => {
  try {
    const job = await bs.getJob(req.params.jobId);
    if (job.status === "done") {
      await AiJob.updateOne(
        { brandshootJobId: req.params.jobId },
        { status: "done",
          images: job.images.map((i, idx) => ({
            fullUrl: i.fullUrl,
            label: (job.scenarios?.[idx]?.label) || `Image ${idx + 1}`,
            scenarioId: job.scenarios?.[idx]?.id,
          })) }
      );
    }
    res.json(job);
  } catch (e) { adminErr(e, res); }
});

// POST /api/admin/ai/jobs/:jobId/save  body: { selectedUrls:[...] }
// publish chosen images to the product gallery (these show on storefront)
router.post("/jobs/:jobId/save", async (req, res) => {
  try {
    const { selectedUrls } = req.body;
    const aiJob = await AiJob.findOne({ brandshootJobId: req.params.jobId });
    if (!aiJob) return res.status(404).json({ error: "job not found" });

    const picks = aiJob.images
      .filter((im) => selectedUrls.includes(im.fullUrl))
      .map((im) => ({ fullUrl: im.fullUrl, label: im.label, source: aiJob.feature,
                      scenarioId: im.scenarioId }));

    await Product.updateOne({ _id: aiJob.productId }, { $push: { aiGallery: { $each: picks } } });
    res.json({ added: picks.length });
  } catch (e) { adminErr(e, res); }
});

function adminErr(e, res) {
  // admin SHOULD see the real reason (credits, quota) so they can act
  const messages = {
    402: "Out of BrandShoot credits — top up the account.",
    429: e.body?.error === "quota_exceeded"
            ? "Monthly image quota reached." : "Rate limited — wait a moment.",
    401: "BrandShoot key invalid/misconfigured — check server config.",
  };
  res.status(e.status || 500).json({ error: e.message, message: messages[e.status] });
}

module.exports = router;
```

---

## 6. Frontend — Customer (React examples; Flutter notes below)

### 6.1 "Try it on" button on the product card

```jsx
function ProductCard({ product }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="product-card">
      {/* ...existing image, name, price... */}
      {product.aiTryOnEnabled && (
        <button className="tryon-btn" onClick={() => setOpen(true)}>
          ✨ Try it on
        </button>
      )}
      {open && <TryOnModal product={product} onClose={() => setOpen(false)} />}
    </div>
  );
}
```

### 6.2 Try-On modal — upload OR take photo, generate, poll, show result

```jsx
function TryOnModal({ product, onClose }) {
  const [photo, setPhoto]   = useState(null);   // base64 (no data-uri prefix)
  const [state, setState]   = useState("idle"); // idle | generating | done | error
  const [result, setResult] = useState(null);
  const [msg, setMsg]       = useState("");

  // file picker / camera both go through <input type="file">.
  // capture="user" tells phones to open the front camera directly.
  function onFile(e) {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => setPhoto(reader.result.split(",").pop()); // strip prefix
    reader.readAsDataURL(file);
  }

  async function generate() {
    try {
      setState("generating"); setMsg("Creating your look… this takes ~20–40s");
      const r = await fetch("/api/ai/tryon", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ productId: product._id, userImage: photo }),
      });
      const data = await r.json();
      if (!r.ok) { setState("error"); setMsg(data.message || "Couldn't start."); return; }
      poll(data.jobId);
    } catch { setState("error"); setMsg("Network error."); }
  }

  async function poll(jobId) {
    for (let i = 0; i < 60; i++) {                 // ~2.5 min max
      await new Promise((r) => setTimeout(r, 2500)); // 2.5s — be polite
      const r = await fetch(`/api/ai/jobs/${jobId}`, { credentials: "include" });
      const data = await r.json();
      if (r.ok && data.status === "done" && data.images?.length) {
        setResult(data.images[0]); setState("done"); return;
      }
      if (!r.ok) { setState("error"); setMsg(data.message || "Failed."); return; }
    }
    setState("error"); setMsg("Timed out — please try again.");
  }

  return (
    <div className="modal">
      <button onClick={onClose}>×</button>
      <h3>Try on: {product.name}</h3>

      {state === "idle" && (
        <>
          {/* Upload from gallery */}
          <label className="btn">
            Upload a photo
            <input type="file" accept="image/*" hidden onChange={onFile} />
          </label>
          {/* Take a photo (opens camera on mobile) */}
          <label className="btn">
            Take a photo
            <input type="file" accept="image/*" capture="user" hidden onChange={onFile} />
          </label>

          {photo && <img className="preview" src={`data:image/jpeg;base64,${photo}`} alt="you" />}
          <button disabled={!photo} onClick={generate}>Generate try-on</button>
          <p className="fine">Your photo is used only to create this image.</p>
        </>
      )}

      {state === "generating" && <div className="spinner-wrap"><Spinner /><p>{msg}</p></div>}

      {state === "done" && (
        <>
          <img className="result" src={result} alt="try-on result" />
          <a className="btn" href={result} download>Download</a>
          <button onClick={() => { setState("idle"); setPhoto(null); setResult(null); }}>
            Try another photo
          </button>
        </>
      )}

      {state === "error" && (
        <><p className="error">{msg}</p><button onClick={() => setState("idle")}>Try again</button></>
      )}
    </div>
  );
}
```

**Why `<input capture>` instead of a custom camera?** It opens the native camera on phones with zero extra code and works everywhere. If you later want an in-browser live camera preview, swap to `navigator.mediaDevices.getUserMedia` and draw a frame to a `<canvas>`, then `canvas.toDataURL()`.

---

## 7. Frontend — Admin

Add a **"Generate AI model photos"** panel on the admin product edit screen.

```jsx
function AdminAiPanel({ product }) {
  const [feature, setFeature] = useState("photoshoot"); // photoshoot | catalog
  const [modelId, setModelId] = useState("");           // preset model
  const [modelImages, setModelImages] = useState([]);   // uploaded model base64[]
  const [job, setJob] = useState(null);                 // { images, ... }
  const [state, setState] = useState("idle");
  const [picked, setPicked] = useState([]);

  async function start() {
    setState("generating");
    const endpoint = feature === "photoshoot" ? "photoshoot" : "catalog";
    const body = feature === "photoshoot"
      ? { productId: product._id, ...(modelId ? { modelId } : { modelImage: modelImages[0] }), categoryId: "Cloths" }
      : { productId: product._id, modelImages, categoryId: "Cloths", backgroundColor: "#FFFFFF" };

    const r = await fetch(`/api/admin/ai/${endpoint}`, {
      method: "POST", headers: { "Content-Type": "application/json" },
      credentials: "include", body: JSON.stringify(body),
    });
    const data = await r.json();
    if (!r.ok) { alert(data.message || data.error); setState("idle"); return; }
    poll(data.jobId);
  }

  async function poll(jobId) {
    for (let i = 0; i < 80; i++) {
      await new Promise((r) => setTimeout(r, 2500));
      const r = await fetch(`/api/admin/ai/jobs/${jobId}`, { credentials: "include" });
      const data = await r.json();
      setJob(data); // partial images may appear before "done"
      if (data.status === "done") { setState("done"); return; }
    }
    setState("idle"); alert("Timed out.");
  }

  async function publish(jobId) {
    await fetch(`/api/admin/ai/jobs/${jobId}/save`, {
      method: "POST", headers: { "Content-Type": "application/json" },
      credentials: "include", body: JSON.stringify({ selectedUrls: picked }),
    });
    alert(`Added ${picked.length} image(s) to the product gallery.`);
  }

  // ...UI: feature toggle, model preset dropdown OR upload N model photos,
  //         "Generate" button, then a grid of result images with checkboxes,
  //         and a "Publish selected to product" button.
}
```

**Admin flow in plain words:**

1. Open a product in admin.
2. Choose **Photoshoot** (one product on one model, several poses) or **Catalog** (product on multiple models).
3. Pick a **preset BrandShoot model** (`modelId`) from a dropdown, or **upload model photo(s)**.
4. Hit Generate → spinner → result grid appears (each image = 1 credit).
5. Tick the good ones → **Publish to product** → they land in `product.aiGallery`.
6. The storefront product page renders `product.aiGallery` alongside the normal photos.

> Populate the model dropdown's categories from `GET /api/admin/ai/categories` (proxied; for clothing you'll almost always use `Cloths`).

---

## 8. Storefront — showing published model photos

On the product detail page, merge `product.aiGallery[].fullUrl` into the existing image carousel. No new API calls needed — they're already stored URLs.

---

## 9. Credits, limits & safety checklist

- [ ] Key only in backend `.env`; never in any client bundle.
- [ ] All routes require auth; admin routes require **admin** role.
- [ ] Customer try-on is **rate limited per user/day** (credits = money).
- [ ] Upload size + MIME validated before forwarding.
- [ ] Product image fetched **server-side by `productId`** — client cannot pick arbitrary images.
- [ ] `402 insufficient_credits` → shopper sees a generic "temporarily unavailable"; **admin/ops** sees the real reason and an alert to top up.
- [ ] `429 quota_exceeded` → consider auto-hiding the Try-On button site-wide until the new month / quota raise.
- [ ] Poll every **2.5s**, give up after a timeout, back off on `429` (honor `Retry-After`).
- [ ] Strip `data:` prefix from every base64 before sending (the service module does this).
- [ ] **Privacy:** decide your policy for shopper photos. Simplest + safest: don't persist `userImage` at all — forward and forget. Only store the generated result URL if you need history.
- [ ] *(Optional, recommended)* **Re-host results.** BrandShoot URLs may not be permanent. For `aiGallery` images (which live forever on the storefront), download each `fullUrl` server-side and re-upload to your own storage/CDN, then store that URL instead.

---

## 10. Build order (suggested phases)

1. **Env + service module** (`services/brandshoot.js`) + `GET /api/admin/ai/categories` sanity check.
2. **Customer backend**: `POST /api/ai/tryon` + `GET /api/ai/jobs/:id` + per-user rate limit + `TryOnJob` model.
3. **Customer UI**: card button + Try-On modal (upload/camera, poll, result).
4. **Admin model + auth**: `aiGallery` on Product, `AiJob` model, admin-role guard.
5. **Admin backend**: `photoshoot`, `catalog`, job poll, `jobs/:id/save`.
6. **Admin UI**: generate panel (feature toggle, model select, result grid, publish).
7. **Storefront**: render `aiGallery` on product page.
8. **Hardening**: error mapping, credit/quota alerts, optional re-hosting, monitoring.

---

## Appendix — Flutter (web/app) mapping

If the storefront is your Flutter stack instead of React, the **entire backend above is unchanged** — only the client differs:

- **Upload/camera** → `image_picker` (`ImageSource.gallery` / `ImageSource.camera`); read bytes, `base64Encode(bytes)`.
- **HTTP + polling** → `Dio`; a `Timer.periodic` (2.5s) hitting `GET /api/ai/jobs/:id`, cancel on `done`/timeout.
- **State** → a `Riverpod` `StateNotifier` with `idle | generating | done | error`, same flow as the React `state` machine.
- **Result image** → `Image.network(fullUrl)`.
- Same rule: the Flutter web build is a client → it **must** call your backend, never BrandShoot directly.
