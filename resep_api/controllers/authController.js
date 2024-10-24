// authController.js
const User = require('../models/userModel');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const crypto = require('crypto');

// Transporter untuk mengirim email
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

// Fungsi untuk mengirim OTP
const sendOTPEmail = async (email, otp) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Your OTP Code',
    text: `Your OTP code is: ${otp}`
  };

  return transporter.sendMail(mailOptions);
};

// Register
const register = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Check if user exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    // Generate OTP
    const otp = crypto.randomBytes(3).toString('hex').toUpperCase(); // OTP 6 karakter

    // Create new user
    const user = new User({ username, email, password, otp });

    // Save user
    await user.save();

    // Send OTP via email
    await sendOTPEmail(email, otp);

    res.status(201).json({
      status: 'success',
      message: 'User registered. OTP has been sent to your email.'
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Verifikasi OTP saat register
const verifyOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;

    // Cari user berdasarkan email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Cek OTP
    if (user.otp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    // Update user jadi verified
    user.isVerified = true;
    user.otp = undefined; // Hapus OTP setelah verifikasi
    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Account verified successfully.'
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Login
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Cari user berdasarkan email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Cek apakah user sudah verifikasi
    if (!user.isVerified) {
      return res.status(403).json({ message: 'Account not verified. Please verify your OTP.' });
    }

    // Cek password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Generate OTP untuk login
    const otp = crypto.randomBytes(3).toString('hex').toUpperCase();
    user.otp = otp;
    await user.save();

    // Kirim OTP via email
    await sendOTPEmail(email, otp);

    res.status(200).json({
      status: 'success',
      message: 'OTP has been sent to your email.'
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Verifikasi OTP saat login
const verifyLoginOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;

    // Cari user berdasarkan email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Cek OTP
    if (user.otp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    // Clear OTP setelah login berhasil
    user.otp = undefined;
    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Login successful.'
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  register,
  verifyOTP,
  login,
  verifyLoginOTP
};
