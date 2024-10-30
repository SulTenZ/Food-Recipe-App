// lib/screens/verify_register.dart
import 'package:flutter/material.dart'; // Library material untuk widget UI
import 'package:http/http.dart' as http; // Library HTTP untuk request ke backend
import 'dart:convert'; // Library JSON untuk encode/decode data

// Membuat StatefulWidget untuk screen verifikasi registrasi
class VerifyRegisterScreen extends StatefulWidget {
  const VerifyRegisterScreen({super.key});

  @override
  _VerifyRegisterScreenState createState() => _VerifyRegisterScreenState();
}

class _VerifyRegisterScreenState extends State<VerifyRegisterScreen> {
  final _otpController = TextEditingController(); // Controller untuk input OTP
  bool _isLoading = false; // Status loading untuk button
  late String _email; // Variabel email yang didapat dari argument

  @override
  void didChangeDependencies() { // Mendapatkan email dari argument route
    super.didChangeDependencies();
    _email = ModalRoute.of(context)!.settings.arguments as String; // Ambil argument email
  }

  // Fungsi verifikasi OTP
  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) { // Validasi jika OTP kosong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP code')), // Show pesan error
      );
      return;
    }

    setState(() => _isLoading = true); // Set status loading

    try {
      // Kirim POST request ke endpoint verifikasi OTP
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/verify-register'), // URL endpoint verifikasi
        headers: {'Content-Type': 'application/json'}, // Headers request
        body: json.encode({
          'email': _email, // Kirim email ke backend
          'otp': _otpController.text, // Kirim OTP ke backend
        }),
      );

      if (response.statusCode == 200) { // Jika verifikasi berhasil
        Navigator.pushReplacementNamed(context, '/home'); // Pindah ke halaman home
      } else {
        final error = json.decode(response.body); // Ambil error dari response
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
        title: const Text('Verifikasi'), // Set judul AppBar
        backgroundColor: Colors.transparent, // Set background AppBar transparan
        elevation: 0, // Hilangkan shadow pada AppBar
        foregroundColor: Colors.black, // Warna teks AppBar
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding konten
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Membuat kolom full lebar
            children: [
              const Text(
                'Masukkan kode OTP', // Teks instruksi
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30), // Space vertikal
              TextFormField(
                controller: _otpController, // Set controller OTP
                decoration: InputDecoration(
                  labelText: 'Kode OTP', // Label input OTP
                  labelStyle: const TextStyle(color: Colors.black), // Style label
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange), // Border default
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange), // Border saat fokus
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange), // Border saat tidak fokus
                  ),
                ),
                keyboardType: TextInputType.number, // Input khusus angka
                textAlign: TextAlign.center, // Text input center
                style: const TextStyle(letterSpacing: 8.0, fontSize: 20), // Style input
              ),
              const SizedBox(height: 30), // Space vertikal
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP, // Jika loading, onPressed null
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15), // Padding button
                  backgroundColor: Colors.orange, // Warna background button
                ),
                child: _isLoading
                    ? const CircularProgressIndicator() // Indicator loading
                    : const Text('Verifikasi', style: TextStyle(color: Colors.black)), // Teks button
              ),
            ],
          ),
        ),
      ),
    );
  }
}