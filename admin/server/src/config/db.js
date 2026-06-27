const mongoose = require('mongoose');

/**
 * Connect to MongoDB. Reads MONGODB_URI from env (local dev defaults to
 * mongodb://127.0.0.1:27017/ecom). Exits the process on a hard failure so
 * the server doesn't run without a database.
 */
async function connectDB() {
  const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/ecom';
  mongoose.set('strictQuery', true);
  try {
    await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 10000,
    });
    console.log(`[db] connected: ${mongoose.connection.host}/${mongoose.connection.name}`);
  } catch (err) {
    console.error('[db] connection error:', err.message);
    process.exit(1);
  }

  mongoose.connection.on('disconnected', () =>
    console.warn('[db] disconnected')
  );
}

module.exports = connectDB;
