// lib/screens/added_recipe.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/payment_screen.dart';
import 'package:flutter_application/services/shared.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_recipe.dart';
import 'home.dart';
import 'added_recipe_detail.dart';
import 'edit_recipe.dart';
import 'profile.dart';

// Widget AddedRecipeScreen menggunakan StatefulWidget untuk mengelola daftar resep yang ditambahkan user
class AddedRecipeScreen extends StatefulWidget {
  const AddedRecipeScreen({super.key});

  @override
  State<AddedRecipeScreen> createState() => _AddedRecipeScreenState();
}

// State untuk AddedRecipeScreen
class _AddedRecipeScreenState extends State<AddedRecipeScreen> {
  List<dynamic> _recipes = []; // Menyimpan daftar resep
  bool _isLoading = true; // Menandakan proses loading data
  int _selectedIndex = 1; // Index untuk bottom navigation
  bool _isPremium = false; // Status premium user

  @override
  void initState() {
    super.initState();
    _fetchRecipes(); // Mengambil data resep saat widget diinisialisasi
    _checkPremiumStatus(); // Memeriksa status premium user
  }

  // Fungsi untuk mengambil daftar resep dari API
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

  // Fungsi untuk memeriksa status premium user
  Future<void> _checkPremiumStatus() async {
    try {
      final token = await getToken();
      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/auth/user-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _isPremium = userData['isPremium'] ?? false;
        });
      }
    } catch (e) {
      print('Error checking premium status: $e');
    }
  }

  // Dialog untuk menampilkan peringatan upgrade ke premium
  void _showPremiumRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: const Text(
          'Anda perlu mengupgrade ke akun Premium untuk menambahkan resep baru.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentScreen(),
                ),
              );
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  // Handler untuk tombol tambah resep
  void _onAddRecipePressed() {
    if (_isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateRecipeScreen()),
      ).then((_) => _fetchRecipes());
    } else {
      _showPremiumRequiredDialog();
    }
  }

  // Fungsi untuk menghapus resep
  Future<void> _deleteRecipe(String recipeId) async {
    final token = await getToken();
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:5000/api/recipes/$recipeId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
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

  // Handler untuk bottom navigation
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resep Anda',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.orange.shade400,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
                ),
              )
            : _recipes.isEmpty
                ? _buildEmptyState()
                : _buildRecipeList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddRecipePressed,
        backgroundColor:
            _isPremium ? Colors.orange.shade400 : Colors.grey.shade400,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Tambah Resep',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange.shade700,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_rounded),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

// Widget untuk menampilkan tampilan ketika resep kosong
Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.restaurant_menu_rounded,
            size: 80,
            color: Colors.orange.shade400,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _isPremium 
            ? 'Belum ada resep yang ditambahkan' 
            : 'Fitur tambah resep terbatas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isPremium 
            ? 'Mulai bagikan resep favorit Anda!' 
            : 'Upgrade ke Premium untuk menambahkan resep',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _onAddRecipePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPremium ? Colors.orange.shade400 : Colors.grey.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
          child: Text( // Ensure the child parameter is provided here
            _isPremium ? 'Tambah Resep Sekarang' : 'Upgrade Premium',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

  // Widget untuk menampilkan daftar resep
  Widget _buildRecipeList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restaurant_rounded,
                color: Colors.orange.shade400,
                size: 32,
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                recipe['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Bahan: ${recipe['ingredients'].join(", ")}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddedRecipeDetailScreen(
                    recipeName: recipe['name'],
                    ingredients: List<String>.from(recipe['ingredients']),
                    instructions: recipe['instructions'] ?? 'Tidak ada instruksi',
                  ),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    color: Colors.orange.shade400,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditRecipeScreen(
                          recipeId: recipe['_id'],
                          currentName: recipe['name'],
                          currentIngredients: List<String>.from(recipe['ingredients']),
                          currentInstructions: recipe['instructions'] ?? 'Tidak ada instruksi',
                        ),
                      ),
                    ).then((_) => _fetchRecipes());
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Resep'),
                        content: const Text(
                          'Apakah Anda yakin ingin menghapus resep ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Batal',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteRecipe(recipe['_id']);
                            },
                            child: const Text(
                              'Hapus',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}