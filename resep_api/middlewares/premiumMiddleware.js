// resep_api/middlewares/premiumMiddleware.js
const User = require('../models/userModel');

const isPremium = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id); // Ambil pengguna dari request
    if (!user || !user.isPremium) {
      return res.status(403).json({ message: 'Access denied. Premium membership required.' });
    }
    next(); // Lanjutkan ke rute berikutnya jika pengguna premium
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { isPremium };