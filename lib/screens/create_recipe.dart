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
          style: TextStyle(color: Colors.black), // Warna teks judul
        ),
        backgroundColor: Colors.white, // Warna latar belakang AppBar
        elevation: 0, // Menghilangkan shadow
        centerTitle: true, // Memusatkan judul
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey, // Key untuk validasi form
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Resep',
                labelStyle: TextStyle(color: Colors.black),
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
                if (value == null || value.isEmpty) {
                  return 'Nama resep tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ingredientsController,
              decoration: InputDecoration(
                labelText: 'Bahan',
                labelStyle: TextStyle(color: Colors.black),
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
                if (value == null || value.isEmpty) {
                  return 'Bahan tidak boleh kosong';
                }
                return null;
              },
              maxLines: 3, // Dapat memasukkan beberapa baris teks
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: InputDecoration(
                labelText: 'Langkah-Langkah',
                labelStyle: TextStyle(color: Colors.black),
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
                if (value == null || value.isEmpty) {
                  return 'Langkah-langkah tidak boleh kosong';
                }
                return null;
              },
              maxLines: 5, // Beberapa baris untuk instruksi
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRecipe,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.orange,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      'Simpan',
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
    _nameController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose(); // Membersihkan controller saat widget dibuang
  }
}