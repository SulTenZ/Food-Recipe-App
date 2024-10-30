// resep_api/controllers/recipeController.js
const Recipe = require('../models/recipeModel'); // Mengimpor model Recipe dari file recipeModel.js

// POST data
const createRecipe = async (req, res) => { // Mendefinisikan fungsi untuk membuat resep baru
    try {
      const { name, ingredients, instructions } = req.body; // Mengambil data nama, bahan, dan instruksi dari body permintaan
      
      // Validasi manual
      const errors = []; // Menyimpan kesalahan validasi
      if (!name) errors.push("Name is required"); // Memeriksa apakah nama ada
      if (!ingredients || !Array.isArray(ingredients) || ingredients.length === 0) {
        errors.push("Ingredients must be a non-empty array"); // Memeriksa apakah bahan adalah array non-kosong
      }
      if (!instructions) errors.push("Instructions are required"); // Memeriksa apakah instruksi ada
  
      if (errors.length > 0) { // Jika ada kesalahan validasi
        return res.status(400).json({ 
          status: "error",
          message: "Validation failed",
          errors: errors // Mengembalikan kesalahan sebagai respons
        });
      }
  
      const recipe = new Recipe({ name, ingredients, instructions }); // Membuat objek resep baru
      await recipe.save(); // Menyimpan resep ke database
      res.status(201).json({
        status: "success",
        message: "Recipe created successfully",
        data: recipe // Mengembalikan resep yang dibuat
      });
    } catch (error) { // Menangani kesalahan
      res.status(400).json({ 
        status: "error",
        message: error.message,
        details: error.errors ? Object.values(error.errors).map(err => err.message) : [] // Mengembalikan detail kesalahan
      });
    }
  };

// GET data
const getRecipes = async (req, res) => { // Mendefinisikan fungsi untuk mendapatkan semua resep
  try {
    const recipes = await Recipe.find(); // Mengambil semua resep dari database
    res.status(200).json(recipes); // Mengembalikan daftar resep sebagai respons
  } catch (error) { // Menangani kesalahan
    res.status(500).json({ message: error.message }); // Mengembalikan pesan kesalahan
  }
};

// GET data by id
const getRecipeById = async (req, res) => { // Mendefinisikan fungsi untuk mendapatkan resep berdasarkan ID
  try {
    const recipe = await Recipe.findById(req.params.id); // Mencari resep dengan ID dari parameter
    if (!recipe) { // Jika resep tidak ditemukan
      return res.status(404).json({ message: 'Recipe not found' }); // Mengembalikan pesan tidak ditemukan
    }
    res.status(200).json(recipe); // Mengembalikan resep yang ditemukan sebagai respons
  } catch (error) { // Menangani kesalahan
    res.status(500).json({ message: error.message }); // Mengembalikan pesan kesalahan
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
const deleteRecipe = async (req, res) => { // Mendefinisikan fungsi untuk menghapus resep
  try {
    const recipe = await Recipe.findByIdAndDelete(req.params.id); // Mencari dan menghapus resep berdasarkan ID dari parameter
    if (!recipe) { // Jika resep tidak ditemukan
      return res.status(404).json({ message: 'Recipe not found' }); // Mengembalikan pesan tidak ditemukan
    }
    res.status(200).json({ message: 'Recipe deleted successfully' }); // Mengembalikan pesan berhasil menghapus
  } catch (error) { // Menangani kesalahan
    res.status(500).json({ message: error.message }); // Mengembalikan pesan kesalahan
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