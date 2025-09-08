import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart'; // Pour Navigator.pop si besoin
import 'package:provider/provider.dart';
import 'package:surf_spots_app/providers/user_provider.dart';
import 'package:http/http.dart' as http;

class SpotDetailPage extends StatefulWidget {
  final SurfSpot spot;

  const SpotDetailPage({super.key, required this.spot});

  @override
  State<SpotDetailPage> createState() => _SpotDetailPageState();
}

class _SpotDetailPageState extends State<SpotDetailPage> {
  late SurfSpot _spot;
  String _backgroundImageUrl = '';

  @override
  void initState() {
    super.initState();
    _spot = widget.spot;
    _backgroundImageUrl = _spot.imageBase64.isNotEmpty
        ? _spot.imageBase64.first
        : '';
  }

  Widget _buildLevelIndicator(int level) {
    return Row(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Image.asset(
            index < level
                ? 'assets/logo/SurfPlancheGOOD.png'
                : 'assets/logo/plancheGrise.png',
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.surfing,
                color: index < level ? Colors.blue : Colors.grey[300],
                size: 24,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildDifficultyIndicator(int difficulty) {
    return Row(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Image.asset(
            index < difficulty
                ? 'assets/logo/vague.png'
                : 'assets/logo/GriseVague.png',
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.waves,
                color: index < difficulty ? Colors.orange : Colors.grey[300],
                size: 24,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildPhotoGallery() {
    final validImages = _spot.imageBase64
        .where((url) => url.isNotEmpty)
        .toList();

    if (validImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          validImages.length == 1 ? "Photo :" : "Photos :",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: validImages.length,
            itemBuilder: (context, index) {
              final imgBase64 = validImages[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _backgroundImageUrl = imgBase64;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _backgroundImageUrl == imgBase64
                          ? Colors.blue
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.memory(
                      base64Decode(imgBase64),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundImage() {
    if (_backgroundImageUrl.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: MemoryImage(base64Decode(_backgroundImageUrl)),
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Future<void> deleteSpot(String spotId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:4000/spots/$spotId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      Navigator.of(context).pop(true); // true = suppression effectuée
    } else {
      // Affiche une erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du spot')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      body: SlidingUpPanel(
        panel: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                // child: Container(
                //   width: 40,
                //   height: 5,
                //   decoration: BoxDecoration(
                //     color: Colors.grey[300],
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                // ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 50.0,
                        ), // Décale de 50 pixels vers la droite
                        child: Text(
                          "Détails du spot",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _spot.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.near_me_rounded,
                            size: 18,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _spot.city,
                            style: const TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _spot.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      _buildPhotoGallery(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            "Niveau : ",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildLevelIndicator(_spot.level),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            "Difficulté : ",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildDifficultyIndicator(_spot.difficulty),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _spot.isLiked ?? false
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() {
                                _spot.isLiked = !(_spot.isLiked ?? false);
                              });
                            },
                          ),
                          Text(
                            "${_spot.isLiked == true ? '1' : '0'} like${_spot.isLiked == true ? '' : 's'}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          // Ajout du bouton supprimer
                          if (currentUser != null &&
                              (currentUser.role == 'admin' ||
                                  currentUser.id == _spot.userId))
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                      'Confirmer la suppression',
                                    ),
                                    content: const Text(
                                      'Voulez-vous vraiment supprimer ce spot ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('Annuler'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                      ),
                                      TextButton(
                                        child: const Text(
                                          'Supprimer',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  // Appelle ta logique de suppression ici
                                  await deleteSpot(_spot.id);
                                }
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Background image with 1/3 height and centered
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.3,
              child: _buildBackgroundImage(),
            ),
            // Dark overlay for better readability - only on image area
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(30),
                      Colors.black.withAlpha(10),
                      Colors.transparent,
                      Colors.black.withAlpha(40),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Top area with solid background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.1,
              child: Container(color: Colors.white),
            ),
            // Bottom area with solid background
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Container(color: Colors.white),
            ),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        minHeight: MediaQuery.of(context).size.height * 0.6,
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
    );
  }
}
