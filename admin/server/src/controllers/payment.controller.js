const crypto = require('crypto');
const Razorpay = require('razorpay');
const Settings = require('../models/settings.model');
const { ok, fail, asyncHandler } = require('../utils/response');

/** Resolve the app origin from request headers (for Stripe redirect URLs). */
function resolveOrigin(req) {
  if (req.headers.origin) return req.headers.origin;
  const ref = req.headers.referer || req.headers.referrer;
  if (ref) {
    try {
      return new URL(ref).origin;
    } catch (_) {
      /* ignore malformed referer */
    }
  }
  return '';
}

/**
 * POST /api/payments/razorpay/order  body { amount } (rupees)
 * Creates a Razorpay order server-side using keys from Settings.
 */
const razorpayOrder = asyncHandler(async (req, res) => {
  try {
    const amount = Number((req.body || {}).amount);
    if (!amount || amount <= 0) return fail(res, 'Invalid amount', 400);

    const settings = await Settings.findOne();
    const key_id = settings && settings.razorpaykey;
    const key_secret = settings && settings.razorpaysecret;
    if (!key_id || !key_secret) return fail(res, 'Razorpay not configured', 400);

    const rzp = new Razorpay({ key_id, key_secret });
    const order = await rzp.orders.create({
      amount: Math.round(amount * 100),
      currency: 'INR',
      receipt: 'rcpt_' + Date.now(),
    });

    return ok(res, { orderId: order.id, key: key_id, amount: order.amount });
  } catch (err) {
    return fail(res, err.message || 'Failed to create Razorpay order', 400);
  }
});

/**
 * POST /api/payments/razorpay/verify
 * body { razorpay_order_id, razorpay_payment_id, razorpay_signature }
 * Verifies the HMAC signature against the Razorpay secret from Settings.
 */
const razorpayVerify = asyncHandler(async (req, res) => {
  try {
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
    } = req.body || {};

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return fail(res, 'Missing verification fields', 400);
    }

    const settings = await Settings.findOne();
    const secret = settings && settings.razorpaysecret;
    if (!secret) return fail(res, 'Razorpay not configured', 400);

    const expected = crypto
      .createHmac('sha256', secret)
      .update(razorpay_order_id + '|' + razorpay_payment_id)
      .digest('hex');

    const valid = expected === razorpay_signature;
    return ok(res, { valid });
  } catch (err) {
    return fail(res, err.message || 'Failed to verify payment', 400);
  }
});

/**
 * POST /api/payments/stripe/session  body { amount, email } (amount in rupees)
 * Creates a Stripe Checkout session using the secret key from Settings.
 */
const stripeSession = asyncHandler(async (req, res) => {
  try {
    const { amount, email, orderId } = req.body || {};
    const amt = Number(amount);
    if (!amt || amt <= 0) return fail(res, 'Invalid amount', 400);

    const settings = await Settings.findOne();
    const stripesecret = settings && settings.stripesecret;
    if (!stripesecret) return fail(res, 'Stripe not configured', 400);

    const stripe = require('stripe')(stripesecret);
    const origin = resolveOrigin(req);

    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      line_items: [
        {
          price_data: {
            currency: 'inr',
            product_data: { name: 'Order Payment' },
            unit_amount: Math.round(amt * 100),
          },
          quantity: 1,
        },
      ],
      customer_email: email || undefined,
      // Link the session to our order so the webhook can confirm payment.
      metadata: orderId ? { orderId: String(orderId) } : undefined,
      success_url: `${origin}/#/SuccessPage`,
      cancel_url: `${origin}/#/CheckoutPage`,
    });

    return ok(res, { url: session.url, id: session.id });
  } catch (err) {
    return fail(res, err.message || 'Failed to create Stripe session', 400);
  }
});

/**
 * POST /api/payments/stripe/webhook  (raw body — mounted before json parser)
 * Stripe calls this after a Checkout payment. On `checkout.session.completed`
 * it marks the linked order as paid. Signature is verified when a webhook
 * secret is configured in Settings.
 */
const stripeWebhook = async (req, res) => {
  try {
    const settings = await Settings.findOne();
    const stripesecret = settings && settings.stripesecret;
    if (!stripesecret) return res.status(200).json({ received: true });

    const stripe = require('stripe')(stripesecret);
    const whSecret = settings && settings.stripewebhooksecret;

    let event;
    if (whSecret) {
      const sig = req.headers['stripe-signature'];
      try {
        event = stripe.webhooks.constructEvent(req.body, sig, whSecret);
      } catch (err) {
        return res.status(400).send(`Webhook signature error: ${err.message}`);
      }
    } else {
      // No webhook secret configured — parse without verification (dev mode).
      event = typeof req.body === 'string' || Buffer.isBuffer(req.body)
        ? JSON.parse(req.body.toString())
        : req.body;
    }

    if (event && event.type === 'checkout.session.completed') {
      const orderId =
        event.data && event.data.object && event.data.object.metadata
          ? event.data.object.metadata.orderId
          : null;
      if (orderId) {
        const Order = require('../models/order.model');
        await Order.findByIdAndUpdate(orderId, {
          paymentStatus: 'paid',
          status: 'processing',
        }).catch(() => {});
      }
    }

    return res.status(200).json({ received: true });
  } catch (err) {
    return res.status(200).json({ received: true });
  }
};

module.exports = { razorpayOrder, razorpayVerify, stripeSession, stripeWebhook };
