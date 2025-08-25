import 'package:flutter/material.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/widgets/spot_card.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<SurfSpot> spots = [
      SurfSpot(
        name: 'La Gravière',
        city: 'Hossegor, France',
        level: 2,
        difficulty: 2,
        description: 'Hossegor, France',
        imageUrls: ['assets/images/la_graviere.jpg'],
      ),
      SurfSpot(
        name: 'Pipeline',
        city: 'Oahu, Hawaï',
        level: 2,
        difficulty: 2,
        description: 'Oahu, Hawaï',
        imageUrls: ['assets/images/pipeline.jpg'],
      ),
      SurfSpot(
        name: 'Uluwatu',
        city: 'Bali, Indonésie',
        level: 2,
        difficulty: 2,
        description: 'Bali, Indonésie',
        imageUrls: ['assets/images/uluwatu.jpg'],
      ),
      SurfSpot(
        name: 'Jeffreys Bay',
        city: 'Afrique du Sud',
        level: 2,
        difficulty: 2,
        description: 'Afrique du Sud',
        imageUrls: ['assets/images/jeffreys_bay.jpg'],
      ),
      SurfSpot(
        name: 'Teahupo\'o',
        city: 'Tahiti, Polynésie',
        level: 2,
        difficulty: 2,
        description: 'Tahiti, Polynésie',
        imageUrls: ['assets/images/teahupoo.jpg'],
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200), // semi-transparent
        borderRadius: BorderRadius.circular(15.0), // arrondis
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: spots.length,
        itemBuilder: (context, index) {
          final spot = spots[index];
          return SpotCard(spot: spot);
        },
      ),
    );
  }
}
