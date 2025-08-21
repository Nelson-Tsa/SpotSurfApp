import 'package:flutter/material.dart';
import 'package:surf_spots_app/models/surf_spot.dart';

class SpotCard extends StatelessWidget {
  final SurfSpot spot;

  const SpotCard({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      clipBehavior: Clip
          .antiAlias, // Pour que l'image respecte les coins arrondis de la carte
      child: Column(
        crossAxisAlignment: CrossAxisAlignment
            .stretch, // Pour que l'image prenne toute la largeur
        children: [
          Expanded(
            child: Image.asset(
              spot.imageUrl,
              fit: BoxFit
                  .cover, // Pour que l'image remplisse l'espace disponible
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  spot.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(spot.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
