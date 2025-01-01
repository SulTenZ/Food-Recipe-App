const express = require('express');
const { initiateQRISPayment, verifyQRISPayment } = require('../controllers/qrisPaymentController');
const router = express.Router();

router.post('/bayar', initiateQRISPayment); // Route to initiate QRIS payment
router.post('/cek-bayar', verifyQRISPayment); // Route to verify QRIS payment

module.exports = router;