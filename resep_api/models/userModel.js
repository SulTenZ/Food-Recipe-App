// resep_api/models/userModel.js
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

// Skema untuk user
const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: [true, 'Username is required'],
    unique: true,
    trim: true
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    trim: true
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: [6, 'Password must be at least 6 characters long']
  },
  otp: {
    type: String,
    required: false
  },
  otpExpires: {
    type: Date,
    default: null
  },
  recipe: {
    type: mongoose.Schema.Types.ObjectId,
    ref:"Recipe"
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  loginAttempts: {
    type: Number,
    default: 0
  },
  banExpires: {
    type: Date,
    default: null
  },
  tokens: [{
    token: {
      type: String,
      required: true
    }
  }],
  orderTokens: [{
    token: String,
    createdAt: { type: Date, default: Date.now }
  }],
  isPremium: {
    type: Boolean,
    default: false // Secara default, pengguna bukan premium
  },
  createdAt: {
    type: Date,
    default: Date.now  // Menyimpan waktu pembuatan user saat dokumen dibuat.
  }
});

// Middleware untuk hashing password sebelum disimpan ke database
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  next();
});

// Membuat model User berdasarkan skema yang telah ditentukan
const User = mongoose.model('User', userSchema);

module.exports = User;