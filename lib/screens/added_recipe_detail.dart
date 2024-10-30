// lib/screens/added_recipe_detail.dart
import 'package:flutter/material.dart';

class AddedRecipeDetailScreen extends StatelessWidget {
  // Parameter yang diperlukan untuk menampilkan detail resep
  final String recipeName; // Nama resep
  final List<String> ingredients; // Daftar bahan resep
  final String instructions; // Instruksi pembuatan

  const AddedRecipeDetailScreen({
    Key? key,
    required this.recipeName,
    required this.ingredients,
    required this.instructions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName), // Menampilkan nama resep sebagai judul
        backgroundColor: Colors.orange, // Warna latar belakang AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul bagian bahan
            Text(
              'Bahan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8), // Spasi antar elemen
            // Menampilkan daftar bahan sebagai satu teks
            Text(ingredients.join(", "), style: TextStyle(fontSize: 16)),
            SizedBox(height: 16), // Spasi antara bagian bahan dan instruksi
            // Judul bagian instruksi
            Text(
              'Instruksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Menampilkan instruksi sebagai teks
            Text(instructions, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}