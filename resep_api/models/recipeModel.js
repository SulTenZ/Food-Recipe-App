// resep_api/models/recipeModel.js
const mongoose = require('mongoose'); // Mengimpor library mongoose untuk berinteraksi dengan MongoDB

// Mendefinisikan skema untuk model resep
const recipeSchema = new mongoose.Schema({
  name: { 
    type: String, // Tipe data untuk nama resep
    required: [true, 'Recipe name is required'], // Validasi untuk memastikan nama resep ada
    trim: true, // Menghapus spasi di awal dan akhir
    minlength: [3, 'Name must be at least 3 characters long'] // Validasi panjang minimum nama
  },
  ingredients: { 
    type: [String], // Tipe data untuk daftar bahan
    required: [true, 'At least one ingredient is required'], // Validasi untuk memastikan ada setidaknya satu bahan
    validate: {
      validator: function(v) { // Fungsi validasi untuk memeriksa apakah array bahan tidak kosong
        return v && v.length > 0; // Mengembalikan true jika ada bahan
      },
      message: 'Recipe must have at least one ingredient' // Pesan kesalahan jika validasi gagal
    }
  },
  instructions: { 
    type: String, // Tipe data untuk instruksi memasak
    required: [true, 'Cooking instructions are required'], // Validasi untuk memastikan instruksi ada
    minlength: [10, 'Instructions must be at least 10 characters long'] // Validasi panjang minimum instruksi
  },
  createdAt: { 
    type: Date, // Tipe data untuk tanggal pembuatan
    default: Date.now // Mengatur nilai default ke waktu saat ini
  },
  user: { // Menambahkan field user
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User ',
    required: true // Field ini wajib diisi
  }
});

// Membuat model Recipe berdasarkan skema yang telah didefinisikan
const Recipe = mongoose.model('Recipe', recipeSchema);

// Mengekspor model Recipe agar bisa digunakan di file lain
module.exports = Recipe;