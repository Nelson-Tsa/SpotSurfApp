import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../models/surf_spot.dart';
import '../services/spot_service.dart';
import '../services/visited_service.dart';
import '../services/auth_service.dart';

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
      
      // Charger l'état des likes pour chaque spot
      await _loadLikesState();
    } catch (e) {
      developer.log('Error loading spots: $e', name: 'SpotsProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Charger l'état des likes pour tous les spots ---
  Future<void> _loadLikesState() async {
    // Vérifier si l'utilisateur est connecté avant de faire des appels API
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      developer.log('Utilisateur non connecté - skip chargement des likes', name: 'SpotsProvider');
      return;
    }
    
    try {
      for (int i = 0; i < _allSpots.length; i++) {
        final spotId = int.parse(_allSpots[i].id);
        
        // Charger le compteur et l'état du like en parallèle
        final futures = await Future.wait([
          LikeService.getLikesCount(spotId),
          LikeService.isLiked(spotId),
        ]);
        
        final count = futures[0] as int;
        final isLiked = futures[1] as bool;
        
        _allSpots[i].likesCount = count;
        _allSpots[i].isLiked = isLiked;
        
        // Mettre à jour aussi dans filteredSpots
        final filteredIndex = _filteredSpots.indexWhere((s) => s.id == _allSpots[i].id);
        if (filteredIndex != -1) {
          _filteredSpots[filteredIndex].likesCount = count;
          _filteredSpots[filteredIndex].isLiked = isLiked;
        }
      }
    } catch (e) {
      developer.log('Erreur lors du chargement des likes: $e', name: 'SpotsProvider');
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

  // --- Toggle favorite avec synchronisation backend ---
  Future<void> toggleFavorite(SurfSpot spot) async {
    // Vérifier si l'utilisateur est connecté
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      developer.log('Utilisateur non connecté - impossible de liker', name: 'SpotsProvider');
      return;
    }
    
    try {
      final spotId = int.parse(spot.id);
      final newLikedState = await LikeService.toggleLike(spotId);
      
      final index = _allSpots.indexWhere((s) => s.id == spot.id);
      if (index != -1) {
        _allSpots[index].isLiked = newLikedState;

        final filteredIndex = _filteredSpots.indexWhere((s) => s.id == spot.id);
        if (filteredIndex != -1) {
          _filteredSpots[filteredIndex].isLiked = newLikedState;
        }

        // Mettre à jour le compteur de likes
        final count = await LikeService.getLikesCount(spotId);
        _allSpots[index].likesCount = count;
        if (filteredIndex != -1) {
          _filteredSpots[filteredIndex].likesCount = count;
        }

        notifyListeners();
      }
    } catch (e) {
      developer.log('Erreur lors du toggle favorite: $e', name: 'SpotsProvider');
      // En cas d'erreur, ne pas changer l'état local
    }
  }

  // --- Historique ---
  Future<void> loadHistory() async {
    // Vérifier si l'utilisateur est connecté
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      developer.log('Utilisateur non connecté - skip chargement historique', name: 'SpotsProvider');
      return;
    }
    
    try {
      final visited = await VisitedService.getVisited();

      // Utiliser l'id du spot comme clé pour éviter les doublons
      final Map<String, SurfSpot> uniqueMap = {};
      for (var spot in visited.reversed) {
        uniqueMap[spot.id] = spot;
      }

      _history = uniqueMap.values.toList().reversed.toList();

      // --- Limiter à 20 spots (clean automatique à la reconnexion) ---
      if (_history.length > 20) {
        final toRemove = _history.sublist(20); // les plus vieux
        _history = _history.sublist(0, 20);

        for (var spot in toRemove) {
          final removedId = int.tryParse(spot.id);
          if (removedId != null) {
            await VisitedService.deleteVisited(removedId);
            developer.log("🗑️ Cleaned old spot from DB on load: ${spot.id}", name: 'SpotsProvider');
          }
        }
      }

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

      developer.log("✅ History loaded with ${_history.length} spots", name: 'SpotsProvider');

      notifyListeners();
    } catch (e) {
      developer.log('Error loading visited: $e', name: 'SpotsProvider');
    }
  }

  Future<void> addToHistory(SurfSpot spot) async {
    // Vérifier si l'utilisateur est connecté
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      developer.log('Utilisateur non connecté - skip ajout historique', name: 'SpotsProvider');
      return;
    }
    
    try {
      final int id = int.parse(spot.id);
      await VisitedService.addVisited(id);
      developer.log("➕ Added spot to visited: ${spot.id}", name: 'SpotsProvider');

      // Supprimer l'ancienne entrée si déjà présente
      _history.removeWhere((s) => s.id == spot.id);
      _history.insert(0, spot);

      // --- Limiter à 20 spots (en mémoire et en DB) ---
      if (_history.length > 20) {
        final removedSpot = _history.removeLast(); // supprime le plus ancien
        final removedId = int.tryParse(removedSpot.id);
        if (removedId != null) {
          await VisitedService.deleteVisitedBySpot(
            removedId,
          ); // <- ici tu appelles la nouvelle route
          developer.log(
            "🗑️ Removed oldest spot to keep history at 5: ${removedSpot.id}", name: 'SpotsProvider',
          );
        }
      }

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

      developer.log("📜 Current history length: ${_history.length}", name: 'SpotsProvider');

      notifyListeners();
    } catch (e) {
      developer.log('Error adding to visited: $e', name: 'SpotsProvider');
    }
  }

  Future<void> removeFromHistory(dynamic visitedId) async {
    // Vérifier si l'utilisateur est connecté
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      developer.log('Utilisateur non connecté - skip suppression historique', name: 'SpotsProvider');
      return;
    }
    
    try {
      final int id = visitedId is String ? int.parse(visitedId) : visitedId;
      await VisitedService.deleteVisited(id);
      _history.removeWhere((s) => s.id == id);

      _filteredHistory = _searchQuery.isNotEmpty
          ? SpotService.filterSpots(_history, _searchQuery)
          : List.from(_history);

      developer.log("🗑️ Manually removed spot from history: $id", name: 'SpotsProvider');

      notifyListeners();
    } catch (e) {
      developer.log('Error removing from visited: $e', name: 'SpotsProvider');
    }
  }

  Future<void> refreshAfterLogin() async {
    await loadHistory();
  }
}
