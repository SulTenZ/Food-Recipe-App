// lib/screens/added_recipe.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/services/shared.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_recipe.dart';
import 'home.dart';
import 'added_recipe_detail.dart'; // Import halaman detail resep
import 'edit_recipe.dart'; // Import halaman edit resep

// Widget utama untuk layar resep yang telah ditambahkan
class AddedRecipeScreen extends StatefulWidget {
  const AddedRecipeScreen({super.key});

  @override
  State<AddedRecipeScreen> createState() => _AddedRecipeScreenState();
}

class _AddedRecipeScreenState extends State<AddedRecipeScreen> {
  List<dynamic> _recipes = []; // Daftar resep yang diambil dari server
  bool _isLoading = true; // Indikator loading untuk menunggu data
  int _selectedIndex = 2; // Indeks item yang dipilih di bottom navigation

  @override
  void initState() {
    super.initState();
    _fetchRecipes(); // Memanggil fungsi untuk mengambil resep saat inisialisasi
  }

  // Fungsi untuk mengambil resep dari API
  Future<void> _fetchRecipes() async {
    final token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please login again.')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/recipes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
      final List<dynamic> recipes = json.decode(response.body);
        // Filter resep berdasarkan ID pengguna
        setState(() {
          _recipes = recipes;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Fungsi untuk menghapus resep
  Future<void> _deleteRecipe(String recipeId) async {
    final token = await getToken();
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:5000/api/recipes/$recipeId'),
        headers: {
          'Authorization':
              'Bearer $token', // Login belum disempurnakan, belum ada JWT
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Jika penghapusan berhasil, ambil ulang daftar resep
        _fetchRecipes();
      } else {
        throw Exception('Failed to delete recipe');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Fungsi untuk menangani navigasi saat item dipilih di bottom navigation
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        // Navigasi ke halaman Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        // Implement navigasi ke halaman favorit jika diperlukan
        break;
      case 2:
        // Halaman yang sama
        break;
      case 3:
        // Implement navigasi ke halaman profil jika diperlukan
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resep Anda', // Judul layar
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Menghilangkan bayangan
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Tampilkan indikator loading
          : _recipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum ada resep yang ditambahkan', // Pesan jika tidak ada resep
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateRecipeScreen(),
                          ),
                        ),
                        child: const Text(
                            'Tambah Resep Sekarang'), // Tombol untuk menambah resep
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16), // Padding untuk ListView
                  itemCount: _recipes.length, // Jumlah item dalam ListView
                  itemBuilder: (context, index) {
                    final recipe =
                        _recipes[index]; // Mengambil resep berdasarkan index
                    return Card(
                      margin: const EdgeInsets.only(
                          bottom: 16), // Margin di bawah kartu
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Membulatkan sudut
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(
                            16), // Padding di dalam ListTile
                        title: Text(
                          recipe['name'], // Menampilkan nama resep
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Bahan: ${recipe['ingredients'].join(", ")}', // Menampilkan bahan
                              maxLines: 2,
                              overflow: TextOverflow
                                  .ellipsis, // Mengatur overflow teks
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigasi ke halaman detail resep
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddedRecipeDetailScreen(
                                recipeName: recipe['name'], // Nama resep
                                ingredients: List<String>.from(
                                    recipe['ingredients']), // Bahan resep
                                instructions: recipe['instructions'] ??
                                    'Tidak ada instruksi', // Instruksi resep
                              ),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Ukuran minimum baris
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit), // Tombol edit
                              onPressed: () {
                                // Navigasi ke halaman edit resep
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditRecipeScreen(
                                      recipeId: recipe['_id'], // ID resep
                                      currentName: recipe['name'], // Nama resep
                                      currentIngredients: List<String>.from(
                                          recipe['ingredients']), // Bahan resep
                                      currentInstructions: recipe[
                                              'instructions'] ??
                                          'Tidak ada instruksi', // Instruksi resep
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                  Icons.delete_outline), // Tombol hapus
                              onPressed: () async {
                                // Panggil fungsi penghapusan resep
                                await _deleteRecipe(recipe['_id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      // Tombol untuk menambah resep baru
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateRecipeScreen()),
        ),
        child: const Icon(Icons.add,
            color: Colors.white), // Ikon untuk tombol tambah
        backgroundColor: Colors.orange,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Bar navigasi bawah dengan ikon untuk halaman berbeda
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex, // Indeks item yang dipilih
        selectedItemColor: Colors.orange, // Warna item terpilih
        unselectedItemColor: Colors.grey, // Warna item tidak terpilih
        onTap: _onItemTapped, // Fungsi untuk menangani item yang dipilih
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
