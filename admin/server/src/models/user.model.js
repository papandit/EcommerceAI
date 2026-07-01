const mongoose = require('mongoose');
const { baseSchemaOptions } = require('../utils/baseSchema');

/**
 * Users — both admin and customers. Field names match the old Firestore "Users"
 * docs (capitalized) so the Flutter UserModels parse responses unchanged.
 * `passwordHash` is bcrypt; never serialized (select:false).
 */
const userSchema = new mongoose.Schema(
  {
    FirstName: { type: String, default: '' },
    LastName: { type: String, default: '' },
    UserName: { type: String, default: '' },
    Email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    PhoneNumber: { type: String, default: '' },
    ProfilePicture: { type: String, default: '' },
    Role: { type: String, default: 'user' }, // 'admin' | 'user' | 'Google_User'
    authProvider: { type: String, default: 'local' }, // 'local' | 'google'
    firebaseUid: { type: String, default: '', index: true },
    Devicetoken: { type: String, default: '' },
    Verifyotp: { type: Boolean, default: false },
    status: { type: String, default: 'active' },

    // AI try-on credits. Each try-on spends 1 credit (= real BrandShoot money).
    // `tryonCredits` is the live spendable balance; the two totals are an audit
    // trail. New users are granted `Settings.signupFreeCredits` on signup, and
    // admins can adjust balances from the panel (see utils/credits.js).
    tryonCredits: { type: Number, default: 0, min: 0 },
    creditsGrantedTotal: { type: Number, default: 0 }, // lifetime granted
    creditsConsumedTotal: { type: Number, default: 0 }, // lifetime consumed

    // Storefront keeps references to the user's cart/wishlist/address docs.
    Cartid: { type: String, default: '' },
    Wishlistid: { type: String, default: '' },
    Addresslistid: { type: String, default: '' },

    passwordHash: { type: String, default: '', select: false },

    // Password reset (OTP) — short-lived; never serialized.
    resetOtp: { type: String, default: '', select: false },
    resetOtpExpires: { type: Date, select: false },
  },
  baseSchemaOptions
);

module.exports = mongoose.model('User', userSchema, 'users');
