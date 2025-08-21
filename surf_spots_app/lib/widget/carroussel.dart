import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Carroussel extends StatefulWidget {
  const Carroussel({super.key});

  @override
  State<Carroussel> createState() => _CarrousselState();
}

class _CarrousselState extends State<Carroussel> {
  // 1. Toutes les variables d'état et les contrôleurs sont DANS la classe State.
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;
  final int _totalItems = 5;
  late int _totalPages;

  @override
  void initState() {
    super.initState();
    // 2. La logique d'initialisation est dans initState.
    _totalPages = (_totalItems / 2).ceil();
    _pageController = PageController(viewportFraction: 0.85);

    // Démarrer le Timer pour le défilement automatique
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _totalPages;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // 3. Il est crucial de libérer les ressources dans dispose.
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. La méthode build retourne un seul widget parent (ici, une Column).
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Center(
            child: Text(
              'Derniers spot ajouté :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(
          height: 150, // Hauteur fixe pour le carrousel
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
                  if (itemIndex >= _totalItems) {
                    return Expanded(child: Container());
                  }
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 60.0),
                      child: Card(
                        elevation: 4.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.surfing,
                              size: 40,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 8),
                            Text('Spot N°${itemIndex + 1}'),
                            const Text('Description...'),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: SmoothPageIndicator(
            controller: _pageController,
            count: _totalPages,
            effect: const WormEffect(
              dotHeight: 10,
              dotWidth: 10,
              activeDotColor: Color.fromARGB(255, 91, 188, 237),
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
    );
  }
}
