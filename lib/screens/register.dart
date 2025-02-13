// lib/screens/register.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Widget RegisterScreen menggunakan StatefulWidget karena membutuhkan perubahan state
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

// State untuk RegisterScreen
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey untuk memvalidasi form
  final _nameController = TextEditingController(); // Controller untuk nama
  final _emailController = TextEditingController(); // Controller untuk email
  final _passwordController = TextEditingController(); // Controller untuk password
  bool _acceptTerms = false; // Status penerimaan syarat dan ketentuan
  bool _isLoading = false; // Menandakan apakah sedang memproses registrasi
  bool _obscurePassword = true; // Menyembunyikan/memperlihatkan password

  // Fungsi untuk melakukan registrasi
  Future<void> _register() async {
    // Validasi form dan penerimaan syarat dan ketentuan
    if (!_formKey.currentState!.validate() || !_acceptTerms) {
      if (!_acceptTerms) {
        _showErrorSnackBar('Terima syarat & ketentuan');
      }
      return;
    }

    setState(() => _isLoading = true); // Tampilkan indikator loading

    try {
      // Kirim permintaan POST ke API registrasi
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/register'), // URL API
        headers: {'Content-Type': 'application/json'}, // Header permintaan
        body: json.encode({
          'username': _nameController.text, // Data nama dari TextField
          'email': _emailController.text, // Data email dari TextField
          'password': _passwordController.text, // Data password dari TextField
        }),
      );

      // Jika registrasi berhasil (status 201)
      if (response.statusCode == 201) {
        // Pindah ke halaman verifikasi registrasi dengan membawa data email
        Navigator.pushReplacementNamed(
          context,
          '/verify-register',
          arguments: _emailController.text,
        );
      } else {
        // Jika gagal registrasi, tampilkan pesan kesalahan dari API
        final error = json.decode(response.body);
        _showErrorSnackBar(error['message']);
      }
    } catch (e) {
      // Tampilkan pesan kesalahan koneksi
      _showErrorSnackBar('Connection error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk menampilkan SnackBar kesalahan
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dengan judul dan styling
      appBar: AppBar(
        title: const Text(
          'Buat akun',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      // Body dengan gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Teks judul halaman
                    Text(
                      'Buat akun agar dapat\nmasuk ke aplikasi',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey.shade800,
                            height: 1.3,
                          ),
                    ),
                    const SizedBox(height: 32),
                    // TextField untuk nama
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nama',
                      prefixIcon: Icons.person_outline,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Masukkan nama Anda' : null,
                    ),
                    const SizedBox(height: 20),
                    // TextField untuk email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      prefixIcon: Icons.email_outlined,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Masukkan email Anda' : null,
                    ),
                    const SizedBox(height: 20),
                    // TextField untuk password dengan toggle visibility
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Masukkan password Anda'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    // Checkbox untuk syarat dan ketentuan
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) =>
                                setState(() => _acceptTerms = value!),
                            activeColor: Colors.orange.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Terima Syarat & Ketentuan',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Tombol Sign Up dengan loading indicator
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    // Link ke halaman login untuk pengguna yang sudah memiliki akun
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun?',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.orange.shade800,
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk membangun TextField dengan styling yang konsisten
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        prefixIcon: Icon(prefixIcon, color: Colors.orange.shade400),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
      ),
      validator: validator,
    );
  }
}