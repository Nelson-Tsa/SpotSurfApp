import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/widgets/spot_card.dart';
import 'package:http/http.dart' as http;
import 'package:surf_spots_app/constants/colors.dart';

class Carroussel extends StatefulWidget {
  const Carroussel({super.key});

  @override
  State<Carroussel> createState() => _CarrousselState();
}

class _CarrousselState extends State<Carroussel> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  List<SurfSpot> _spots = [];
  late int _totalPages;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    fetchSpots();

    // Démarrer le Timer pour le défilement automatique
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

  Future<void> fetchSpots() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/api/spot/spots'),
    );
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> data = json.decode(response.body);
      List<SurfSpot> spotsList = data
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
            ),
          )
          .toList();

      // Garde seulement les 10 derniers spots
      if (spotsList.length > 10) {
        spotsList = spotsList.sublist(spotsList.length - 10);
      }

      setState(() {
        _spots = spotsList;
        _totalPages = (_spots.length / 2).ceil();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        _totalPages = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_spots.isEmpty) {
      return const Center(child: Text('Aucun spot disponible.'));
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Center(
              child: Text(
                'Derniers spot ajoutés :',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        child: Column(
                          children: [SpotCard(spot: spot, showLike: false)],
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
