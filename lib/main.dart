// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/added_recipe.dart';
import 'package:flutter_application/screens/create_recipe.dart';
import 'package:flutter_application/screens/edit_password.dart';
import 'package:flutter_application/screens/forgot_password.dart';
import 'package:flutter_application/screens/payment_screen.dart';
import 'package:flutter_application/screens/profile.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/verify_register.dart';
import 'screens/home.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/verify-register': (context) => const VerifyRegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/added-recipes': (context) => const AddedRecipeScreen(),
        '/create-recipe': (context) => const CreateRecipeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/edit-password': (context) => const EditPasswordScreen(),
        '/payment': (context) => const PaymentScreen()
      }
    );
  }
}
