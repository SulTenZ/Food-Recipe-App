// resep_api/controllers/paymentController.js
const midtrans = require('../config/midtrans');
const User = require('../models/userModel');

const createPayment = async (req, res) => {
  const { userId } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const orderId = `order-${Date.now()}`;
    const parameter = {
      transaction_details: {
        order_id: orderId,
        gross_amount: 100000,
      },
      customer_details: {
        first_name: user.name,
        email: user.email,
      },
      credit_card: {
        secure: true,
      },
      callbacks: {
        finish: `${process.env.APP_URL}/payment/finish`,
        error: `${process.env.APP_URL}/payment/error`,
        pending: `${process.env.APP_URL}/payment/pending`,
      }
    };

    const chargeResponse = await midtrans.createTransaction(parameter);
    
    // Simpan order_id ke user untuk tracking
    user.orderTokens.push({ token: orderId });
    await user.save();

    res.status(200).json(chargeResponse);
  } catch (error) {
    console.error('Payment creation error:', error);
    res.status(500).json({ message: error.message });
  }
};

const paymentCallback = async (req, res) => {
  try {
    const { order_id, transaction_status, fraud_status } = req.body;

    // Validasi signature key untuk memastikan callback dari Midtrans
    const signatureKey = req.get('X-Midtrans-Signature');
    const isValidSignature = midtrans.isValidSignature(req.body, signatureKey);

    if (!isValidSignature) {
      return res.status(403).json({ message: 'Invalid signature' });
    }

    if (transaction_status === 'capture' && fraud_status === 'accept') {
      const user = await User.findOneAndUpdate(
        { 'orderTokens.token': order_id },
        { 
          isPremium: true,
          $pull: { orderTokens: { token: order_id } } // Hapus token setelah diproses
        },
        { new: true }
      );

      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
    }

    res.status(200).json({ status: 'ok' });
  } catch (error) {
    console.error('Callback processing error:', error);
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  createPayment,
  paymentCallback,
};