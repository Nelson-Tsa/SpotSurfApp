import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/widgets/spot_card.dart';
import 'package:surf_spots_app/services/spot_service.dart';
import 'package:surf_spots_app/constants/colors.dart';

class UserSpotsCarousel extends StatefulWidget {
  const UserSpotsCarousel({super.key});

  @override
  State<UserSpotsCarousel> createState() => _UserSpotsCarouselState();
}

class _UserSpotsCarouselState extends State<UserSpotsCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  List<SurfSpot> _spots = [];
  late int _totalPages;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    fetchUserSpots();
  }

  Future<void> fetchUserSpots() async {
    try {
      final data = await SpotService.getMySpots();
      setState(() {
        _spots = data
            .map(
              (json) => SurfSpot(
                id: json['id'].toString(),
                userId: json['user_id'],
                name: json['name'],
                city: json['city'],
                level: int.tryParse(json['level'].toString()) ?? 1,
                difficulty: int.tryParse(json['difficulty'].toString()) ?? 1,
                description: json['description'],
                imageBase64: json['images'] != null
                    ? (json['images'] as List)
                          .map((img) => img['image_data'] ?? '')
                          .where((img) => img != '')
                          .cast<String>()
                          .toList()
                    : [],
                    gps: json['gps'] ?? '',
              ),
            )
            .toList();
        _totalPages = _spots.isNotEmpty ? (_spots.length / 2).ceil() : 0;
        isLoading = false;

        // Démarrer le Timer pour le défilement automatique seulement s'il y a des spots
        if (_spots.isNotEmpty && _totalPages > 1) {
          _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
            if (_pageController.hasClients && _totalPages > 0) {
              _currentPage = (_currentPage + 1) % _totalPages;
              _pageController.animateToPage(
                _currentPage,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _totalPages = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(200),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_spots.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(200),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: const Column(
          children: [
            Icon(Icons.surfing, size: 50, color: AppColors.primary),
            SizedBox(height: 10),
            Text(
              'Aucun spot ajouté',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Vous n\'avez encore ajouté aucun spot.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Center(
              child: Text(
                'Mes spots (${_spots.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _totalPages,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, pageIndex) {
                return Row(
                  children: List.generate(2, (cardIndex) {
                    final itemIndex = pageIndex * 2 + cardIndex;
                    if (itemIndex >= _spots.length) {
                      return Expanded(child: Container());
                    }
                    final spot = _spots[itemIndex];

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SpotCard(spot: spot, showLike: false),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          if (_totalPages > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _totalPages,
                effect: const WormEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  activeDotColor: AppColors.primary,
                  type: WormType.thin,
                ),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
