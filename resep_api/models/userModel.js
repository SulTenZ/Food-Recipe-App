// resep_api/models/userModel.js
const mongoose = require('mongoose');  // Mengimpor Mongoose untuk interaksi dengan MongoDB.
const bcrypt = require('bcrypt');  // Mengimpor bcrypt untuk melakukan hashing pada password.

// Skema untuk user
const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: [true, 'Username is required'],  // Field username wajib diisi.
    unique: true,  // Setiap username harus unik.
    trim: true  // Menghapus spasi di awal dan akhir username.
  },
  email: {
    type: String,
    required: [true, 'Email is required'],  // Field email wajib diisi.
    unique: true,  // Setiap email harus unik.
    trim: true  // Menghapus spasi di awal dan akhir email.
  },
  password: {
    type: String,
    required: [true, 'Password is required'],  // Field password wajib diisi.
    minlength: [6, 'Password must be at least 6 characters long']  // Minimal panjang password adalah 6 karakter.
  },
  otp: {
    type: String,
    required: false  // Field OTP tidak wajib diisi.
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
    default: false  // Secara default, akun tidak terverifikasi saat pertama kali dibuat.
  },
  loginAttempts: {
    type: Number,
    default: 0  // Jumlah percobaan login gagal awalnya di-set ke 0.
  },
  banExpires: {
    type: Date,
    default: null  // Waktu kedaluwarsa ban (blokir sementara), secara default null (tidak diblokir).
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
  if (!this.isModified('password')) return next();  // Jika password tidak diubah, lanjutkan ke proses berikutnya.
  this.password = await bcrypt.hash(this.password, 10);  // Hash password dengan bcrypt, dengan salt 10.
  next();  // Lanjutkan ke proses berikutnya.
});

// Membuat model User berdasarkan skema yang telah ditentukan
const User = mongoose.model('User', userSchema);

module.exports = User;  // Mengekspor model User agar bisa digunakan di tempat lain.