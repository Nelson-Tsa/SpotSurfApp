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
              _selectedSpot != null
                  ? Image.asset(
                      _selectedSpot!.imageUrls[0],
                      height: 80,
                      width: 150,
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
                  gpsController: _gpsController,
                  onPickLocation: () {
                    setState(() {
                      _isPickingLocation = true;
                      _panelController.close();
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
