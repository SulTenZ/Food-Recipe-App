
const { createQRISPayment, checkPaymentStatus } = require('../utils/bayar');
const User = require('../models/userModel');

const initiateQRISPayment = async (req, res) => {
  const { userId } = req.body;
  const amount = parseInt(process.env.PREMIUM_AMOUNT);

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Cek apakah user sudah premium
    if (user.isPremium) {
      return res.status(400).json({ message: 'User is already premium' });
    }

    const { orderId, qrisUrl } = await createQRISPayment(amount);

    // Simpan orderId untuk tracking
    user.orderTokens.push({ token: orderId });
    await user.save();

    res.status(200).json({ orderId, qrisUrl });
  } catch (error) {
    console.error('QRIS payment initiation error:', error);
    res.status(500).json({ message: error.message });
  }
};


const verifyQRISPayment = async (req, res) => {
    const { orderId } = req.body;
    const expectedAmount = parseInt(process.env.PREMIUM_AMOUNT);
  
    try {
      const paymentStatus = await checkPaymentStatus(orderId);
  
      // Validasi jumlah pembayaran sesuai dengan amount premium
      // Tambahkan kondisi settlement sebagai status valid
      const isValidPayment = 
        (paymentStatus.transaction_status === 'capture' || 
         paymentStatus.transaction_status === 'settlement') && 
        paymentStatus.fraud_status === 'accept' &&
        parseInt(paymentStatus.gross_amount) === expectedAmount;
  
      if (isValidPayment) {
        const user = await User.findOneAndUpdate(
          { 'orderTokens.token': orderId },
          { 
            isPremium: true, // Set isPremium menjadi true untuk status valid
            $pull: { orderTokens: { token: orderId } }
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
  

module.exports = {
  initiateQRISPayment,
  verifyQRISPayment,
};
