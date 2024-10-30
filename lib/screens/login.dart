// lib/screens/login.dart
import 'package:flutter/material.dart'; // Import library material untuk UI Flutter
import 'package:http/http.dart' as http; // Import library HTTP untuk request ke backend
import 'dart:convert'; // Import library untuk encode dan decode data JSON

// Membuat StatefulWidget untuk login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Key untuk form validation
  final _emailController = TextEditingController(); // Controller untuk input email
  final _passwordController = TextEditingController(); // Controller untuk input password
  bool _isLoading = false; // Status loading untuk button login

  // Fungsi login async yang kirim request ke API login
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return; // Validasi form

    setState(() => _isLoading = true); // Set status loading ke true

    try {
      // Mengirim POST request ke endpoint login
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/login'), // URL endpoint
        headers: {'Content-Type': 'application/json'}, // Headers request
        body: json.encode({
          'email': _emailController.text, // Isi data email dari input
          'password': _passwordController.text, // Isi data password dari input
        }),
      );

      if (response.statusCode == 200) {
        // Jika login berhasil
        Navigator.pushReplacementNamed(context, '/home'); // Pindah ke halaman home
      } else {
        final error = json.decode(response.body); // Ambil error message dari response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'])), // Show error message
        );
      }
    } catch (e) {
      // Jika ada error koneksi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan koneksi')),
      );
    } finally {
      setState(() => _isLoading = false); // Set loading status ke false
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding di sekitar elemen UI
          child: Form(
            key: _formKey, // Set form key untuk validasi
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Membuat kolom menempati full lebar
              children: [
                const SizedBox(height: 40), // Space vertikal kosong
                const Text(
                  'Halo,',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Selamat datang!',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40), // Space vertikal kosong
                TextFormField(
                  controller: _emailController, // Set controller untuk email
                  decoration: InputDecoration(
                    labelText: 'Email', // Label input
                    labelStyle: const TextStyle(color: Colors.black), // Style label
                    border: const OutlineInputBorder(), // Border default
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.orange, width: 2), // Border saat fokus
                      borderRadius: BorderRadius.circular(12), // Radius border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.orange, width: 2), // Border saat tidak fokus
                      borderRadius: BorderRadius.circular(12), // Radius border
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan email Anda'; // Pesan validasi jika kosong
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20), // Space vertikal kosong
                TextFormField(
                  controller: _passwordController, // Set controller untuk password
                  decoration: InputDecoration(
                    labelText: 'Password', // Label input
                    labelStyle: const TextStyle(color: Colors.black), // Style label
                    border: const OutlineInputBorder(), // Border default
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.orange, width: 2), // Border saat fokus
                      borderRadius: BorderRadius.circular(12), // Radius border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.orange, width: 2), // Border saat tidak fokus
                      borderRadius: BorderRadius.circular(12), // Radius border
                    ),
                  ),
                  obscureText: true, // Mengatur input jadi karakter bintang untuk password
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan password Anda'; // Pesan validasi jika kosong
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10), // Space vertikal kosong
                TextButton(
                  onPressed: () {
                    // Implementasi fitur lupa password
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange, // Warna teks
                  ),
                  child: const Text('Lupa Password?'), // Teks button
                ),
                const SizedBox(height: 20), // Space vertikal kosong
                ElevatedButton(
                  onPressed: _isLoading ? null : _login, // Jika loading, onPressed null
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Warna background button
                    padding: const EdgeInsets.symmetric(vertical: 15), // Padding dalam button
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator() // Indicator loading
                      : const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.black), // Teks button saat tidak loading
                        ),
                ),
                const SizedBox(height: 20), // Space vertikal kosong
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Posisikan di tengah secara horizontal
                  children: [
                    const Text('Belum punya akun?'), // Teks ajakan daftar
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register'); // Pindah ke halaman register
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange, // Warna teks button
                      ),
                      child: const Text('Daftar sekarang'), // Teks button
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
