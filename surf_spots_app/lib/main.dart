import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_spots_app/providers/user_provider.dart';
import 'package:surf_spots_app/providers/spots_provider.dart';
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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SpotsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surf Spots App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: Colors.white,
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
  Key _profileKey = UniqueKey();
  bool _isMapPanelOpen = false;
  final GlobalKey<MapPageState> _mapPageKey = GlobalKey<MapPageState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 4) {
        _profileKey = UniqueKey();
      }
      if (index != 2 && _isMapPanelOpen) {
        _isMapPanelOpen = false;
      }
    });
  }

  void _onMapPanelStateChanged(bool isOpen) {
    setState(() => _isMapPanelOpen = isOpen);
  }

  Future<bool> _checkAuthStatus() async {
    try {
      final localStatus = await AuthService.isLoggedIn();
      if (!localStatus) {
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).clearUser();
        }
        return false;
      }

      final user = await AuthService.getUser();
      if (user != null) {
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).setUser(user);
        }
        return true;
      } else {
        await AuthService.logout();
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).clearUser();
        }
        return false;
      }
    } catch (e) {
      await AuthService.logout();
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).clearUser();
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBarSpot(),
          const SizedBox(height: 0.5),
          Carroussel(),
          const SizedBox(height: 0.3),
          Expanded(child: GalleryPage(showHistory: true)),
        ],
      ),
      const ExplorePage(),
      MapPage(
        key: _mapPageKey, 
        onPanelStateChanged: _onMapPanelStateChanged,
        onNavigateToTab: (index) => setState(() => _selectedIndex = index),
      ),
      const FavorisPage(),
      FutureBuilder<bool>(
        key: _profileKey,
        future: _checkAuthStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final isLoggedIn = snapshot.data ?? false;
          if (isLoggedIn) {
            return const ProfilePage();
          } else {
            return LoginPage(
              onLoginSuccess: () async {
                final spotsProvider = Provider.of<SpotsProvider>(
                  context,
                  listen: false,
                );
                await spotsProvider.refreshAfterLogin();
                setState(() => _profileKey = UniqueKey());
              },
            );
          }
        },
      ),
    ];

    return Scaffold(
      body: Container(
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
      floatingActionButton:
          (_selectedIndex == 2 && _isMapPanelOpen) || _selectedIndex == 4 || _selectedIndex == 0 
          || _selectedIndex == 1 || _selectedIndex == 3
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (_selectedIndex == 2) {
                  _mapPageKey.currentState?.openAddSpotPanel();
                } else {
                  setState(() => _selectedIndex = 2);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _mapPageKey.currentState?.openAddSpotPanel(),
                  );
                }
              },
              tooltip: 'Ajouter un spot',
              child: const Icon(Icons.add),
            ),
    );
  }
}
