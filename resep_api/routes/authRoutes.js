// resep_api/routes/authRoutes.js
const express = require('express');  // Mengimpor express untuk membuat router.
const { register, verifyOTP, login, logout } = require('../controllers/authController');  // Mengimpor fungsi-fungsi dari authController.
const {auth} = require('../middlewares/authMiddleware');
const router = express.Router();  // Membuat instance router dari express.

// Rute untuk register
router.post('/register', register);  // Rute POST untuk pendaftaran pengguna baru.
router.post('/verify-register', verifyOTP);  // Rute POST untuk verifikasi OTP saat registrasi.

// Rute untuk login
router.post('/login', login);  // Rute POST untuk login pengguna.

// Rute untuk Logout
router.post('/logout', auth, logout);

module.exports = router;  // Mengekspor router agar dapat digunakan di file utama aplikasi.