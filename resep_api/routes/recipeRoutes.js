// resep_api/routes/recipeRoutes.js
const express = require('express');
const {
  createRecipe,
  getRecipes,
  getRecipeById,
  updateRecipe,
  deleteRecipe,
} = require('../controllers/recipeController');
const { auth } = require('../middlewares/authMiddleware');

const router = express.Router();

// Rute-rute CRUD (Create, Read, Update, Delete) dengan middleware autentikasi
router.post('/recipes', auth, createRecipe);
router.get('/recipes', auth, getRecipes);
router.get('/recipes/:id', auth, getRecipeById);
router.put('/recipes/:id', auth, updateRecipe);
router.delete('/recipes/:id', auth, deleteRecipe);

module.exports = router;