// resep_api/controllers/authController.js
const User = require('../models/userModel');  // Mengambil model `User` dari file userModel.js untuk mengakses data pengguna di database.
const bcrypt = require('bcrypt');  // Untuk mengenkripsi password dan mencocokkannya saat login.
const nodemailer = require('nodemailer');  // Mengirimkan email untuk mengirimkan OTP ke pengguna.
const crypto = require('crypto');  // Menghasilkan kode OTP acak.
const jwt = require('jsonwebtoken');

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

// Fungsi generate token JWT
const generateAuthToken = async (user) => {
  const token = jwt.sign(
    { 
      _id: user._id.toString(), 
      email: user.email 
    }, 
    process.env.JWT_SECRET, 
    { expiresIn: '1h' }
  );

  // Simpan token ke dalam array tokens user
  user.tokens = user.tokens.concat({ token });
  await user.save();

  return token;
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

    // Generate token
    const token = await generateAuthToken(user);
    
    console.log(token)
    console.log('Server Key:', process.env.MIDTRANS_SERVER_KEY);
    console.log('Client Key:', process.env.MIDTRANS_CLIENT_KEY);


    res.status(200).json({
      status: 'success',
      message: 'Login successful.',
      token: token,
      userId: user._id
    });
  } catch (error) {
    res.status(500).json({ message: error.message });  // Menangani kesalahan dan mengembalikan pesan error.
  }
};

// Forgot Password
const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    // Cari pengguna berdasarkan email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Generate OTP yang lebih kompleks
    const otp = crypto.randomBytes(4).toString('hex').toUpperCase();
    const otpExpires = Date.now() + 15 * 60 * 1000; // OTP berlaku 15 menit

    // Update user dengan OTP dan waktu kedaluwarsa
    user.otp = otp;
    user.otpExpires = otpExpires;
    await user.save();

    // Kirim email dengan OTP
    await sendOTPEmail(email, otp);

    res.status(200).json({
      status: 'success',
      message: 'Password reset OTP has been sent to your email.',
    });
  } catch (error) {
    console.error('Forgot Password Error:', error);
    res.status(500).json({ message: 'Server error during password reset process' });
  }
};

// Reset Password
const resetPassword = async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;

    // Cari pengguna berdasarkan email
    const user = await User.findOne({ 
      email,
      otp,
      otpExpires: { $gt: Date.now() } // Periksa apakah OTP masih berlaku
    });

    if (!user) {
      return res.status(400).json({ 
        message: 'Invalid or expired OTP. Please request a new OTP.' 
      });
    }

    // Validasi kekuatan password (contoh sederhana)
    if (newPassword.length < 8) {
      return res.status(400).json({ 
        message: 'Password must be at least 8 characters long' 
      });
    }

    // Update password
    user.password = newPassword; // Akan di-hash oleh middleware pre-save
    user.otp = undefined;
    user.otpExpires = undefined;
    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Password has been reset successfully.',
    });
  } catch (error) {
    console.error('Reset Password Error:', error);
    res.status(500).json({ message: 'Server error during password reset' });
  }
};

// Logout
const logout = async (req, res) => {
  try {
    // Hapus token saat ini dari array tokens
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
    console.error("Error fetching user profile:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// Delete Account
const deleteUser = async (req, res) => {
  const {id} = req.params;
  try {
    const user = await User.findByIdAndDelete(id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
      
    }
    res.status(200).json({message: "User berhasil dihapus" });
  } catch (error) {
    res.status(500).json({ message: "Internal server error"});
  }

}

// GetAllUsers
const GetAllUsers = async (req,res) => {
  try {
    const user = await User.find({});
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: "Internal server error"});
    console.error('error mengambil data user:', error);
  }
}

// Mengekspor fungsi untuk digunakan di tempat lain
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