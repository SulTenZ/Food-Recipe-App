// Mengimpor fungsi utility untuk pembayaran dan model User
const { createQRISPayment, checkPaymentStatus } = require('../utils/bayar');
const User = require('../models/userModel');

// Fungsi untuk memulai pembayaran QRIS
const initiateQRISPayment = async (req, res) => {
  const { userId } = req.body; // Mengambil userId dari request body
  const amount = parseInt(process.env.PREMIUM_AMOUNT); // Mendapatkan jumlah pembayaran dari environment variable

  try {
    // Mencari user berdasarkan userId
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Cek apakah user sudah premium
    if (user.isPremium) {
      return res.status(400).json({ message: 'User is already premium' });
    }

    // Memulai pembayaran QRIS dan mendapatkan orderId dan qrisUrl
    const { orderId, qrisUrl } = await createQRISPayment(amount);

    // Menyimpan orderId untuk keperluan tracking
    user.orderTokens.push({ token: orderId });
    await user.save();

    // Mengembalikan respons dengan orderId dan URL QRIS
    res.status(200).json({ orderId, qrisUrl });
  } catch (error) {
    console.error('QRIS payment initiation error:', error);
    res.status(500).json({ message: error.message });
  }
};

// Fungsi untuk memverifikasi status pembayaran QRIS
const verifyQRISPayment = async (req, res) => {
  const { orderId } = req.body; // Mengambil orderId dari request body
  const expectedAmount = parseInt(process.env.PREMIUM_AMOUNT); // Mendapatkan jumlah yang diharapkan dari environment variable

  try {
    // Memeriksa status pembayaran berdasarkan orderId
    const paymentStatus = await checkPaymentStatus(orderId);

    // Validasi pembayaran
    const isValidPayment = 
      (paymentStatus.transaction_status === 'capture' || 
       paymentStatus.transaction_status === 'settlement') && 
      paymentStatus.fraud_status === 'accept' &&
      parseInt(paymentStatus.gross_amount) === expectedAmount;

    if (isValidPayment) {
      // Mengubah status user menjadi premium jika pembayaran valid
      const user = await User.findOneAndUpdate(
        { 'orderTokens.token': orderId },
        { 
          isPremium: true,
          $pull: { orderTokens: { token: orderId } } // Menghapus orderId dari orderTokens
        },
        { new: true }
      );

      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }

      return res.status(200).json({ 
        message: 'Payment successful, user upgraded to premium',
        isPremium: user.isPremium,
        paymentStatus: paymentStatus.transaction_status
      });
    }

    // Jika pembayaran tidak valid, pastikan isPremium tetap false
    const user = await User.findOneAndUpdate(
      { 'orderTokens.token': orderId },
      { 
        isPremium: false, // Tetap false jika pembayaran tidak valid
        $pull: { orderTokens: { token: orderId } }
      },
      { new: true }
    );

    res.status(400).json({ 
      message: 'Invalid payment', 
      paymentStatus: paymentStatus.transaction_status,
      isPremium: false
    });
  } catch (error) {
    console.error('Payment verification error:', error);
    res.status(500).json({ message: error.message });
  }
};

// Mengekspor fungsi-fungsi ini agar dapat digunakan di file lain
module.exports = {
  initiateQRISPayment,
  verifyQRISPayment,
};
