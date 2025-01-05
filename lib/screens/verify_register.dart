// lib/screens/verify_register.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Widget VerifyRegisterScreen menggunakan StatefulWidget untuk menangani verifikasi OTP
class VerifyRegisterScreen extends StatefulWidget {
  const VerifyRegisterScreen({super.key});

  @override
  _VerifyRegisterScreenState createState() => _VerifyRegisterScreenState();
}

// State untuk VerifyRegisterScreen
class _VerifyRegisterScreenState extends State<VerifyRegisterScreen> {
  final _otpController = TextEditingController(); // Controller untuk input OTP
  bool _isLoading = false; // Menandakan apakah sedang memproses verifikasi
  late String _email; // Menyimpan email yang akan diverifikasi

  @override
  // Mengambil email dari arguments yang dikirim saat navigasi
  void didChangeDependencies() {
    super.didChangeDependencies();
    _email = ModalRoute.of(context)!.settings.arguments as String;
  }

  // Fungsi untuk memverifikasi kode OTP
  Future<void> _verifyOTP() async {
    // Validasi input OTP
    if (_otpController.text.isEmpty) {
      _showErrorSnackBar('Masukkan kode OTP');
      return;
    }

    setState(() => _isLoading = true); // Tampilkan indikator loading

    try {
      // Kirim permintaan POST ke API verifikasi
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/verify-register'), // URL API
        headers: {'Content-Type': 'application/json'}, // Header permintaan
        body: json.encode({
          'email': _email, // Email yang diverifikasi
          'otp': _otpController.text, // Kode OTP dari input
        }),
      );

      // Jika verifikasi berhasil (status 200)
      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/home'); // Pindah ke halaman Home
      } else {
        // Jika gagal verifikasi, tampilkan pesan kesalahan dari API
        final error = json.decode(response.body);
        _showErrorSnackBar(error['message']);
      }
    } catch (e) {
      // Tampilkan pesan kesalahan koneksi
      _showErrorSnackBar('Terjadi kesalahan koneksi');
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

  // Widget untuk membangun TextField khusus input OTP
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number, // Keyboard khusus angka
      textAlign: TextAlign.center, // Text di tengah
      style: const TextStyle(letterSpacing: 8.0, fontSize: 20), // Style untuk OTP
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        prefixIcon: Icon(prefixIcon, color: Colors.orange.shade400),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dengan warna dan styling yang konsisten
      appBar: AppBar(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon email terverifikasi
                  Icon(
                    Icons.mark_email_read_rounded,
                    size: 64,
                    color: Colors.orange.shade400,
                  ),
                  const SizedBox(height: 24),
                  // Judul halaman
                  Text(
                    'Verifikasi Email',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Instruksi untuk pengguna
                  Text(
                    'Masukkan kode OTP yang telah dikirim ke email Anda',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // TextField untuk input OTP
                  _buildTextField(
                    controller: _otpController,
                    label: 'Kode OTP',
                    prefixIcon: Icons.pin_outlined,
                  ),
                  const SizedBox(height: 32),
                  // Tombol verifikasi dengan loading indicator
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Verifikasi',
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
        ),
      ),
    );
  }

  // Membersihkan controller saat widget di dispose
  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}