import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:surf_spots_app/models/surf_spot.dart'; // Importer le modèle
import 'package:surf_spots_app/widget/spot_card.dart'; // Importer la nouvelle carte

class Carroussel extends StatefulWidget {
  const Carroussel({super.key});

  @override
  State<Carroussel> createState() => _CarrousselState();
}

class _CarrousselState extends State<Carroussel> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  // 1. Créer une liste de données de substitution (plus tard, cela viendra de la base de données)
  final List<SurfSpot> _spots = [
    SurfSpot(name: 'La Gravière', description: 'Hossegor, France', imageUrl: 'assets/images/la_graviere.jpg'),
    SurfSpot(name: 'Pipeline', description: 'Oahu, Hawaï', imageUrl: 'assets/images/pipeline.jpg'),
    SurfSpot(name: 'Uluwatu', description: 'Bali, Indonésie', imageUrl: 'assets/images/uluwatu.jpg'),
    SurfSpot(name: 'Jeffreys Bay', description: 'Afrique du Sud', imageUrl: 'assets/images/jeffreys_bay.jpg'),
    SurfSpot(name: 'Teahupo\'o', description: 'Tahiti, Polynésie', imageUrl: 'assets/images/teahupoo.jpg'),
  ];

  late int _totalPages;

  @override
  void initState() {
    super.initState();
    _totalPages = (_spots.length / 2).ceil();
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
                  if (itemIndex >= _spots.length) {
                    return Expanded(child: Container());
                  }
                  // 2. Récupérer le bon spot de la liste
                  final spot = _spots[itemIndex];

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      // 3. Utiliser le nouveau widget SpotCard
                      child: SpotCard(spot: spot),
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
