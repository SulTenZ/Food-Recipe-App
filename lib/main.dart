// lib/main.dart
import 'package:flutter/material.dart';  // Mengimpor paket Material untuk desain UI di Flutter.
import 'package:flutter_application/screens/added_recipe.dart';  // Mengimpor layar untuk resep yang ditambahkan.
import 'package:flutter_application/screens/create_recipe.dart';  // Mengimpor layar untuk membuat resep.
import 'package:flutter_application/screens/edit_password.dart';
import 'package:flutter_application/screens/forgot_password.dart';
import 'package:flutter_application/screens/profile.dart';
import 'screens/login.dart';  // Mengimpor layar login.
import 'screens/register.dart';  // Mengimpor layar registrasi.
import 'screens/verify_register.dart';  // Mengimpor layar verifikasi registrasi.
import 'screens/home.dart';  // Mengimpor layar utama.
import 'screens/splash_screen.dart';  // Mengimpor layar SplashScreen.


void main() {
  runApp(const MyApp());  // Memanggil aplikasi utama.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,  // Menetapkan judul aplikasi.
      theme: ThemeData(
        primarySwatch: Colors.orange,  // Mengatur warna utama aplikasi menjadi oranye.
        scaffoldBackgroundColor: Colors.white,  // Mengatur warna latar belakang menjadi putih.
      ),
      initialRoute: '/splash',  // Menetapkan rute awal aplikasi ke SplashScreen.
      routes: {
        '/splash': (context) => const SplashScreen(),  // Rute untuk layar splash.
        '/login': (context) => const LoginScreen(),  // Rute untuk layar login.
        '/register': (context) => const RegisterScreen(),  // Rute untuk layar registrasi.
        '/verify-register': (context) => const VerifyRegisterScreen(),  // Rute untuk layar verifikasi registrasi.
        '/home': (context) => const HomeScreen(),  // Rute untuk layar utama setelah login.
        '/added-recipes': (context) => const AddedRecipeScreen(),  // Rute untuk layar daftar resep yang telah ditambahkan.
        '/create-recipe': (context) => const CreateRecipeScreen(),  // Rute untuk layar membuat resep baru.
        '/profile': (context) => const ProfileScreen(), // Rute untuk Layar profil.
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/edit-password': (context) => const EditPasswordScreen()
      },
    );
  }
}
