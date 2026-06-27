/**
 * Firebase Admin is used ONLY to verify Google Sign-In ID tokens coming from
 * the storefront (POST /api/auth/google-login). It is initialized lazily so the
 * backend runs fine without credentials during the admin-migration phase.
 *
 * To enable Google verification, provide ONE of:
 *   - GOOGLE_APPLICATION_CREDENTIALS=./serviceAccount.json   (path to key file), or
 *   - FIREBASE_SERVICE_ACCOUNT='{...json...}'                 (inline JSON), and
 *   - FIREBASE_PROJECT_ID=<project id>
 */
let admin = null;
let initialized = false;
let available = false;

function getAdmin() {
  if (initialized) return available ? admin : null;
  initialized = true;
  try {
    admin = require('firebase-admin');
    const projectId = process.env.FIREBASE_PROJECT_ID;
    let credential;

    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      const json = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
      credential = admin.credential.cert(json);
    } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      credential = admin.credential.applicationDefault();
    } else {
      console.warn(
        '[firebase] No service account configured — Google Sign-In verification is disabled.'
      );
      available = false;
      return null;
    }

    if (!admin.apps.length) {
      admin.initializeApp({ credential, projectId });
    }
    available = true;
    console.log('[firebase] admin initialized for Google token verification');
    return admin;
  } catch (err) {
    console.warn('[firebase] admin init failed:', err.message);
    available = false;
    return null;
  }
}

/** Verify a Google/Firebase ID token. Throws if verification is unavailable/invalid. */
async function verifyIdToken(idToken) {
  const a = getAdmin();
  if (!a) {
    const e = new Error(
      'Google Sign-In is not configured on the server (missing Firebase service account).'
    );
    e.statusCode = 501;
    throw e;
  }
  return a.auth().verifyIdToken(idToken);
}

module.exports = { getAdmin, verifyIdToken };
