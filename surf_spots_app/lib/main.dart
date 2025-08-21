import 'package:flutter/material.dart';
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
        // C'est le thème de votre application.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 91, 188, 237),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 242, 211, 154),
      ),
      home: const HomeScreen(title: 'Surf Spots App'),
      debugShowCheckedModeBanner: false,
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
    const Center(child: Text('Profil', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // ESSAYEZ CECI : Essayez de changer la couleur ici pour une couleur spécifique (peut-être
      //   // Colors.amber ?) et déclenchez un hot reload pour voir la couleur de l'AppBar
      //   // changer tandis que les autres couleurs restent les mêmes.
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   // Ici, nous prenons la valeur de l'objet MyHomePage qui a été créé par
      //   // la méthode App.build, et nous l'utilisons pour définir le titre de notre barre d'applications.
      //   title: Text(widget.title),
      //   centerTitle: true,
      // ),
      // Le corps principal de votre application
      body: Container(
        // 1. Définir la décoration du conteneur pour y mettre l'image
        decoration: const BoxDecoration(
          image: DecorationImage(
            // 2. Charger l'image depuis les assets
            image: AssetImage(
              "assets/images/background.png",
            ), // <-- METTEZ LE NOM DE VOTRE IMAGE ICI
            // 3. Assurer que l'image couvre tout l'écran
            fit: BoxFit.cover,
          ),
        ),
        // 4. Le contenu de la page vient ici, par-dessus l'image
        child: Padding(
          padding: const EdgeInsets.only(top:40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tittle(),
              SearchBarSpot(),
              Carroussel(),
              // On ajoute un Expanded pour que le compteur prenne la place restante
              Expanded(
                child: CounterDisplay(
                  count: _counter, // On passe la valeur actuelle du compteur
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Le bouton est une propriété du Scaffold, pas du body
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'IncrÃ©menter',
        child: const Icon(Icons.add),
      ),
    );
  }
}