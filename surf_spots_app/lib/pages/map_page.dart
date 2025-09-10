import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/pages/spot_detail_page.dart';
import 'package:surf_spots_app/providers/spots_provider.dart';
import 'package:surf_spots_app/widgets/container_forms.dart';
import 'package:surf_spots_app/services/auth_service.dart';
import 'package:surf_spots_app/services/spot_service.dart';

class MapPage extends StatefulWidget {
  final Function(bool)? onPanelStateChanged;

  const MapPage({super.key, this.onPanelStateChanged});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final PanelController _panelController = PanelController();

  // Infos pour le spot sélectionné
  String _selectedSpotTitle = "Aucun spot sélectionné";
  String _selectedSpotDescription =
      "Cliquez sur un marqueur pour voir les détails ici.";
  String _selectedSpotCity = "";

  SurfSpot? _selectedSpot;

  // Variables panel
  bool _isPanelOpen = false;
  bool _isAddingSpot = false;
  bool _isSubmitting = false;
  
  void openAddSpotPanel() {
    setState(() {
      _isAddingSpot = true;
    });
    _panelController.open();
  }

  // Mode GPS
  LatLng? _pickedLocation;
  bool _isPickingLocation = false;
  final TextEditingController _gpsController = TextEditingController();

  // Position initiale de la map
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(47.2180, 1.5528),
    zoom: 5,
  );

  final Set<Marker> _markers = {};

  int? _selectedNiveau;
  int? _selectedDifficulte;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _spotController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<XFile> _images = [];

  final Key _mapKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    fetchSpotsAndMarkers();
  }

  // Méthodes pour gérer les likes avec synchronisation backend
  Future<void> _loadLikeData() async {
    if (_selectedSpot == null) return;
    
    try {
      final spotId = int.parse(_selectedSpot!.id);
      final futures = await Future.wait([
        LikeService.getLikesCount(spotId),
        LikeService.isLiked(spotId),
      ]);
      
      final count = futures[0] as int;
      final isLiked = futures[1] as bool;
      
      if (mounted) {
        setState(() {
          _selectedSpot!.likesCount = count;
          _selectedSpot!.isLiked = isLiked;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des likes: $e');
      if (mounted) {
        setState(() {
          _selectedSpot!.isLiked = false;
          _selectedSpot!.likesCount = 0;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    if (_selectedSpot == null) return;
    
    try {
      // Utiliser directement le Provider qui gère la synchronisation backend
      final spotsProvider = Provider.of<SpotsProvider>(context, listen: false);
      await spotsProvider.toggleFavorite(_selectedSpot!);
      
      // Recharger les données locales depuis le backend pour être sûr
      await _loadLikeData();
    } catch (e) {
      debugPrint('Erreur lors du toggle like: $e');
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Vous devez être connecté pour liker un spot'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> fetchSpotsAndMarkers() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/api/spot/spots'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _markers.clear();
        for (var jsonSpot in data) {
          final gps = jsonSpot['gps'] as String;
          final parts = gps.split(',');
          if (parts.length == 2) {
            final lat = double.tryParse(parts[0].trim());
            final lon = double.tryParse(parts[1].trim());
            if (lat != null && lon != null) {
              final spot = SurfSpot(
                id: jsonSpot['id'].toString(), // Ajoute l'id
                name: jsonSpot['name'],
                city: jsonSpot['city'],
                description: jsonSpot['description'],
                level: int.tryParse(jsonSpot['level'].toString()) ?? 1,
                difficulty:
                    int.tryParse(jsonSpot['difficulty'].toString()) ?? 1,
                imageBase64: jsonSpot['images'] != null
                    ? (jsonSpot['images'] as List)
                          .map((img) => img['image_data'] ?? '')
                          .where((img) => img != '')
                          .cast<String>()
                          .toList()
                    : [],
                userId: jsonSpot['user_id'], // Ajoute le userId
                gps: jsonSpot['gps'] ?? '', 
              );
              _markers.add(
                Marker(
                  markerId: MarkerId(spot.name),
                  position: LatLng(lat, lon),
                  infoWindow: InfoWindow(title: spot.name),
                  onTap: () async {
                    setState(() {
                      _selectedSpot = spot;
                      _selectedSpotTitle = spot.name;
                      _selectedSpotCity = spot.city;
                      _selectedSpotDescription = spot.description;
                      _isAddingSpot = false;
                    });
                    _panelController.open();
                    // Charger les données de likes depuis le backend
                    await _loadLikeData();
                  },
                ),
              );
            }
          }
        }
      });
    }
  }

  Widget buildSpotDetailsPanel() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
          ),
          // Header
          Row(
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    "Informations sur le spot",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (_selectedSpot != null)
                IconButton(
                  icon: Icon(
                    _selectedSpot!.isLiked ?? false
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.blue,
                  ),
                  onPressed: _toggleLike,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedSpotTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.near_me_rounded,
                      size: 18,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedSpotCity,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _selectedSpotDescription,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 3, // Limite à 3 lignes
                  overflow: TextOverflow.ellipsis, // Ajoute "...",
                ),
                const SizedBox(height: 20),
                const Text(
                  "Photo :",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _selectedSpot != null && _selectedSpot!.imageBase64.isNotEmpty
                    ? buildSpotImage(_selectedSpot!.imageBase64[0])
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          // Footer : likes + bouton détails
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_selectedSpot != null)
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.blue, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${_selectedSpot!.likesCount} like${_selectedSpot!.likesCount != 1 ? 's' : ''}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedSpot != null) {
                    // Sauvegarder les références avant les opérations async
                    final navigator = Navigator.of(context);
                    final spotsProvider = Provider.of<SpotsProvider>(context, listen: false);
                    
                    // Marquer le spot comme visité avant d'ouvrir les détails
                    spotsProvider.addToHistory(_selectedSpot!);

                    final result = await navigator.push(
                      MaterialPageRoute(
                        builder: (context) =>
                            SpotDetailPage(spot: _selectedSpot!),
                      ),
                    );

                    if (mounted) {
                      if (result is SurfSpot) {
                        // Le spot a été mis à jour, on met à jour les données locales
                        setState(() {
                          _selectedSpot = result;
                          _selectedSpotTitle = result.name;
                          _selectedSpotDescription = result.description;
                          _selectedSpotCity = result.city;
                        });
                        // Rafraîchit la carte avec les nouvelles données
                        await fetchSpotsAndMarkers();
                      } else if (result == true) {
                        // Le spot a été supprimé
                        setState(() {
                          _selectedSpot = null;
                          _selectedSpotTitle = "Aucun spot sélectionné";
                          _selectedSpotDescription =
                              "Cliquez sur un marqueur pour voir les détails ici.";
                          _selectedSpotCity = "";
                        });
                        _panelController.close();
                        await fetchSpotsAndMarkers();
                      }
                    }
                  }
                },
                child: const Text("Détails"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _validateAndAddSpot() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    if (_formKey.currentState!.validate() &&
        _selectedNiveau != null &&
        _selectedDifficulte != null &&
        _images.isNotEmpty &&
        _pickedLocation != null) {
      setState(() {
        _isSubmitting = true;
      });
      // 1. Envoie le spot au backend
      final spotResponse = await AuthService.authenticatedDio.post(
        '/api/spot/create',
        data: {
          'name': _spotController.text,
          'city': _villeController.text,
          'description': _descriptionController.text,
          'level': _selectedNiveau,
          'difficulty': _selectedDifficulte,
          'gps': "${_pickedLocation!.latitude},${_pickedLocation!.longitude}",
        },
      );

      if (spotResponse.statusCode == 201) {
        final spotData = spotResponse.data;
        final spotId = spotData['id']; // récupère l'ID du spot créé

        // 2. Envoie chaque image au backend
        for (var image in _images) {
          final bytes = await image.readAsBytes();
          final base64Image = base64Encode(bytes);

          try {
            await AuthService.authenticatedDio.post(
              '/api/spot/images',
              data: {'spot_id': spotId, 'image_data': base64Image},
            );
          } catch (e) {
            // Continue with other images even if one fails
            debugPrint('Error uploading image: $e');
          }
        }

        // Recharge les markers depuis la BDD
        await fetchSpotsAndMarkers();

        setState(() {
          _pickedLocation = null; // Supprime le marker bleu
          // Réinitialise la sélection du spot
          _selectedSpot = null;
          _selectedSpotTitle = "Aucun spot sélectionné";
          _selectedSpotDescription =
              "Cliquez sur un marqueur pour voir les détails ici.";
          _selectedSpotCity = "";
          _isSubmitting = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Spot ajouté !')),
          );
        }
        _panelController.close();
      } else {
        setState(() {
          _isSubmitting = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de l\'ajout du spot')),
          );
        }
      }
    } else {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez remplir tous les champs, ajouter au moins une photo et choisir un point GPS',
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> picked = await picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() {
          _images.addAll(picked);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la sélection des images')),
        );
      }
    }
  }

  void _removeImage(XFile image) {
    setState(() {
      _images.remove(image);
    });
  }

  // Affichage de la photo principale du spot
  Widget buildSpotImage(String imagePath) {
    // Si le chemin commence par 'assets/', c'est une image d'asset
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, height: 50, width: 70, fit: BoxFit.cover);
    } else if (imagePath.isNotEmpty) {
      // Si c'est une chaîne base64, on la décode
      try {
        return Image.memory(
          base64Decode(imagePath),
          height: 50,
          width: 70,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return const SizedBox.shrink();
      }
    } else {
      // Sinon, c'est une image locale (fichier)
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SlidingUpPanel(
        controller: _panelController,
        onPanelSlide: (double pos) {
          bool isOpen = pos > 0.1;
          if (isOpen != _isPanelOpen) {
            setState(() {
              _isPanelOpen = isOpen;
            });
            widget.onPanelStateChanged?.call(isOpen);
          }
        },
        onPanelOpened: () => widget.onPanelStateChanged?.call(true),
        onPanelClosed: () => widget.onPanelStateChanged?.call(false),
        panel: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
              child: Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isAddingSpot
                  ? ContainerForms(
                      formKey: _formKey,
                      gpsController: _gpsController,
                      villeController: _villeController,
                      spotController: _spotController,
                      descriptionController: _descriptionController,
                      isSubmitting: _isSubmitting,
                      onPickLocation: () {
                        setState(() {
                          _markers.removeWhere(
                            (marker) => marker.markerId == MarkerId('picked'),
                          );
                          _pickedLocation = null;
                          _isPickingLocation = true;
                          Future.delayed(const Duration(milliseconds: 500), () {
                            _panelController.close();
                          });
                        });
                      },
                      selectedNiveau: _selectedNiveau,
                      selectedDifficulte: _selectedDifficulte,
                      onNiveauChanged: (val) =>
                          setState(() => _selectedNiveau = val),
                      onDifficulteChanged: (val) =>
                          setState(() => _selectedDifficulte = val),
                      onValidate: _validateAndAddSpot,
                      existingImagesBase64: const [], // <-- AJOUTE CETTE LIGNE
                      images: _images,
                      onAddImage: _pickImages,
                      onRemoveImage: _removeImage,
                      onRemoveExistingImage: (_) {}, // <-- AJOUTE CETTE LIGNE
                    )
                  : buildSpotDetailsPanel(),
            ),
          ],
        ),
        body: GoogleMap(
          key: _mapKey, // Ajoute la clé ici
          initialCameraPosition: _initialCameraPosition,
          markers: {
            ..._markers,
            if (_pickedLocation != null)
              Marker(
                markerId: const MarkerId("picked"),
                position: _pickedLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
              ),
          },
          onTap: _isPickingLocation
              ? (LatLng pos) {
                  setState(() {
                    _pickedLocation = pos;
                    _gpsController.text = "${pos.latitude}, ${pos.longitude}";
                    _isPickingLocation =
                        false; // Désactive le mode après sélection
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_panelController.isPanelClosed) {
                        _panelController.open();
                      }
                    });
                  });
                }
              : null,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        minHeight: 50,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
    );
  }
}
