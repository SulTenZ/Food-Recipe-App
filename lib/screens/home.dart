// lib/screens/home.dart
import 'package:flutter/material.dart';  // Mengimpor paket material design Flutter.
import 'added_recipe.dart';  // Mengimpor layar 'AddedRecipeScreen' untuk menampilkan resep yang ditambahkan.

class Recipe {  // Kelas model untuk menyimpan data resep.
  final String name;
  final String chef;
  final double rating;
  final String imageUrl;

  const Recipe({
    required this.name,
    required this.chef,
    required this.rating,
    required this.imageUrl,
  });
}

class HomeScreen extends StatefulWidget {  // Stateful widget untuk layar beranda aplikasi.
  static const List<Recipe> _recipes = [  
    // Daftar resep yang ditampilkan pada halaman utama (Sementara saya membuat list untuk sekedar tampilan saja,
    // untuk selanjutnya saya ingin fetch API unofficial dari orang yang saya temukan di github untuk menampilkan
    // resep-resep masakan yang sudah ada)
    Recipe(
      name: 'Nasi Goreng Spesial',
      chef: 'Chef John',
      rating: 4.5,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Recipe(
      name: 'Soto Ayam',
      chef: 'Chef Sarah',
      rating: 4.8,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Recipe(
      name: 'Rendang Daging',
      chef: 'Chef Michael',
      rating: 4.7,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Recipe(
      name: 'Mie Goreng',
      chef: 'Chef Lisa',
      rating: 4.3,
      imageUrl: 'https://via.placeholder.com/150',
    ),
  ];

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;  // Menyimpan indeks navigasi bawah yang dipilih.

  void _onItemTapped(int index) {  // Fungsi untuk menangani navigasi antar halaman.
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {  // Navigasi ke layar 'AddedRecipeScreen' saat ikon bookmark ditekan.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddedRecipeScreen()),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(  // Memastikan konten tidak berada di bawah area notifikasi perangkat.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(  // Menampilkan sapaan dan ikon profil.
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Halo,',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Mau masak apa hari ini?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: const Icon(
                      Icons.person,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari resep',  // Placeholder untuk kolom pencarian.
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orange, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Recipe grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: HomeScreen._recipes.length,
                itemBuilder: (context, index) {
                  final recipe = HomeScreen._recipes[index];
                  return RecipeCard(recipe: recipe);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(  // Bar navigasi bawah dengan ikon untuk halaman berbeda.
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
}


class RecipeCard extends StatelessWidget {  // Kartu untuk menampilkan informasi tiap resep.
  final Recipe recipe;

  const RecipeCard({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(  // Menampilkan gambar resep di bagian atas kartu.
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Image.network(
                  recipe.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(  // Posisi rating di kanan atas gambar.
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,  // Menampilkan nama resep.
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(  // Menampilkan nama koki di bawah nama resep.
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'By ${recipe.chef}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
