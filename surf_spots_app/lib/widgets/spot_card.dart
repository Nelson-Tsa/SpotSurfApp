import 'package:flutter/material.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/constants/colors.dart';
import 'package:surf_spots_app/pages/spot_detail_page.dart'; // Ajoute l'import
import 'dart:convert';

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
            SizedBox(
              height: 90, // Choisis une hauteur adaptée à ton design
              child: (widget.spot.imageBase64.isNotEmpty &&
                      widget.spot.imageBase64.first.isNotEmpty)
                  ? Image.memory(
                      base64Decode(widget.spot.imageBase64.first),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    widget.spot.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.spot.description.length > 60
                        ? '${widget.spot.description.substring(0, 60)}...'
                        : widget.spot.description,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
