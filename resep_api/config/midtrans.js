// resep_api/config/midtrans.js
const midtransClient = require("midtrans-client");

const midtrans = new midtransClient.Snap({
  isProduction: false,
  serverKey: process.env.MIDTRANS_SERVER_KEY,
  clientKey: process.env.MIDTRANS_CLIENT_KEY
});

// Tambahkan metode untuk mendapatkan authorization header
// midtrans.getAuthHeader = () => {
//   return {
//     'Content-Type': 'application/json',
//     'Authorization': `Basic ${Buffer.from(process.env.MIDTRANS_SERVER_KEY + ':').toString('base64')}`
//   };
// };

module.exports = midtrans;