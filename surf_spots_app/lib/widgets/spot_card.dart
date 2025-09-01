import 'package:flutter/material.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/constants/colors.dart';
import 'package:surf_spots_app/pages/spot_detail_page.dart'; // Ajoute l'import

class SpotCard extends StatefulWidget {
  final SurfSpot spot;
  final bool showLike;

  const SpotCard({super.key, required this.spot, this.showLike = true});

  @override
  State<SpotCard> createState() => _SpotCardState();
}

class _SpotCardState extends State<SpotCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpotDetailPage(spot: widget.spot),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(widget.spot.imageUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    widget.spot.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(widget.spot.description),
                  if (widget.showLike)
                    IconButton(
                      icon: Icon(
                        widget.spot.isLiked ?? false
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          widget.spot.isLiked = !(widget.spot.isLiked ?? false);
                        });
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
