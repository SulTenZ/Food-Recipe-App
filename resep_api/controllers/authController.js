// Mengimpor model User dan berbagai library yang diperlukan
const User = require('../models/userModel');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');

// Mendefinisikan batas login maksimum dan waktu ban sementara
const MAX_LOGIN_ATTEMPTS = 3;
const BAN_TIME = 10 * 60 * 1000;

// Konfigurasi transporter untuk mengirim email menggunakan Gmail
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER, // Email pengirim diambil dari environment variable
    pass: process.env.EMAIL_PASS  // Password email pengirim
  }
});

// Fungsi untuk mengirim OTP melalui email
const sendOTPEmail = async (email, otp) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Your OTP Code',
    text: `Your OTP code is: ${otp}`
  };

  return transporter.sendMail(mailOptions);
};

// Fungsi register untuk mendaftarkan pengguna baru
const register = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Cek apakah email sudah terdaftar
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    // Menghasilkan OTP acak
    const otp = crypto.randomBytes(3).toString('hex').toUpperCase();

    // Membuat pengguna baru
    const user = new User({ username, email, password, otp });

    // Menyimpan pengguna di database
    await user.save();

    // Mengirim OTP ke email pengguna
    await sendOTPEmail(email, otp);

    res.status(201).json({
      status: 'success',
      message: 'User registered. OTP has been sent to your email.'
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Fungsi untuk memverifikasi OTP
const verifyOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;

    // Mencari pengguna berdasarkan email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Memeriksa kecocokan OTP
    if (user.otp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    // Memperbarui status pengguna
    user.isVerified = true;
    user.otp = undefined;
    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Account verified successfully.'
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Fungsi untuk menghasilkan token JWT
const generateAuthToken = async (user) => {
  const token = jwt.sign(
    { 
      _id: user._id.toString(), 
      email: user.email 
    }, 
    process.env.JWT_SECRET, 
    { expiresIn: '1h' }
  );

  // Simpan token di array tokens user
  user.tokens = user.tokens.concat({ token });
  await user.save();

  return token;
};

// Fungsi login
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Mencari pengguna berdasarkan email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Memeriksa status ban pengguna
    if (user.banExpires && user.banExpires > Date.now()) {
      const remainingTime = Math.ceil((user.banExpires - Date.now()) / 60000);
      return res.status(403).json({
        message: `Account is temporarily banned. Try again in ${remainingTime} minute(s).`
      });
    }

    // Memeriksa apakah akun sudah diverifikasi
    if (!user.isVerified) {
      return res.status(403).json({ message: 'Account not verified. Please verify your account.' });
    }

    // Memeriksa kecocokan password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      user.loginAttempts += 1;

      // Jika login gagal mencapai batas maksimum, ban sementara
      if (user.loginAttempts >= MAX_LOGIN_ATTEMPTS) {
        user.banExpires = new Date(Date.now() + BAN_TIME);
        user.loginAttempts = 0;
      }

      await user.save();
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Reset loginAttempts dan banExpires jika berhasil login
    user.loginAttempts = 0;
    user.banExpires = null;
    await user.save();

    // Generate token
    const token = await generateAuthToken(user);

    res.status(200).json({
      status: 'success',
      message: 'Login successful.',
      token: token,
      userId: user._id
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Fungsi untuk proses lupa password
const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    // Mencari pengguna berdasarkan email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Menghasilkan OTP untuk reset password
    const otp = crypto.randomBytes(4).toString('hex').toUpperCase();
    const otpExpires = Date.now() + 15 * 60 * 1000;

    user.otp = otp;
    user.otpExpires = otpExpires;
    await user.save();

    // Mengirimkan email dengan OTP
    await sendOTPEmail(email, otp);

    res.status(200).json({
      status: 'success',
      message: 'Password reset OTP has been sent to your email.',
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error during password reset process' });
  }
};

// Fungsi untuk mereset password pengguna
const resetPassword = async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;

    const user = await User.findOne({ 
      email,
      otp,
      otpExpires: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({ 
        message: 'Invalid or expired OTP. Please request a new OTP.' 
      });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({ 
        message: 'Password must be at least 8 characters long' 
      });
    }

    user.password = newPassword;
    user.otp = undefined;
    user.otpExpires = undefined;
    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Password has been reset successfully.',
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error during password reset' });
  }
};

// Fungsi untuk logout
const logout = async (req, res) => {
  try {
    req.user.tokens = req.user.tokens.filter((token) => {
      return token.token !== req.token;
    });

    await req.user.save();

    res.status(200).json({ 
      status: 'success', 
      message: 'Logged out successfully' 
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Fungsi untuk mendapatkan profil pengguna
const getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select(
      "username email isPremium phone isVerified createdAt",
    );
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

// Fungsi untuk menghapus akun pengguna
const deleteUser = async (req, res) => {
  const { id } = req.params;
  try {
    const user = await User.findByIdAndDelete(id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.status(200).json({ message: "User berhasil dihapus" });
  } catch (error) {
    res.status(500).json({ message: "Internal server error" });
  }
};

// Fungsi untuk mendapatkan daftar semua pengguna
const GetAllUsers = async (req, res) => {
  try {
    const user = await User.find({});
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: "Internal server error" });
  }
};

// Mengekspor semua fungsi agar dapat digunakan di file lain
module.exports = {
  register,
  verifyOTP,
  login,
  logout,
  getUserProfile,
  forgotPassword,
  resetPassword,
  deleteUser,
  GetAllUsers
};
