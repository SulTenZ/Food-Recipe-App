// authRoutes.js
const express = require('express');
const { register, verifyOTP, login, verifyLoginOTP } = require('../controllers/authController');

const router = express.Router();

// Rute untuk register
router.post('/register', register);
router.post('/verify-register', verifyOTP);

// Rute untuk login
router.post('/login', login);
router.post('/verify-login', verifyLoginOTP);

module.exports = router;
