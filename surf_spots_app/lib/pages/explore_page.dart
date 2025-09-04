import 'package:flutter/material.dart';
import 'package:surf_spots_app/widgets/searchbar.dart';
import 'package:surf_spots_app/widgets/grid.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBarSpot(hintText: 'Rechercher un spot...'),
          SizedBox(height: 0.5),
          Expanded(child: GalleryPage(showOnlyFavorites: false)),
        ],
      ),
    );
  }
}
