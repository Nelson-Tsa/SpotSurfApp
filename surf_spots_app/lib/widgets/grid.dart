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
