import 'package:flutter/material.dart';
import 'package:surf_spots_app/models/surf_spot.dart'; // Importer le modèle
import 'package:surf_spots_app/widgets/spot_card.dart'; // Importer la nouvelle carte

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<SurfSpot> _spots = [
      SurfSpot(
        name: 'La Gravière',
        description: 'Hossegor, France',
        imageUrl: 'assets/images/la_graviere.jpg',
      ),
      SurfSpot(
        name: 'Pipeline',
        description: 'Oahu, Hawaï',
        imageUrl: 'assets/images/pipeline.jpg',
      ),
      SurfSpot(
        name: 'Uluwatu',
        description: 'Bali, Indonésie',
        imageUrl: 'assets/images/uluwatu.jpg',
      ),
      SurfSpot(
        name: 'Jeffreys Bay',
        description: 'Afrique du Sud',
        imageUrl: 'assets/images/jeffreys_bay.jpg',
      ),
      SurfSpot(
        name: 'Teahupo\'o',
        description: 'Tahiti, Polynésie',
        imageUrl: 'assets/images/teahupoo.jpg',
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // nombre de colonnes
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _spots.length,
      itemBuilder: (context, index) {
        final spot = _spots[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.asset(
                    spot.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
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
      },
    );
  }
}
