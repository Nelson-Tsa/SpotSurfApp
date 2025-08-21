import 'package:flutter/material.dart';
import 'package:surf_spots_app/widgets/carroussel.dart';
import 'package:surf_spots_app/widgets/tittle.dart'; // Importer le widget Tittle
import 'package:surf_spots_app/widgets/searchbar.dart'; // Importer le widget SearchBar
import 'package:surf_spots_app/widgets/counter_display.dart'; // Importer le widget d'affichage
import 'package:surf_spots_app/widgets/grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Ce widget est la racine de votre application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surf Spots App',
      theme: ThemeData(
        // C'est le thème de votre application.
        //
        // ESSAYEZ CECI : Essayez d'exécuter votre application avec "flutter run". Vous verrez
        // que l'application a une barre d'outils violette. Ensuite, sans quitter l'application,
        // essayez de changer la seedColor dans le colorScheme ci-dessous en Colors.green
        // puis appelez le "hot reload" (enregistrez vos modifications ou appuyez sur le bouton
        // "hot reload" dans un IDE compatible avec Flutter, ou appuyez sur "r" si vous avez utilisé
        // la ligne de commande pour démarrer l'application).
        //
        // Notez que le compteur n'est pas revenu à zéro ; l'état de l'application
        // n'est pas perdu pendant le rechargement. Pour réinitialiser l'état, utilisez plutôt
        // le redémarrage à chaud (hot restart).
        //
        // Cela fonctionne aussi pour le code, pas seulement pour les valeurs : la plupart des modifications de code peuvent être
        // testées avec un simple rechargement à chaud (hot reload).
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 91, 188, 237),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 242, 211, 154),
      ),
      home: const MyHomePage(title: 'Surf Spots App'),
      debugShowCheckedModeBanner: false,
      // ESSAYEZ CECI : Essayez de changer le titre ici pour quelque
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // Ce widget est la page d'accueil de votre application. Il est stateful, ce qui signifie
  // qu'il a un objet State (défini ci-dessous) qui contient des champs qui affectent
  // son apparence.

  // Cette classe est la configuration de l'état. Elle contient les valeurs (dans ce
  // cas le titre) fournies par le parent (dans ce cas le widget App) et
  // utilisées par la méthode build de l'état. Les champs dans une sous-classe de Widget sont
  // toujours marqués comme "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // L'état et la logique restent ici
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cette méthode est réexécutée chaque fois que setState est appelé, par exemple comme fait
    // par la méthode _incrementCounter ci-dessus.
    //
    // Le framework Flutter a été optimisé pour rendre la réexécution des méthodes build
    // rapide, de sorte que vous pouvez simplement reconstruire tout ce qui a besoin d'être mis à jour plutôt
    // que d'avoir à modifier individuellement des instances de widgets.
    return Scaffold(
      appBar: AppBar(
        // ESSAYEZ CECI : Essayez de changer la couleur ici pour une couleur spécifique (peut-être
        // Colors.amber ?) et déclenchez un hot reload pour voir la couleur de l'AppBar
        // changer tandis que les autres couleurs restent les mêmes.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Ici, nous prenons la valeur de l'objet MyHomePage qui a été créé par
        // la méthode App.build, et nous l'utilisons pour définir le titre de notre barre d'applications.
        title: Text(widget.title),
        centerTitle: true,
      ),
      // Le corps principal de votre application
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Tittle(),
          const SearchBarSpot(),
          const Carroussel(),
          const SizedBox(height: 23),
          // On ajoute un Expanded pour que le compteur prenne la place restante
          Expanded(child: GalleryPage()),
          const SizedBox(height: 23),
          CounterDisplay(
            count: _counter, // On passe la valeur actuelle du compteur
          ),
          const SizedBox(height: 23),
        ],
      ),
      // Le bouton est une propriété du Scaffold, pas du body
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter, // Il appelle la fonction définie ici
        tooltip: 'Incrémenter',
        child: const Icon(Icons.add),
      ),
    );
  }
}
