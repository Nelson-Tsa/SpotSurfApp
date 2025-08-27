import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/pages/spot_detail_page.dart';
import 'package:surf_spots_app/widgets/container_forms.dart';

class MapPage extends StatefulWidget {
  final Function(bool)? onPanelStateChanged;

  const MapPage({super.key, this.onPanelStateChanged});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final PanelController _panelController = PanelController();

  // Informations pour le panel détails spot
  String _selectedSpotTitle = "Aucun spot sélectionné";
  String _selectedSpotDescription = "Cliquez sur un marqueur pour voir les détails ici.";
  String _selectedSpotCity = "";
  int _selectedSpotLevel = 0;
  int _selectedSpotDifficulty = 0;

  SurfSpot? _selectedSpot;

  // Variables de contrôle du panel
  bool _isPanelOpen = false;
  bool _isAddingSpot = false;
  void openAddSpotPanel() {
    setState(() {
      _isAddingSpot = true; // mode ajout actif
    });
    _panelController.open();
  }
  // Variables pour le mode GPS
  LatLng? _pickedLocation;
  bool _isPickingLocation = false; // mode sélection activé ou pas
  final TextEditingController _gpsController = TextEditingController();

  // Position initiale de la map
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(45.75, 4.85),
    zoom: 5,
  );

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    // Exemple de marqueur
    _markers.add(
      Marker(
        markerId: const MarkerId('Teahupoo'),
        position: const LatLng(-17.8473, -149.2671),
        infoWindow: const InfoWindow(title: 'Teahupoo'),
        onTap: () {
          // On clique sur le marqueur => afficher le détail
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



  // Widget panel détails spot
  Widget buildSpotDetailsPanel() {
    return Column(
      children: [
        // Barre de drag du panel
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
        // Header avec titre et bouton like
        Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "Informations sur le spot",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 0.2),
              Row(
                children: [
                  const Icon(Icons.near_me_rounded, size: 18, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    _selectedSpotCity,
                    style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(_selectedSpotDescription, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              const Text("Photo :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _selectedSpot != null
                  ? Image.asset(
                      _selectedSpot!.imageUrls[0],
                      height: 50,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/placeholder.png',
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bouton flottant pour ajouter un spot directement depuis la map
      floatingActionButton: FloatingActionButton(
        onPressed: openAddSpotPanel,
        child: const Icon(Icons.add),
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        onPanelSlide: (double pos) {
          setState(() {
            _isPanelOpen = pos > 0.1; // Considérer ouvert si plus de 10%
          });
          widget.onPanelStateChanged?.call(_isPanelOpen);
        },
        onPanelOpened: () => widget.onPanelStateChanged?.call(true),
        onPanelClosed: () => widget.onPanelStateChanged?.call(false),
        panel: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isAddingSpot
              ? ContainerForms(
                  gpsController: _gpsController,
                  onPickLocation: () {
                    setState(() {
                      _isPickingLocation = true;
                      _panelController.close(); // fermer temporairement le panel
                    });
                  },
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
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
          },
          onTap: (LatLng pos) {
            if (_isPickingLocation) {
              setState(() {
                _pickedLocation = pos;
                _isPickingLocation = false;
              });
              _gpsController.text = "${pos.latitude}, ${pos.longitude}";
            } else if (_panelController.isPanelOpen) {
              _panelController.close();
            }
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
