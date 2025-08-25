import 'package:flutter/material.dart';
import 'package:surf_spots_app/widgets/searchbar.dart';
import 'package:surf_spots_app/widgets/grid.dart';

class FavorisPage extends StatelessWidget {
  final String hintText;
  const FavorisPage({
    super.key,
    this.hintText = "Rechercher dans mes favoris...",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder personnalisé pour la page Favoris
          SearchBarSpot(hintText: hintText),
          const SizedBox(height: 0.5),
          const Expanded(child: GalleryPage()),
        ],
      ),
    );
  }
}
