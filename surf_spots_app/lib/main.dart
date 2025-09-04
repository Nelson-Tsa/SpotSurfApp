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
import 'package:surf_spots_app/services/auth_service.dart';
import 'package:surf_spots_app/auth/login_page.dart';

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
  Key _profileKey = UniqueKey(); // Clé pour forcer le rebuild

  // Variable pour tracker si le panel de la carte est ouvert
  bool _isMapPanelOpen = false;

  // On garde une clé pour accéder à MapPage et ouvrir le panel depuis le bouton +
  final GlobalKey<MapPageState> _mapPageKey = GlobalKey<MapPageState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Si on va sur l'onglet Profile, on renouvelle la clé pour forcer le rebuild
      if (index == 4) {
        _profileKey = UniqueKey();
      }
      // Si on quitte la carte, on ferme le panel
      if (index != 2 && _isMapPanelOpen) {
        _isMapPanelOpen = false;
      }
    });
  }

  void _onMapPanelStateChanged(bool isOpen) {
    setState(() {
      _isMapPanelOpen = isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Liste des pages utilisées par la barre de navigation
    final List<Widget> pages = [
      // Page 0: Accueil
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de recherche en haut
          SearchBarSpot(),
          SizedBox(height: 0.5),
          // Carrousel
          Carroussel(),
          SizedBox(height: 0.3),
          // Grille des spots
          Expanded(child: GalleryPage()),
        ],
      ),
      // Autres pages
      const ExplorePage(),
      MapPage(key: _mapPageKey, onPanelStateChanged: _onMapPanelStateChanged),
      const FavorisPage(),
      // Page Profile conditionnelle
      FutureBuilder<bool>(
        key: _profileKey, // Clé pour forcer le rebuild
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final isLoggedIn = snapshot.data ?? false;

          if (isLoggedIn) {
            return const ProfilePage();
          } else {
            return LoginPage(
              onLoginSuccess: () {
                setState(() {
                  _profileKey = UniqueKey(); // Forcer le rebuild
                });
              },
            );
          }
        },
      ),
    ];

    return Scaffold(
      body: Container(
        // Fond d'écran sauf sur la page 4
        decoration: _selectedIndex == 4
            ? null
            : const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: pages.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Navbar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      // Bouton flottant pour ajouter un spot sur la map
      floatingActionButton:
          (_selectedIndex == 2 && _isMapPanelOpen) || _selectedIndex == 4
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (_selectedIndex == 2) {
                  _mapPageKey.currentState?.openAddSpotPanel();
                } else {
                  setState(() => _selectedIndex = 2);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _mapPageKey.currentState?.openAddSpotPanel();
                  });
                }
              },
              tooltip: 'Ajouter un spot',
              child: const Icon(Icons.add),
            ),
    );
  }
}
