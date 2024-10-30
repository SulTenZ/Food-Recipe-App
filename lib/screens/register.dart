// lib/screens/register.dart
import 'package:flutter/material.dart'; // Import library material untuk UI
import 'package:http/http.dart' as http; // Import library HTTP untuk request ke backend
import 'dart:convert'; // Import library untuk encode dan decode data JSON

// Membuat StatefulWidget untuk register screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // Key untuk form validation
  final _nameController = TextEditingController(); // Controller untuk input nama
  final _emailController = TextEditingController(); // Controller untuk input email
  final _passwordController = TextEditingController(); // Controller untuk input password
  bool _acceptTerms = false; // Status checkbox Terms & Conditions
  bool _isLoading = false; // Status loading untuk button sign-up

  // Fungsi register async yang kirim request ke API register
  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || !_acceptTerms) { // Validasi form dan checkbox
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept terms and conditions')), // Show pesan error jika checkbox tidak dicentang
        );
      }
      return;
    }

    setState(() => _isLoading = true); // Set status loading ke true

    try {
      // Kirim POST request ke endpoint register
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/register'), // URL endpoint
        headers: {'Content-Type': 'application/json'}, // Headers request
        body: json.encode({
          'username': _nameController.text, // Isi data username dari input
          'email': _emailController.text, // Isi data email dari input
          'password': _passwordController.text, // Isi data password dari input
        }),
      );

      if (response.statusCode == 201) { // Jika register berhasil
        Navigator.pushReplacementNamed(
          context,
          '/verify-register', // Pindah ke halaman verifikasi registrasi
          arguments: _emailController.text, // Kirim email sebagai argument
        );
      } else {
        final error = json.decode(response.body); // Ambil error message dari response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'])), // Show error message
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error')), // Show pesan error koneksi
      );
    } finally {
      setState(() => _isLoading = false); // Set loading status ke false
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat akun'), // Set judul app bar
        backgroundColor: Colors.transparent, // Background app bar transparan
        elevation: 0, // Hilangkan bayangan pada app bar
        foregroundColor: Colors.black, // Warna teks app bar
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding di sekitar elemen UI
          child: Form(
            key: _formKey, // Set form key untuk validasi
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Membuat kolom full lebar
              children: [
                const Text(
                  'Buat akun agar dapat\nmasuk ke aplikasi', // Teks deskripsi
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30), // Space vertikal kosong
                TextFormField(
                  controller: _nameController, // Set controller untuk nama
                  decoration: InputDecoration(
                    labelText: 'Nama', // Label input
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
                  validator: (value) { // Validator untuk nama
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name'; // Pesan jika nama kosong
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20), // Space vertikal kosong
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
                  validator: (value) { // Validator untuk email
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email'; // Pesan jika email kosong
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
                  obscureText: true, // Buat input jadi bintang untuk password
                  validator: (value) { // Validator untuk password
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password'; // Pesan jika password kosong
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20), // Space vertikal kosong
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms, // Status checkbox
                      onChanged: (value) {
                        setState(() => _acceptTerms = value!); // Update status checkbox
                      },
                      activeColor: Colors.orange, // Warna aktif checkbox
                    ),
                    const Text('Terima Syarat & Ketentuan'), // Label checkbox
                  ],
                ),
                const SizedBox(height: 20), // Space vertikal kosong
                ElevatedButton(
                  onPressed: _isLoading ? null : _register, // Jika loading, onPressed null
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15), // Padding dalam button
                    backgroundColor: Colors.orange, // Warna background button
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator() // Indicator loading
                      : const Text('Sign Up', style: TextStyle(color: Colors.black)), // Teks button
                ),
                const SizedBox(height: 20), // Space vertikal kosong
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center alignment
                  children: [
                    const Text('Sudah punya akun?'), // Teks prompt sign-in
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Kembali ke halaman sebelumnya (login)
                      },
                      child: Text('Sign in', style: TextStyle(color: Colors.orange)), // Teks button
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
