// lib/screens/create_recipe.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/shared.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  // Key untuk validasi form
  final _formKey = GlobalKey<FormState>();
  
  // Controllers untuk menangani input pengguna
  final _nameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  // Menyimpan status loading saat proses pengiriman data
  bool _isLoading = false;

  // Fungsi untuk submit resep ke backend
  Future<void> _submitRecipe() async {
    // Memvalidasi form, jika tidak valid, return
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Mengaktifkan indikator loading
    final token = await getToken();
    try {
      // Membuat permintaan POST ke server untuk menambahkan resep baru
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/recipes'),
        headers: {
          'Authorization': 'Bearer $token', // Token otorisasi
          'Content-Type': 'application/json',
        },
        body: json.encode({
          // Mengambil nilai dari controller dan menyiapkan JSON body
          'name': _nameController.text,
          'ingredients': _ingredientsController.text.split(',').map((e) => e.trim()).toList(),
          'instructions': _instructionsController.text,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return; // Cek jika widget masih dalam tree
        Navigator.pop(context); // Kembali ke layar sebelumnya
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil ditambahkan')),
        );
      } else {
        throw Exception('Failed to create recipe');
      }
    } catch (e) {
      // Menampilkan error jika koneksi gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false); // Nonaktifkan indikator loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambahkan Resep',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildFormSection(
                icon: Icons.restaurant_menu_rounded,
                title: 'Detail Resep',
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration(
                      'Nama Resep',
                      'Masukkan nama resep',
                      Icons.food_bank_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama resep tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ingredientsController,
                    decoration: _buildInputDecoration(
                      'Bahan-bahan',
                      'Masukkan bahan-bahan (pisahkan dengan koma)',
                      Icons.format_list_bulleted_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bahan tidak boleh kosong';
                      }
                      return null;
                    },
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _instructionsController,
                    decoration: _buildInputDecoration(
                      'Langkah-Langkah',
                      'Masukkan langkah-langkah pembuatan',
                      Icons.format_list_numbered_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Langkah-langkah tidak boleh kosong';
                      }
                      return null;
                    },
                    maxLines: 5,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simpan Resep',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: Colors.orange.shade400,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: Colors.orange.shade400,
      ),
      labelStyle: TextStyle(
        color: Colors.brown.shade600,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.orange.shade200,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.orange.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.orange.shade400,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.red.shade300,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.red.shade400,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.orange.shade50.withOpacity(0.3),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}