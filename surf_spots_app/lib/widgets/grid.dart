import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_spots_app/widgets/spot_card.dart';
import '../providers/spots_provider.dart';
import '../models/surf_spot.dart';

class GalleryPage extends StatefulWidget {
  final bool showOnlyFavorites;

  const GalleryPage({super.key, this.showOnlyFavorites = false});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  void initState() {
    super.initState();
    // Charger les spots au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SpotsProvider>(context, listen: false).loadSpots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpotsProvider>(
      builder: (context, spotsProvider, child) {
        if (spotsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Déterminer quels spots afficher
        List<SurfSpot> spotsToShow;
        if (widget.showOnlyFavorites) {
          spotsToShow = spotsProvider.filteredFavorites;
        } else {
          spotsToShow = spotsProvider.filteredSpots;
        }

        if (spotsToShow.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.showOnlyFavorites
                      ? Icons.favorite_border
                      : Icons.search_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.showOnlyFavorites
                      ? spotsProvider.favoriteSpots.isEmpty
                            ? 'Aucun favori pour le moment'
                            : 'Aucun favori trouvé pour "${spotsProvider.searchQuery}"'
                      : spotsProvider.searchQuery.isEmpty
                      ? 'Aucun spot trouvé'
                      : 'Aucun spot trouvé pour "${spotsProvider.searchQuery}"',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
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
            itemCount: spotsToShow.length,
            itemBuilder: (context, index) {
              final spot = spotsToShow[index];
              return SpotCard(
                spot: spot,
                // Si ton SpotCard n'a pas encore onFavoriteToggle, ajoute-le
                // onFavoriteToggle: () {
                //   spotsProvider.toggleFavorite(spot);
                // },
              );
            },
          ),
        );
      },
    );
  }
}
