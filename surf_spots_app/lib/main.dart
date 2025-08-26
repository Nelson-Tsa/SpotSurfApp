import 'package:flutter/material.dart';
import 'package:surf_spots_app/pages/explore_page.dart';
import 'package:surf_spots_app/pages/favoris_page.dart';
import 'package:surf_spots_app/pages/profile_page.dart';
import 'package:surf_spots_app/routes.dart';
import 'package:surf_spots_app/widgets/navbar.dart';
import 'package:surf_spots_app/widgets/carroussel.dart';
import 'package:surf_spots_app/widgets/searchbar.dart';
import 'package:surf_spots_app/widgets/grid.dart';
import 'package:surf_spots_app/pages/map_page.dart';
import 'package:surf_spots_app/constants/colors.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surf Spots App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
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
  // Variable pour tracker si le panel de la carte est ouvert
  bool _isMapPanelOpen = false;

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

  void _onMapPanelStateChanged(bool isOpen) {
    setState(() {
      _isMapPanelOpen = isOpen;
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
      const ExplorePage(),
      MapPage(onPanelStateChanged: _onMapPanelStateChanged),
      const FavorisPage(),
      Center(
        // child: ProfilePage(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.black,
                maximumSize: const Size(350, 60),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.black,
                minimumSize: const Size(170, 30),

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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: Container(
        // Le fond d'écran est conservé
        decoration: _selectedIndex == 4
            ? null
            : const BoxDecoration(
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
      floatingActionButton: (_selectedIndex == 2 && _isMapPanelOpen)
          ? null
          : FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Incrémenter',
              child: const Icon(Icons.add),
            ),
    );
  }
}
