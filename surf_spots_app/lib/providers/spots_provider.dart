import 'package:flutter/foundation.dart';
import '../models/surf_spot.dart';
import '../services/spot_service.dart';
import '../services/visited_service.dart';

class SpotsProvider with ChangeNotifier {
  List<SurfSpot> _allSpots = [];
  List<SurfSpot> _filteredSpots = [];

  List<SurfSpot> _history = []; // historique complet
  List<SurfSpot> _filteredHistory = []; // historique filtré pour la search bar

  String _searchQuery = '';
  bool _isLoading = false;

  // --- Getters ---
  List<SurfSpot> get allSpots => _allSpots;
  List<SurfSpot> get filteredSpots => _filteredSpots;
  List<SurfSpot> get history => _filteredHistory; // afficher le filtré
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<SurfSpot> get favoriteSpots =>
      _allSpots.where((spot) => spot.isLiked == true).toList();

  List<SurfSpot> get filteredFavorites {
    final favorites = favoriteSpots;
    return SpotService.filterSpots(favorites, _searchQuery);
  }

  // --- Charger tous les spots ---
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

  // --- Filtrer les spots et l'historique ---
  void searchSpots(String query) {
    _searchQuery = query;

    // Spots normaux
    _filteredSpots = SpotService.filterSpots(_allSpots, query);

    // Historique filtré
    _filteredHistory = _searchQuery.isNotEmpty
        ? SpotService.filterSpots(_history, _searchQuery)
        : List.from(_history);

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredSpots = List.from(_allSpots);
    _filteredHistory = List.from(_history);
    notifyListeners();
  }

  // --- Toggle favorite ---
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

  // --- Historique ---
  Future<void> loadHistory() async {
    try {
      final visited = await VisitedService.getVisited();

      // Utiliser l'id du spot comme clé pour éviter les doublons
      final Map<String, SurfSpot> uniqueMap = {};
      for (var spot in visited.reversed) {
        uniqueMap[spot.id] = spot;
      }

      _history = uniqueMap.values.toList().reversed.toList();

      // Associer les images correctes des spots principaux
      _history = _history.map((spot) {
        final original = _allSpots.firstWhere(
          (s) => s.id == spot.id,
          orElse: () => spot,
        );
        return original;
      }).toList();

      // Filtrage initial
      _filteredHistory = _searchQuery.isNotEmpty
          ? SpotService.filterSpots(_history, _searchQuery)
          : List.from(_history);

      notifyListeners();
    } catch (e) {
      print('Error loading visited: $e');
    }
  }

  Future<void> addToHistory(SurfSpot spot) async {
    try {
      final int id = int.parse(spot.id);
      await VisitedService.addVisited(id);

      // Supprimer l'ancienne entrée si déjà présente
      _history.removeWhere((s) => s.id == spot.id);
      _history.insert(0, spot);

      // Associer l'image correcte si disponible
      final original = _allSpots.firstWhere(
        (s) => s.id == spot.id,
        orElse: () => spot,
      );
      _history[0] = original;

      // Mettre à jour le filtré selon la search bar
      _filteredHistory = _searchQuery.isNotEmpty
          ? SpotService.filterSpots(_history, _searchQuery)
          : List.from(_history);

      notifyListeners();
    } catch (e) {
      print('Error adding to visited: $e');
    }
  }

  Future<void> removeFromHistory(dynamic visitedId) async {
    try {
      final int id = visitedId is String ? int.parse(visitedId) : visitedId;
      await VisitedService.deleteVisited(id);
      _history.removeWhere((s) => s.id == id);

      _filteredHistory = _searchQuery.isNotEmpty
          ? SpotService.filterSpots(_history, _searchQuery)
          : List.from(_history);

      notifyListeners();
    } catch (e) {
      print('Error removing from visited: $e');
    }
  }

  Future<void> refreshAfterLogin() async {
    await loadHistory();
  }
}
