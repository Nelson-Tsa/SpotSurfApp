import 'package:flutter/material.dart';
import 'package:surf_spots_app/routes.dart';
import 'package:surf_spots_app/widgets/navbar.dart';
import 'package:surf_spots_app/widgets/carroussel.dart';
import 'package:surf_spots_app/widgets/tittle.dart';
import 'package:surf_spots_app/widgets/searchbar.dart';
import 'package:surf_spots_app/widgets/counter_display.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  late final List<Widget> _pages = [
    // Page "Accueil" avec carrousel, grille, compteur
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Tittle(),
        const SearchBarSpot(),
        const Carroussel(),
        const SizedBox(height: 23),
        Expanded(child: GalleryPage()),
        const SizedBox(height: 23),
        CounterDisplay(count: _counter),
        const SizedBox(height: 23),
      ],
    ),
    const Center(child: Text('Explore', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Carte', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Favoris', style: TextStyle(fontSize: 24))),
    // Profil page avec navigation vers Login et Register
    Column(
      children: [
        const SizedBox(height: 23),
        const Text('Profil', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 23),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Se connecter'),
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
              ListTile(
                leading: const Icon(Icons.app_registration),
                title: const Text('S\'inscrire'),
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),
            ],
          ),
        ),
      ],
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Navbar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'IncrÃ©menter',
        child: const Icon(Icons.add),
      ),
    );
  }
}
