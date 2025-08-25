import 'package:flutter/material.dart';
import 'package:surf_spots_app/widgets/searchbar.dart';
import 'package:surf_spots_app/widgets/grid.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // pour ne pas écraser le fond
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SearchBarSpot(),
          SizedBox(height: 0.5), // Espace entre les widgets
          // espacement entre SearchBar et la grille
          Expanded(child: GalleryPage()), // la grille occupe le reste
        ],
      ),
    );
  }
}
