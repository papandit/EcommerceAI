require('dotenv').config();
const path = require('path');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const connectDB = require('./config/db');
const apiRoutes = require('./routes');
const { apiLimiter } = require('./middleware/rateLimit');
const { notFound, errorHandler } = require('./middleware/error');
const { UPLOAD_ROOT } = require('./middleware/upload');

const app = express();
const PORT = process.env.PORT || 4000;

// --- Security & parsing ---
app.use(
  helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' }, // allow images to load cross-origin
  })
);

const origins = (process.env.CORS_ORIGINS || '*').split(',').map((s) => s.trim());
app.use(
  cors({
    origin: origins.includes('*') ? true : origins,
    credentials: true,
  })
);

// Stripe webhook needs the RAW request body for signature verification, so it
// must be registered before the JSON body parser below.
app.post(
  '/api/payments/stripe/webhook',
  express.raw({ type: 'application/json' }),
  require('./controllers/payment.controller').stripeWebhook
);

// 15mb so AI try-on/photoshoot base64 photos aren't rejected here before the
// route handlers run (the AI controllers still enforce the real per-image cap).
app.use(express.json({ limit: '15mb' }));
app.use(express.urlencoded({ extended: true, limit: '15mb' }));
if (process.env.NODE_ENV !== 'production') app.use(morgan('dev'));

// --- Static uploads (served at /uploads/...) ---
app.use(
  '/uploads',
  express.static(UPLOAD_ROOT, {
    maxAge: '7d',
    setHeaders: (res) => res.set('Access-Control-Allow-Origin', '*'),
  })
);

// --- Health ---
app.get('/api/health', (_req, res) =>
  res.json({ success: true, message: 'ok', data: { uptime: process.uptime() } })
);

// --- API ---
app.use('/api', apiLimiter, apiRoutes);

// --- 404 + errors ---
app.use(notFound);
app.use(errorHandler);

connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`[server] listening on http://localhost:${PORT}`);
    console.log(`[server] uploads served from ${UPLOAD_ROOT} at /uploads`);
  });
});

module.exports = app;
