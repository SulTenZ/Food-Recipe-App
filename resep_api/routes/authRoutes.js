// resep_api/routes/authRoutes.js
const express = require('express');
const { register, verifyOTP, login, logout, getUserProfile, forgotPassword, resetPassword, deleteUser, GetAllUsers } = require('../controllers/authController');  // Mengimpor fungsi-fungsi dari authController.
const {auth} = require('../middlewares/authMiddleware');
const router = express.Router();

// Rute untuk register
router.post('/register', register);
router.post('/verify-register', verifyOTP);

// Rute untuk login
router.post('/login', login);
router.get("/user-profile", auth, getUserProfile);

// Rute untuk ubah password
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

// Rute untuk logout
router.post('/logout', auth, logout);

// Rute untuk Delete User
router.delete('/delete-user/:id', auth, deleteUser)

// Rute untuk Menampilkan Daftar User
router.get('/user-list', auth, GetAllUsers)

module.exports = router;