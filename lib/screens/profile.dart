import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/shared.dart'; // Pastikan impor shared.dart sudah benar
import 'added_recipe.dart'; // Pastikan Anda mengimpor halaman AddedRecipeScreen jika belum

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _email = '';
  int _selectedIndex = 3; // Set index ke 3 untuk halaman profil

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fungsi untuk mengambil data profil pengguna
  Future<void> _fetchUserProfile() async {
    try {
      final token = await getToken();

      if (token == null) {
        // Redirect ke halaman login jika tidak ada token
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _username = userData['username'];
          _email = userData['email'];
        });
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    try {
      final token = await getToken();

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Hapus token dari SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('authToken');

        // Redirect ke halaman login
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/login', 
          (Route<dynamic> route) => false
        );
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'] ?? 'Logout gagal')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan koneksi')),
      );
    }
  }

  // Fungsi untuk menangani navigasi antar halaman
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Navigasi ke halaman favorit (jika ada)
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddedRecipeScreen()),
        ).then((_) {
          setState(() {
            _selectedIndex = 3;
          });
        });
        break;
      case 3:
        // Sudah di halaman profil
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.orange[100],
                child: Icon(
                  Icons.person,
                  color: Colors.orange,
                  size: 60,
                ),
              ),
              SizedBox(height: 20),
              Text(
                _username,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 40),
              _buildProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profil',
                onTap: () {
                  // Implementasi edit profil
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Pengaturan',
                onTap: () {
                  // Implementasi halaman pengaturan
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Bantuan',
                onTap: () {
                  // Implementasi halaman bantuan
                },
              ),
              SizedBox(height: 20),
              _buildProfileMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: _logout,
                isLogout: true,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isLogout ? Colors.red : Colors.orange
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16, 
          color: isLogout ? Colors.red : Colors.black
        ),
      ),
      trailing: Icon(
        Icons.chevron_right, 
        color: isLogout ? Colors.red : Colors.grey
      ),
      onTap: onTap,
    );
  }
}
