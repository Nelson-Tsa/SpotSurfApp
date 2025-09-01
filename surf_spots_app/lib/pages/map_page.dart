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

  // Variables panel
  bool _isPanelOpen = false;
  bool _isAddingSpot = false;
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

  @override
  void initState() {
    super.initState();

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
              name: 'Teahupoo Wave',
              city: 'Tahiti, Polynésie',
              level: 1,
              difficulty: 2,
              description:
                  'L\'une des vagues les plus puissantes et célèbres au monde, située en Polynésie française.',
              imageUrls: [
                'assets/images/teahupoo.jpg',
                'assets/images/teahupoo2.jpg',
                'assets/images/teahupoo3.jpg',
              ],
              isLiked: false,
            );
          });
          _panelController.open();
        },
      ),
    );
  }

  Widget buildSpotDetailsPanel() {
    return Column(
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
                    _selectedSpot!.isLiked = !(_selectedSpot!.isLiked ?? false);
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
              ),
              const SizedBox(height: 20),
              const Text(
                "Photo :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _selectedSpot != null && _selectedSpot!.imageUrls.isNotEmpty
                  ? buildSpotImage(_selectedSpot!.imageUrls[0])
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
    );
  }

  void _validateAndAddSpot() {
    if (_formKey.currentState!.validate() &&
        _selectedNiveau != null &&
        _selectedDifficulte != null &&
        _images.isNotEmpty && // Au moins une photo
        _pickedLocation !=
            null // Point GPS sélectionné
            ) {
      // Crée un nouvel objet SurfSpot
      final newSpot = SurfSpot(
        name: _spotController.text,
        city: _villeController.text,
        description: _descriptionController.text,
        level: _selectedNiveau ?? 1,
        difficulty: _selectedDifficulte ?? 1,
        imageUrls: _images.map((img) => img.path).toList(),
        isLiked: false,
      );

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(DateTime.now().toString()),
            position: _pickedLocation!,
            infoWindow: InfoWindow(
              title: newSpot.name,
              snippet:
                  "${newSpot.city}\nNiveau: ${newSpot.level} | Difficulté: ${newSpot.difficulty}\n${newSpot.description}",
            ),
            onTap: () {
              setState(() {
                _selectedSpot = newSpot;
                _selectedSpotTitle = newSpot.name;
                _selectedSpotCity = newSpot.city;
                _selectedSpotLevel = newSpot.level;
                _selectedSpotDifficulty = newSpot.difficulty;
                _selectedSpotDescription = newSpot.description;
                _isAddingSpot = false;
              });
              _panelController.open();
            },
          ),
        );
        _pickedLocation = null;
        _isAddingSpot = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Spot ajouté !')));
      _panelController.close();
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
    } else {
      // Sinon, c'est une image locale (fichier)
      return Image.file(
        File(imagePath),
        height: 50,
        width: 70,
        fit: BoxFit.cover,
      );
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
        panel: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isAddingSpot
              ? ContainerForms(
                  formKey: _formKey,
                  gpsController: _gpsController,
                  villeController: _villeController,
                  spotController: _spotController,
                  descriptionController: _descriptionController,
                  onPickLocation: () {
                    setState(() {
                      _isPickingLocation = true;
                      _panelController.close();
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
        body: GoogleMap(
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
          onTap: (LatLng pos) {
            setState(() {
              _pickedLocation = pos;
              _gpsController.text = "${pos.latitude}, ${pos.longitude}";
              if (_panelController.isPanelOpen) {
                _panelController.close();
              }
            });
          },
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
    );
  }
}
