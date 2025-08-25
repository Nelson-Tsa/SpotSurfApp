import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:surf_spots_app/models/surf_spot.dart';

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
    _backgroundImageUrl = _spot.imageUrls.isNotEmpty
        ? _spot.imageUrls.first
        : '';
  }

  Widget _buildLevelIndicator(int level) {
    return Row(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Icon(
            Icons.surfing,
            color: index < level ? Colors.blue : Colors.grey[300],
            size: 24,
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
          child: Icon(
            Icons.waves,
            color: index < difficulty ? Colors.orange : Colors.grey[300],
            size: 24,
          ),
        );
      }),
    );
  }

  Widget _buildPhotoGallery() {
    // Filter out empty or null image URLs
    final validImages = _spot.imageUrls.where((url) => url.isNotEmpty).toList();

    if (validImages.isEmpty) {
      return const SizedBox.shrink(); // Don't show gallery if no valid images
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          validImages.length == 1 ? "Photo :" : "Photos :",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: validImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _backgroundImageUrl = validImages[index];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _backgroundImageUrl == validImages[index]
                          ? Colors.blue
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      validImages[index],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
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
              // Header with title and back arrow
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "Détails du spot",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Spot information
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
                          Icon(
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
                      // Photo gallery
                      _buildPhotoGallery(),
                      const SizedBox(height: 20),
                      // Level indicator
                      Row(
                        children: [
                          Text(
                            "Niveau : ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildLevelIndicator(_spot.level),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Difficulty indicator
                      Row(
                        children: [
                          Text(
                            "Difficulté : ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildDifficultyIndicator(_spot.difficulty),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Likes section
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Background image
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_backgroundImageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withAlpha(30), Colors.transparent],
              ),
            ),
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        minHeight: MediaQuery.of(context).size.height * 0.4,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
    );
  }
}
