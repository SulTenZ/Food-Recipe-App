// resep_api/server.js
const express = require('express'); // Mengimpor library express untuk membuat aplikasi web
const mongoose = require('mongoose'); // Mengimpor library mongoose untuk berinteraksi dengan MongoDB
// const dotenv = require('dotenv'); // Mengimpor library dotenv untuk mengelola variabel lingkungan
const recipeRoutes = require('./routes/recipeRoutes'); // Mengimpor rute resep
const paymentRoutes = require('./routes/paymentRoutes');
require("dotenv").config();

// dotenv.config(); // Memuat variabel lingkungan dari file .env

const app = express(); // Membuat instance aplikasi Express

// Middleware
app.use(express.json()); // Middleware untuk mengurai JSON dari body permintaan

// Routes
app.use('/api', recipeRoutes); // Menghubungkan rute resep dengan prefiks '/api'

// Connect ke MongoDB
mongoose
  .connect(process.env.MONGODB_URI) // Menghubungkan ke MongoDB menggunakan URI dari variabel lingkungan
  .then(() => {
    console.log('Connected to MongoDB'); // Menampilkan pesan jika berhasil terhubung
    app.listen(process.env.PORT, () => { // Memulai server pada port yang ditentukan di variabel lingkungan
      console.log(`Server running on port ${process.env.PORT}`); // Menampilkan pesan bahwa server sedang berjalan
      console.log("Server Key:", process.env.MIDTRANS_SERVER_KEY);
      console.log("Client Key:", process.env.MIDTRANS_CLIENT_KEY);
    });
  })
  .catch((error) => console.log(error)); // Menangani kesalahan jika koneksi gagal

// Login

const authRoutes = require('./routes/authRoutes');

// Routes
app.use('/api', recipeRoutes);
app.use('/api/auth', authRoutes); // Menambahkan rute auth
app.use('/api/payment', paymentRoutes);
