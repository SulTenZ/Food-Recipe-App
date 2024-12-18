// resep_api/controllers/recipeController.js
const Recipe = require('../models/recipeModel'); // Mengimpor model Recipe dari file recipeModel.js

// POST data
const createRecipe = async (req, res) => {
  try {
    const { name, ingredients, instructions } = req.body;
    
    const errors = [];
    if (!name) errors.push("Name is required");
    if (!ingredients || !Array.isArray(ingredients) || ingredients.length === 0) {
      errors.push("Ingredients must be a non-empty array");
    }
    if (!instructions) errors.push("Instructions are required");

    if (errors.length > 0) {
      return res.status(400).json({ 
        status: "error",
        message: "Validation failed",
        errors: errors
      });
    }

    const recipe = new Recipe({ 
      name, 
      ingredients, 
      instructions,
      user: req.user._id // Menyimpan ID pengguna yang membuat resep
    });
    await recipe.save();
    res.status(201).json({
      status: "success",
      message: "Recipe created successfully",
      data: recipe
    });
  } catch (error) {
    res.status(400).json({ 
      status: "error",
      message: error.message,
      details: error.errors ? Object.values(error.errors).map(err => err.message) : []
    });
  }
};

// GET data
const getRecipes = async (req, res) => {
  try {
    const recipes = await Recipe.find({ user: req.user._id }); // Hanya mengambil resep yang dibuat oleh pengguna yang sedang login
    res.status(200).json(recipes);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET data by id
const getRecipeById = async (req, res) => {
  try {
    const recipe = await Recipe.findOne({ _id: req.params.id, user: req.user._id }); // Mencari resep berdasarkan ID dan pengguna
    if (!recipe) {
      return res.status(404).json({ message: 'Recipe not found' });
    }
    res.status(200).json(recipe);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// PUT data (update)
const updateRecipe = async (req, res) => { // Mendefinisikan fungsi untuk memperbarui resep
  try {
    const { name, ingredients, instructions } = req.body; // Mengambil data dari body permintaan
    const recipe = await Recipe.findByIdAndUpdate(
      req.params.id, // Mencari resep berdasarkan ID dari parameter
      { name, ingredients, instructions }, // Data baru untuk diperbarui
      { new: true } // Mengembalikan objek resep yang diperbarui
    );
    if (!recipe) { // Jika resep tidak ditemukan
      return res.status(404).json({ message: 'Recipe not found' }); // Mengembalikan pesan tidak ditemukan
    }
    res.status(200).json(recipe); // Mengembalikan resep yang diperbarui sebagai respons
  } catch (error) { // Menangani kesalahan
    res.status(400).json({ message: error.message }); // Mengembalikan pesan kesalahan
  }
};

// DEL data (delete)
const deleteRecipe = async (req, res) => {
  try {
    const recipe = await Recipe.findOneAndDelete({ _id: req.params.id, user: req.user._id }); // Mencari dan menghapus resep berdasarkan ID dan pengguna
    if (!recipe) {
      return res.status(404).json({ message: 'Recipe not found' });
    }
    res.status(200).json({ message: 'Recipe deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Export controller
module.exports = {
  createRecipe,
  getRecipes,
  getRecipeById,
  updateRecipe,
  deleteRecipe
};