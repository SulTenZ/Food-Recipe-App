const Recipe = require('../models/recipeModel'); // Mengimpor model resep

// POST: Membuat resep baru
const createRecipe = async (req, res) => {
  try {
    const { name, ingredients, instructions } = req.body; // Mengambil data dari request body
    
    // Validasi input
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

    // Membuat dan menyimpan resep ke database
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
    // Menangani error yang terjadi
    res.status(400).json({ 
      status: "error",
      message: error.message,
      details: error.errors ? Object.values(error.errors).map(err => err.message) : []
    });
  }
};

// GET: Mengambil semua resep milik pengguna
const getRecipes = async (req, res) => {
  try {
    const recipes = await Recipe.find({ user: req.user._id }); // Hanya mengambil resep milik pengguna
    res.status(200).json(recipes); // Mengirimkan data resep sebagai respons
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET by ID: Mengambil satu resep berdasarkan ID
const getRecipeById = async (req, res) => {
  try {
    const recipe = await Recipe.findOne({ _id: req.params.id, user: req.user._id }); // Validasi ID dan pengguna
    if (!recipe) {
      return res.status(404).json({ message: 'Recipe not found' });
    }
    res.status(200).json(recipe); // Mengirimkan data resep
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// PUT: Memperbarui resep berdasarkan ID
const updateRecipe = async (req, res) => {
  try {
    const { name, ingredients, instructions } = req.body;
    const recipe = await Recipe.findByIdAndUpdate(
      req.params.id,
      { name, ingredients, instructions },
      { new: true } // Mengembalikan data terbaru setelah pembaruan
    );
    if (!recipe) {
      return res.status(404).json({ message: 'Recipe not found' });
    }
    res.status(200).json(recipe); // Mengirimkan data resep yang diperbarui
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// DELETE: Menghapus resep berdasarkan ID
const deleteRecipe = async (req, res) => {
  try {
    const recipe = await Recipe.findOneAndDelete({ _id: req.params.id, user: req.user._id }); // Validasi ID dan pengguna
    if (!recipe) {
      return res.status(404).json({ message: 'Recipe not found' });
    }
    res.status(200).json({ message: 'Recipe deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Mengekspor fungsi controller agar dapat digunakan di router
module.exports = {
  createRecipe,
  getRecipes,
  getRecipeById,
  updateRecipe,
  deleteRecipe
};
