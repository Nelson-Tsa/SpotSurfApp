import 'package:flutter/foundation.dart';
import '../models/surf_spot.dart';
import '../services/spot_service.dart';
import '../services/visited_service.dart';

class SpotsProvider with ChangeNotifier {
  List<SurfSpot> _allSpots = [];
  List<SurfSpot> _filteredSpots = [];
  List<SurfSpot> _history = [];
  String _searchQuery = '';
  bool _isLoading = false;

  // Getters
  List<SurfSpot> get allSpots => _allSpots;
  List<SurfSpot> get filteredSpots => _filteredSpots;
  List<SurfSpot> get history => _history;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<SurfSpot> get favoriteSpots =>
      _allSpots.where((spot) => spot.isLiked == true).toList();

  List<SurfSpot> get filteredFavorites =>
      SpotService.filterSpots(favoriteSpots, _searchQuery);

  // Charger tous les spots
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

  // Toggle favorite
  void toggleFavorite(SurfSpot spot) {
    final index = _allSpots.indexWhere((s) => s.id == spot.id);
    if (index != -1) {
      _allSpots[index].isLiked = !(_allSpots[index].isLiked ?? false);

      final filteredIndex = _filteredSpots.indexWhere((s) => s.id == spot.id);
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

  // --- Historique ---

  Future<void> loadHistory() async {
    try {
      _history = await VisitedService.getVisited();
      notifyListeners();
    } catch (e) {
      print('Error loading visited: $e');
    }
  }

  Future<void> addToHistory(SurfSpot spot) async {
    try {
      // Supprimer l'ancien doublon
      _history.removeWhere((s) => s.id == spot.id);

      final int id = int.parse(spot.id);
      await VisitedService.addVisited(id);

      // Ajouter en première position
      _history.insert(0, spot);
      notifyListeners();
    } catch (e) {
      print('Error adding to visited: $e');
    }
  }

  Future<void> removeFromHistory(dynamic visitedId) async {
    try {
      final int id = visitedId is String ? int.parse(visitedId) : visitedId;
      await VisitedService.deleteVisited(id);
      _history.removeWhere((s) => s.id == visitedId.toString());
      notifyListeners();
    } catch (e) {
      print('Error removing from visited: $e');
    }
  }

  Future<void> refreshAfterLogin() async {
    await loadHistory();
  }
}
