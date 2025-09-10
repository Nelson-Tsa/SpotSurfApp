import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:surf_spots_app/widgets/spot_card.dart';
import 'package:surf_spots_app/constants/colors.dart';
import 'package:surf_spots_app/providers/spots_provider.dart';

class UserSpotsCarousel extends StatefulWidget {
  const UserSpotsCarousel({super.key});

  @override
  State<UserSpotsCarousel> createState() => _UserSpotsCarouselState();
}

class _UserSpotsCarouselState extends State<UserSpotsCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    
    // Charger les spots utilisateur via le provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SpotsProvider>(context, listen: false);
      if (!provider.hasCachedUserSpots) {
        provider.loadUserSpots();
      }
    });
  }

  void _startAutoScroll(int totalPages) {
    // Démarrer le Timer pour le défilement automatique seulement s'il y a des spots
    if (totalPages > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients && totalPages > 0) {
          _currentPage = (_currentPage + 1) % totalPages;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
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
    return Consumer<SpotsProvider>(
      builder: (context, spotsProvider, child) {
        if (spotsProvider.isLoading) {
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
        
        final spots = spotsProvider.userSpots;
        
        if (spots.isEmpty) {
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
        
        // Calculer le nombre de pages et démarrer l'auto-scroll si nécessaire
        _totalPages = (spots.length / 2).ceil();
        if (_timer == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startAutoScroll(_totalPages);
          });
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
                    'Mes spots (${spots.length})',
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
                        if (itemIndex >= spots.length) {
                          return Expanded(child: Container());
                        }
                        final spot = spots[itemIndex];

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
      },
    );
  }
}
