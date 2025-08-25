import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/pages/spot_detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Controller to programmatically open/close the sliding panel
  final PanelController _panelController = PanelController();

  // Information for the selected spot to be displayed in the panel
  String _selectedSpotTitle = "Aucun spot sélectionné";
  String _selectedSpotDescription =
      "Cliquez sur un marqueur pour voir les détails ici.";
  String _selectedSpotCity = "";
  int _selectedSpotLevel = 0;
  int _selectedSpotDifficulty = 0;

  // SurfSpot object for the selected spot to handle likes
  SurfSpot? _selectedSpot;

  // The initial camera position when the map opens
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(45.75, 4.85), // Centered on Lyon, France by default
    zoom: 5,
  );

  // Set of markers to display on the map
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Initialize markers here
    _markers.add(
      Marker(
        markerId: const MarkerId('Teahupoo'),
        position: const LatLng(
          -17.8473,
          -149.2671,
        ), // Coordinates for Teahupoo, Tahiti
        infoWindow: const InfoWindow(title: 'Teahupoo'),
        onTap: () {
          // When the marker is tapped, update the state with the spot's info
          // and open the panel.
          setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: _panelController, // Assign the controller
        // The panel that slides up
        panel: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Handle to indicate the panel is draggable
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
              // Header with title and like button
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "Informations sur le spot",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
              // Spot information aligned to the left
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
                    const SizedBox(height: 0.2),
                    Row(
                      children: [
                        Icon(
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
                    // Photo section aligned to the left
                    Text(
                      "Photo :",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
              // Bottom section with likes count and details button
              Padding(
                padding: const EdgeInsets.only(
                  right: 80.0,
                ), // Marge pour éviter le bouton flottant
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_selectedSpot != null)
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.blue, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "${_selectedSpot!.isLiked == true ? '1' : '0'} like${_selectedSpot!.isLiked == true ? '' : 's'}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
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
              ),
            ],
          ),
        ),
        // The main content behind the panel
        body: GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          markers: _markers,
          onTap: (LatLng pos) {
            // If the user taps on the map (not on a marker), close the panel.
            if (_panelController.isPanelOpen) {
              _panelController.close();
            }
          },
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        minHeight: 0, // The panel is completely hidden when closed
        maxHeight:
            MediaQuery.of(context).size.height *
            0.5, // Panel takes half the screen
      ),
    );
  }
}
