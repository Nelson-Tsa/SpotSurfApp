import 'package:flutter/material.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/constants/colors.dart';
import 'package:surf_spots_app/pages/spot_detail_page.dart';
import 'package:surf_spots_app/providers/spots_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class SpotCard extends StatefulWidget {
  final SurfSpot spot;
  final bool showLike;
  final VoidCallback? onFavoriteToggle;

  const SpotCard({
    super.key,
    required this.spot,
    this.showLike = true,
    this.onFavoriteToggle,
  });

  @override
  State<SpotCard> createState() => _SpotCardState();
}

class _SpotCardState extends State<SpotCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Provider.of<SpotsProvider>(
          context,
          listen: false,
        ).addToHistory(widget.spot);
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
            SizedBox(height: 90, child: _buildSpotImage()),
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
                        if (widget.onFavoriteToggle != null) {
                          widget.onFavoriteToggle!();
                        } else {
                          setState(() {
                            widget.spot.isLiked =
                                !(widget.spot.isLiked ?? false);
                          });
                        }
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

  Widget _buildSpotImage() {
    if (widget.spot.imageBase64.isEmpty ||
        widget.spot.imageBase64.first.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image_not_supported)),
      );
    }

    String base64String = widget.spot.imageBase64.first;

    // Supprimer le préfixe data si présent
    if (base64String.contains(',')) {
      final parts = base64String.split(',');
      base64String = parts.length > 1 ? parts.last : parts.first;
    }

    try {
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.broken_image)),
          );
        },
      );
    } catch (e) {
      return Container(
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.broken_image)),
      );
    }
  }
}
