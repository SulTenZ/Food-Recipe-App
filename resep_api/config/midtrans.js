// Mengimpor library Midtrans Client
const midtransClient = require("midtrans-client");

// Membuat instance Midtrans Snap Client
const midtrans = new midtransClient.Snap({
  isProduction: false, // Menentukan mode pengembangan (false berarti sandbox/test)
  serverKey: process.env.MIDTRANS_SERVER_KEY, // Mengambil server key dari environment variable
  clientKey: process.env.MIDTRANS_CLIENT_KEY  // Mengambil client key dari environment variable
});

// Mengekspor instance Midtrans agar dapat digunakan di file lain
module.exports = midtrans;
