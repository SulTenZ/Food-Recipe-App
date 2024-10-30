// resep_api/controllers/authController.js
const User = require('../models/userModel');  // Mengambil model `User` dari file userModel.js untuk mengakses data pengguna di database.
const bcrypt = require('bcrypt');  // Untuk mengenkripsi password dan mencocokkannya saat login.
const nodemailer = require('nodemailer');  // Mengirimkan email untuk mengirimkan OTP ke pengguna.
const crypto = require('crypto');  // Menghasilkan kode OTP acak.

const MAX_LOGIN_ATTEMPTS = 3;  // Batas maksimum percobaan login yang salah.
const BAN_TIME = 10 * 60 * 1000;  // Durasi ban sementara dalam milidetik (10 menit).

// Membuat transporter untuk mengirim email melalui Gmail
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,  // Mengambil alamat email dari environment variables.
    pass: process.env.EMAIL_PASS   // Mengambil password email dari environment variables.
  }
});

// Fungsi untuk mengirim email OTP
const sendOTPEmail = async (email, otp) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,  // Alamat pengirim (diambil dari environment variables).
    to: email,  // Alamat tujuan (alamat email pengguna).
    subject: 'Your OTP Code',  // Judul email.
    text: `Your OTP code is: ${otp}`  // Isi email dengan kode OTP.
  };

  return transporter.sendMail(mailOptions);  // Mengirim email dan mengembalikan hasil pengiriman.
};

// Register
const register = async (req, res) => {
  try {
    const { username, email, password } = req.body;  // Mendapatkan data dari permintaan pengguna.

    // Cek apakah email sudah terdaftar
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    // Menghasilkan OTP secara acak
    const otp = crypto.randomBytes(3).toString('hex').toUpperCase();

    // Membuat pengguna baru dengan data yang diterima
    const user = new User({ username, email, password, otp });

    // Menyimpan pengguna baru di database
    await user.save();

    // Mengirim OTP ke email pengguna
    await sendOTPEmail(email, otp);

    res.status(201).json({
      status: 'success',
      message: 'User registered. OTP has been sent to your email.'
    });
  } catch (error) {
    res.status(500).json({ message: error.message });  // Menangani kesalahan dan mengembalikan pesan error.
  }
};

// Verifikasi OTP saat register
const verifyOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;  // Mendapatkan email dan OTP dari permintaan pengguna.

    // Mencari pengguna berdasarkan email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Memeriksa kecocokan OTP
    if (user.otp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    // Memperbarui status verifikasi pengguna
    user.isVerified = true;
    user.otp = undefined;  // Menghapus OTP setelah diverifikasi.
    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Account verified successfully.'
    });
  } catch (error) {
    res.status(500).json({ message: error.message });  // Menangani kesalahan dan mengembalikan pesan error.
  }
};

// Login
const login = async (req, res) => {
  try {
    const { email, password } = req.body;  // Mendapatkan email dan password dari permintaan pengguna.

    // Mencari pengguna berdasarkan email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Memeriksa apakah pengguna dalam status banned
    if (user.banExpires && user.banExpires > Date.now()) {
      const remainingTime = Math.ceil((user.banExpires - Date.now()) / 60000);
      return res.status(403).json({
        message: `Account is temporarily banned. Try again in ${remainingTime} minute(s).`
      });
    }

    // Memeriksa apakah akun pengguna sudah diverifikasi
    if (!user.isVerified) {
      return res.status(403).json({ message: 'Account not verified. Please verify your account.' });
    }

    // Memeriksa kecocokan password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      user.loginAttempts += 1;  // Menambah jumlah percobaan login yang gagal.

      // Jika login gagal mencapai batas maksimum, melakukan ban sementara
      if (user.loginAttempts >= MAX_LOGIN_ATTEMPTS) {
        user.banExpires = new Date(Date.now() + BAN_TIME);
        user.loginAttempts = 0;
      }

      await user.save();

      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Reset loginAttempts dan banExpires jika login berhasil
    user.loginAttempts = 0;
    user.banExpires = null;
    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Login successful.'
    });
  } catch (error) {
    res.status(500).json({ message: error.message });  // Menangani kesalahan dan mengembalikan pesan error.
  }
};

// Mengekspor fungsi untuk digunakan di tempat lain
module.exports = {
  register,
  verifyOTP,
  login
};