// lib/screens/edit_recipe.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Widget untuk layar edit resep
class EditRecipeScreen extends StatefulWidget {
  final String recipeId; // ID resep yang akan diedit
  final String currentName; // Nama resep saat ini
  final List<String> currentIngredients; // Bahan-bahan saat ini
  final String currentInstructions; // Langkah-langkah saat ini

  const EditRecipeScreen({
    Key? key,
    required this.recipeId,
    required this.currentName,
    required this.currentIngredients,
    required this.currentInstructions,
  }) : super(key: key);

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk form
  late TextEditingController _nameController; // Controller untuk nama resep
  late TextEditingController _ingredientsController; // Controller untuk bahan
  late TextEditingController _instructionsController; // Controller untuk langkah-langkah
  bool _isLoading = false; // Indikator loading saat mengirim data

  @override
  void initState() {
    super.initState();
    // Inisialisasi controllers dengan nilai awal dari widget
    _nameController = TextEditingController(text: widget.currentName);
    _ingredientsController = TextEditingController(text: widget.currentIngredients.join(', '));
    _instructionsController = TextEditingController(text: widget.currentInstructions);
  }

  // Fungsi untuk mengirim data resep yang telah diedit ke server
  Future<void> _submitRecipe() async {
    // Validasi form sebelum pengiriman
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Tampilkan loading

    try {
      // Mengirim permintaan PUT untuk memperbarui resep di server
      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/api/recipes/${widget.recipeId}'),
        headers: {
          'Authorization': 'Bearer your-token-here', // Token otorisasi
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _nameController.text, // Nama resep baru
          'ingredients': _ingredientsController.text.split(',').map((e) => e.trim()).toList(), // Mengonversi bahan ke list
          'instructions': _instructionsController.text, // Langkah-langkah baru
        }),
      );

      // Jika berhasil, kembali ke layar sebelumnya dan tampilkan pesan
      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil diperbarui')),
        );
      } else {
        throw Exception('Failed to update recipe'); // Menangani kesalahan jika permintaan gagal
      }
    } catch (e) {
      // Menampilkan pesan kesalahan jika ada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false); // Menyembunyikan loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Resep', // Judul aplikasi
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Menghilangkan bayangan
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Tombol kembali
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey, // Menghubungkan form dengan kunci
        child: ListView(
          padding: const EdgeInsets.all(16), // Padding di sekitar form
          children: [
            // Field untuk nama resep
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Resep',
                labelStyle: const TextStyle(color: Colors.black),
                hintText: 'Masukkan nama resep',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              validator: (value) {
                // Validasi nama resep
                if (value == null || value.isEmpty) {
                  return 'Nama resep tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Field untuk bahan
            TextFormField(
              controller: _ingredientsController,
              decoration: InputDecoration(
                labelText: 'Bahan',
                labelStyle: const TextStyle(color: Colors.black),
                hintText: 'Masukkan bahan-bahan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              validator: (value) {
                // Validasi bahan
                if (value == null || value.isEmpty) {
                  return 'Bahan tidak boleh kosong';
                }
                return null;
              },
              maxLines: 3, // Batasan baris untuk bahan
            ),
            const SizedBox(height: 16),
            // Field untuk langkah-langkah
            TextFormField(
              controller: _instructionsController,
              decoration: InputDecoration(
                labelText: 'Langkah-Langkah',
                labelStyle: const TextStyle(color: Colors.black),
                hintText: 'Masukkan langkah-langkah',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              validator: (value) {
                // Validasi langkah-langkah
                if (value == null || value.isEmpty) {
                  return 'Langkah-langkah tidak boleh kosong';
                }
                return null;
              },
              maxLines: 5, // Batasan baris untuk langkah-langkah
            ),
            const SizedBox(height: 24),
            // Tombol untuk menyimpan perubahan
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRecipe, // Nonaktifkan jika loading
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.orange,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator() // Tampilkan indikator loading
                  : const Text(
                      'Simpan', // Teks tombol
                      style: TextStyle(color: Colors.black),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Membersihkan controllers saat widget dibuang
    _nameController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}

