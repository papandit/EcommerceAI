const nodemailer = require('nodemailer');
const Settings = require('../models/settings.model');

/**
 * Best-effort order-confirmation email. Reads SMTP config from the Settings
 * singleton. If SMTP is not configured (missing host/user) it returns silently
 * without throwing — callers must never let this block/break order creation.
 */
async function sendOrderEmail(order) {
  if (!order) return;
  const to = order.email;
  if (!to) return; // no recipient → nothing to send

  const settings = await Settings.findOne();
  if (!settings) return;

  const host = settings.smtphost;
  const user = settings.smtpuser;
  const pass = settings.smtppass;
  // Require at least a host to attempt sending.
  if (!host) return;

  const port = parseInt(settings.smtpport, 10) || 587;
  const from = settings.smtpfrom || user || 'no-reply@example.com';

  const transporter = nodemailer.createTransport({
    host,
    port,
    secure: port === 465, // implicit TLS only on 465
    auth: user ? { user, pass } : undefined,
  });

  const orderRef =
    order.Orderid || (order._id ? String(order._id) : '') || '';
  const amount =
    order.totalAmount != null ? order.totalAmount : order.subtotal;

  const subject = orderRef
    ? `Order placed — ${orderRef}`
    : 'Order placed';
  const lines = [
    'Thank you for your order!',
    orderRef ? `Order ID: ${orderRef}` : null,
    amount != null ? `Total: ${amount}` : null,
    '',
    'We will notify you when it ships.',
  ].filter(Boolean);

  await transporter.sendMail({
    from,
    to,
    subject,
    text: lines.join('\n'),
  });
}

/**
 * Generic best-effort mail send. Reads SMTP from Settings; returns true if it
 * sent, false if SMTP isn't configured (no host). Throws only on real send
 * failures so callers can log them.
 */
async function sendMail({ to, subject, text }) {
  if (!to) return false;
  const settings = await Settings.findOne();
  const host = settings && settings.smtphost;
  if (!host) return false; // not configured

  const user = settings.smtpuser;
  const pass = settings.smtppass;
  const port = parseInt(settings.smtpport, 10) || 587;
  const from = settings.smtpfrom || user || 'no-reply@example.com';

  const transporter = nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: user ? { user, pass } : undefined,
  });

  await transporter.sendMail({ from, to, subject, text });
  return true;
}

module.exports = { sendOrderEmail, sendMail };
