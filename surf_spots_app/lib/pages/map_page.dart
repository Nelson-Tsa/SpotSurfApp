import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/pages/spot_detail_page.dart';
import 'package:surf_spots_app/widgets/container_forms.dart';
import 'dart:io';

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
  int _selectedSpotLevel = 0;
  int _selectedSpotDifficulty = 0;

  SurfSpot? _selectedSpot;

  bool _nouveauMarker = false;

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

  List<XFile> _images = [];

  Key _mapKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    fetchSpotsAndMarkers(); // Ajoute cet appel ici

    // Exemple de spot
    _markers.add(
      Marker(
        markerId: const MarkerId('Teahupoo'),
        position: const LatLng(-17.8473, -149.2671),
        infoWindow: const InfoWindow(title: 'Teahupoo'),
        onTap: () {
          setState(() {
            _isAddingSpot = false;
            _selectedSpotTitle = 'Teahupoo Wave';
            _selectedSpotCity = 'Tahiti, Polynésie';
            _selectedSpotLevel = 2;
            _selectedSpotDifficulty = 2;
            _selectedSpotDescription =
                'L\'une des vagues les plus puissantes et célèbres au monde, située en Polynésie française.';
            _selectedSpot = SurfSpot(
              id: 'teahupoo', // Ajoute un id unique
              name: 'Teahupoo Wave',
              city: 'Tahiti, Polynésie',
              level: 1,
              difficulty: 2,
              description:
                  'L\'une des vagues les plus puissantes et célèbres au monde, située en Polynésie française.',
              imageBase64: [
                'assets/images/teahupoo.jpg',
                'assets/images/teahupoo2.jpg',
                'assets/images/teahupoo3.jpg',
              ],
              userId: '1', // ou l’id du créateur/admin
              isLiked: false,
            );
          });
          _panelController.open();
        },
      ),
    );
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
                difficulty: int.tryParse(jsonSpot['difficulty'].toString()) ?? 1,
                imageBase64: jsonSpot['images'] != null
                    ? (jsonSpot['images'] as List)
                          .map((img) => img['image_data'] ?? '')
                          .where((img) => img != '')
                          .cast<String>()
                          .toList()
                    : [],
                userId: jsonSpot['user_id'].toString(), // Ajoute le userId
              );
              _markers.add(
                Marker(
                  markerId: MarkerId(spot.name),
                  position: LatLng(lat, lon),
                  infoWindow: InfoWindow(title: spot.name),
                  onTap: () {
                    setState(() {
                      _selectedSpot = spot;
                      _selectedSpotTitle = spot.name;
                      _selectedSpotCity = spot.city;
                      _selectedSpotLevel = spot.level;
                      _selectedSpotDifficulty = spot.difficulty;
                      _selectedSpotDescription = spot.description;
                      _isAddingSpot = false;
                    });
                    _panelController.open();
                  },
                ),
              );
            }
          }
        }
        // _mapKey = UniqueKey(); // Retire cette ligne ici
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
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            // child: Container(
            //   width: 40,
            //   height: 5,
            //   decoration: BoxDecoration(
            //     color: Colors.grey[300],
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            // ),
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
                  onPressed: () {
                    setState(() {
                      _selectedSpot!.isLiked =
                          !(_selectedSpot!.isLiked ?? false);
                    });
                  },
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
                      "${_selectedSpot!.isLiked == true ? '1' : '0'} like${_selectedSpot!.isLiked == true ? '' : 's'}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: () {
                  if (_selectedSpot != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SpotDetailPage(spot: _selectedSpot!),
                      ),
                    );
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
    if (_isSubmitting) return; // Empêche les doubles clics

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
      final spotResponse = await http.post(
        Uri.parse('http://10.0.2.2:4000/api/spot/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _spotController.text,
          'city': _villeController.text,
          'description': _descriptionController.text,
          'level': _selectedNiveau,
          'difficulty': _selectedDifficulte,
          'gps': "${_pickedLocation!.latitude},${_pickedLocation!.longitude}",
          'user_id': 1, // ou l'ID de l'utilisateur connecté
        }),
      );

      if (spotResponse.statusCode == 201) {
        final spotData = jsonDecode(spotResponse.body);
        final spotId = spotData['id']; // récupère l'ID du spot créé

        // 2. Envoie chaque image au backend
        for (var image in _images) {
          final bytes = await image.readAsBytes();
          final base64Image = base64Encode(bytes);

          await http.post(
            Uri.parse('http://10.0.2.2:4000/api/spot/images'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'spot_id': spotId, 'image_data': base64Image}),
          );
        }

        // Recharge les markers depuis la BDD
        await fetchSpotsAndMarkers();

        setState(() {
          _pickedLocation = null; // Supprime le marker bleu
          _nouveauMarker = false;
          // Réinitialise la sélection du spot
          _selectedSpot = null;
          _selectedSpotTitle = "Aucun spot sélectionné";
          _selectedSpotDescription =
              "Cliquez sur un marqueur pour voir les détails ici.";
          _selectedSpotCity = "";
          _selectedSpotLevel = 0;
          _selectedSpotDifficulty = 0;
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Spot ajouté !')));
        _panelController.close();
      } else {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout du spot')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez remplir tous les champs, ajouter au moins une photo et choisir un point GPS',
          ),
        ),
      );
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
      print('Erreur lors de la sélection des images : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection des images')),
      );
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
                      images: _images, // AJOUTE CET ARGUMENT
                      onAddImage: _pickImages, // AJOUTE CET ARGUMENT
                      onRemoveImage: _removeImage, // AJOUTE CET ARGUMENT
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
                    _nouveauMarker = true;
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
