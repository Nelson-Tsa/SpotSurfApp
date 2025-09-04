import 'package:flutter/foundation.dart';
import '../models/surf_spot.dart';
import '../services/spot_service.dart';

class SpotsProvider with ChangeNotifier {
  List<SurfSpot> _allSpots = [];
  List<SurfSpot> _filteredSpots = [];
  String _searchQuery = '';
  bool _isLoading = false;

  // Getters
  List<SurfSpot> get allSpots => _allSpots;
  List<SurfSpot> get filteredSpots => _filteredSpots;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<SurfSpot> get favoriteSpots {
    return _allSpots.where((spot) => spot.isLiked == true).toList();
  }

  List<SurfSpot> get filteredFavorites {
    final favorites = favoriteSpots;
    return SpotService.filterSpots(favorites, _searchQuery);
  }

  // Charger tous les spots depuis l'API
  Future<void> loadSpots() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allSpots = await SpotService.fetchAllSpots();
      _filteredSpots = List.from(_allSpots);
    } catch (e) {
      print('Error loading spots: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtrer les spots
  void searchSpots(String query) {
    _searchQuery = query;
    _filteredSpots = SpotService.filterSpots(_allSpots, query);
    notifyListeners();
  }

  // Toggle favorite (utilise ta logique existante si tu en as une)
  void toggleFavorite(SurfSpot spot) {
    final index = _allSpots.indexWhere(
      (s) => s.name == spot.name && s.city == spot.city,
    );
    if (index != -1) {
      _allSpots[index].isLiked = !(_allSpots[index].isLiked ?? false);

      // Mettre à jour aussi dans la liste filtrée si le spot y existe
      final filteredIndex = _filteredSpots.indexWhere(
        (s) => s.name == spot.name && s.city == spot.city,
      );
      if (filteredIndex != -1) {
        _filteredSpots[filteredIndex].isLiked = _allSpots[index].isLiked;
      }

      notifyListeners();
    }
  }

  // Réinitialiser la recherche
  void clearSearch() {
    _searchQuery = '';
    _filteredSpots = List.from(_allSpots);
    notifyListeners();
  }
}
