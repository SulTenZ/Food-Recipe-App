// resep_api/routes/recipeRoutes.js
const express = require('express');
const {
  createRecipe,
  getRecipes,
  getRecipeById,
  updateRecipe,
  deleteRecipe,
} = require('../controllers/recipeController');
const { auth } = require('../middlewares/authMiddleware'); // Mengimpor middleware autentikasi

const router = express.Router();

// Rute-rute CRUD (Create, Read, Update, Delete) dengan middleware autentikasi
router.post('/recipes', auth, createRecipe);       // Membuat resep baru
router.get('/recipes', auth, getRecipes);          // Membaca semua resep milik pengguna
router.get('/recipes/:id', auth, getRecipeById);   // Membaca satu resep berdasarkan ID milik pengguna
router.put('/recipes/:id', auth, updateRecipe);    // Memperbarui resep berdasarkan ID milik pengguna
router.delete('/recipes/:id', auth, deleteRecipe); // Menghapus resep berdasarkan ID milik pengguna

module.exports = router; // Mengekspor router agar bisa digunakan di file lain