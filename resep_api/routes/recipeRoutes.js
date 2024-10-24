// recipeRoutes.js
const express = require('express'); // Mengimpor library express untuk membuat rute
const {
  createRecipe,
  getRecipes,
  getRecipeById,
  updateRecipe,
  deleteRecipe,
} = require('../controllers/recipeController'); // Mengimpor fungsi-fungsi controller resep

const router = express.Router(); // Membuat instance router dari express

// Rute-rute CRUD (Create, Read, Update, Delete)
router.post('/recipes', createRecipe);       // Membuat resep baru
router.get('/recipes', getRecipes);          // Membaca semua resep
router.get('/recipes/:id', getRecipeById);   // Membaca satu resep berdasarkan ID
router.put('/recipes/:id', updateRecipe);    // Memperbarui resep berdasarkan ID
router.delete('/recipes/:id', deleteRecipe); // Menghapus resep berdasarkan ID

module.exports = router; // Mengekspor router agar bisa digunakan di file lain