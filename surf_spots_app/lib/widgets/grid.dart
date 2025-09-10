import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_spots_app/widgets/spot_card.dart';
import '../providers/spots_provider.dart';
import '../models/surf_spot.dart';

class GalleryPage extends StatefulWidget {
  final bool showOnlyFavorites;
  final bool showHistory;

  const GalleryPage({
    super.key,
    this.showOnlyFavorites = false,
    this.showHistory = false,
  });

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<SpotsProvider>(context, listen: false);

      // Charger les spots uniquement si on est dans les favoris ou l'historique
      if (widget.showOnlyFavorites || widget.showHistory) {
        await provider.loadSpots();
      } else {
        // Pour la compatibilité avec l'ancienne logique
        await provider.loadSpots();
      }

      if (widget.showHistory) {
        await provider.loadHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpotsProvider>(
      builder: (context, spotsProvider, child) {
        if (spotsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Déterminer les spots à afficher
        List<SurfSpot> spotsToShow;

        if (widget.showHistory) {
          spotsToShow = spotsProvider.history;
        } else if (widget.showOnlyFavorites) {
          spotsToShow = spotsProvider.filteredFavorites;
        } else {
          // Explore page : n'affiche la grid que si une recherche est tapée
          if (spotsProvider.searchQuery.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tapez dans la barre de recherche pour afficher des spots',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          spotsToShow = spotsProvider.filteredSpots;
        }

        // Si aucun spot trouvé après filtre
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
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.showOnlyFavorites
                      ? spotsProvider.favoriteSpots.isEmpty
                            ? 'Aucun favori pour le moment'
                            : 'Aucun favori trouvé pour "${spotsProvider.searchQuery}"'
                      : widget.showHistory
                      ? 'Aucun spot dans votre historique'
                      : 'Aucun spot trouvé pour "${spotsProvider.searchQuery}"',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Affichage de la grid
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
              childAspectRatio: 0.65,
            ),
            itemCount: spotsToShow.length,
            itemBuilder: (context, index) {
              final spot = spotsToShow[index];
              return SpotCard(
                spot: spot,
                onFavoriteToggle: () {
                  spotsProvider.toggleFavorite(spot);
                },
              );
            },
          ),
        );
      },
    );
  }
}
