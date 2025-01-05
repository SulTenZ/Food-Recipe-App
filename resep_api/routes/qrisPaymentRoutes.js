// resep_api/routes/qrisPaymentRoutes.js
const express = require('express');
const { initiateQRISPayment, verifyQRISPayment } = require('../controllers/qrisPaymentController');
const router = express.Router();

router.post('/bayar', initiateQRISPayment);
router.post('/cek-bayar', verifyQRISPayment);

module.exports = router;