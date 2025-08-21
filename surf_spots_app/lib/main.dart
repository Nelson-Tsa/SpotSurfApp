import 'package:flutter/material.dart';
import 'package:surf_spots_app/routes.dart';
import 'package:surf_spots_app/widgets/navbar.dart';
import 'package:surf_spots_app/widgets/carroussel.dart';
import 'package:surf_spots_app/widgets/return_button.dart';
import 'package:surf_spots_app/widgets/searchbar.dart';
import 'package:surf_spots_app/widgets/grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surf Spots App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 91, 188, 237),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      home: const HomeScreen(title: 'Surf Spots App'),
      debugShowCheckedModeBanner: false,
      routes: Routes.appRoutes,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // Le compteur n'est plus utilisé dans cette mise en page, mais on le garde pour le bouton
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. On définit la liste des pages ici pour qu'elle soit toujours à jour.
    final List<Widget> pages = [
      // Page 0: "Accueil"
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Éléments non défilables en haut
          SearchBarSpot(),
          SizedBox(height: 0.5), // Espace entre les widgets
          Carroussel(),
          SizedBox(height: 0.3), // Espace entre les widgets
          // 3. La grille prend tout l'espace restant et est défilable
          Expanded(child: GalleryPage()),
        ],
      ),
      // Les autres pages de la barre de navigation
      const Center(
        child: Text(
          'Explore',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      const Center(
        child: Text(
          'Carte',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      const Center(
        child: Text(
          'Favoris',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                'Se connecter',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text(
                'S\'inscrire',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: Container(
        // Le fond d'écran est conservé
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        // 4. Le contenu par-dessus le fond d'écran
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: pages.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Navbar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Incrémenter',
        child: const Icon(Icons.add),
      ),
    );
  }
}
