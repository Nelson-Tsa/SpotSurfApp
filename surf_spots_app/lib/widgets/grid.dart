import 'package:flutter/material.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/widgets/spot_card.dart';
import 'package:surf_spots_app/services/spot_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GalleryPage extends StatefulWidget {
  final bool showFavoritesOnly;

  const GalleryPage({super.key, this.showFavoritesOnly = false});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<SurfSpot> spots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSpots();
  }

  Future<void> fetchSpots() async {
    try {
      if (widget.showFavoritesOnly) {
        // Récupérer les favoris de l'utilisateur
        print('Chargement des favoris...');
        final favoriteSpots = await LikeService.getUserFavorites();
        print('Favoris reçus: ${favoriteSpots.length}');
        setState(() {
          spots = favoriteSpots;
          isLoading = false;
        });
      } else {
        // Récupérer tous les spots
        final response = await http.get(
          Uri.parse('http://10.0.2.2:4000/api/spot/spots'),
        );
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            spots = data
                .map(
                  (json) => SurfSpot(
                    id: json['id'].toString(),
                    userId: json['user_id'],
                    name: json['name'],
                    city: json['city'],
                    level: int.tryParse(json['level'].toString()) ?? 1,
                    difficulty:
                        int.tryParse(json['difficulty'].toString()) ?? 1,
                    description: json['description'],
                    imageBase64: json['images'] != null
                        ? (json['images'] as List)
                              .map((img) => img['image_data'] ?? '')
                              .where((img) => img != '')
                              .cast<String>()
                              .toList()
                        : [],
                  ),
                )
                .toList();
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des spots: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (spots.isEmpty && widget.showFavoritesOnly) {
      return const Center(
        child: Text(
          'Aucun spot dans vos favoris',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(15.0),
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
