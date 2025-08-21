import 'package:flutter/material.dart';
import 'package:surf_spots_app/models/surf_spot.dart';

class SpotCard extends StatelessWidget {
  final SurfSpot spot;

  const SpotCard({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.surfing, size: 40, color: Colors.blue),
          const SizedBox(height: 8),
          Text(spot.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(spot.description),
        ],
      ),
    );
  }
}
