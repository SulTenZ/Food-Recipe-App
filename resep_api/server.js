// resep_api/server.js
const express = require('express'); // Mengimpor library express untuk membuat aplikasi web
const mongoose = require('mongoose'); // Mengimpor library mongoose untuk berinteraksi dengan MongoDB
const recipeRoutes = require('./routes/recipeRoutes'); // Mengimpor rute resep
const qrisPaymentRoutes = require('./routes/qrisPaymentRoutes'); // Mengimpor rute pembayaran QRIS
require("dotenv").config();

const app = express();

// Middleware
app.use(express.json());

// Routes
app.use('/api', recipeRoutes);

// Connect ke MongoDB
mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('Connected to MongoDB');
    app.listen(process.env.PORT, () => {
      console.log(`Server running on port ${process.env.PORT}`);
      console.log("Server Key:", process.env.MIDTRANS_SERVER_KEY);
      console.log("Client Key:", process.env.MIDTRANS_CLIENT_KEY);
    });
  })
  .catch((error) => console.log(error));

// Login
const authRoutes = require('./routes/authRoutes');

// Routes
app.use('/api', recipeRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/qris-payment', qrisPaymentRoutes);
