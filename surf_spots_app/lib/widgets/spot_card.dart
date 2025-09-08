import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/constants/colors.dart';
import 'package:surf_spots_app/pages/spot_detail_page.dart';
import 'package:surf_spots_app/services/spot_service.dart';

class SpotCard extends StatefulWidget {
  final SurfSpot spot;
  final bool showLike;

  const SpotCard({super.key, required this.spot, this.showLike = true});

  @override
  State<SpotCard> createState() => _SpotCardState();
}

class _SpotCardState extends State<SpotCard> {
  @override
  void initState() {
    super.initState();
    _loadLikes();
  }

  // Charger le nombre de likes depuis le backend
  Future<void> _loadLikes() async {
    final count = await getLikes(widget.spot.id);
    setState(() {
      widget.spot.likesCount = count;
    });
  }

  Future<void> _toggleLike() async {
    final userId = 3; // ⚠️ provisoire → récupérer depuis Auth
    bool success;

    if (widget.spot.isLiked == true) {
      success = await unlikeSpot(widget.spot.id, userId);
      if (success) {
        setState(() {
          widget.spot.isLiked = false;
          widget.spot.likesCount = (widget.spot.likesCount ?? 1) - 1;
        });
      }
    } else {
      success = await likeSpot(widget.spot.id, userId);
      if (success) {
        setState(() {
          widget.spot.isLiked = true;
          widget.spot.likesCount = (widget.spot.likesCount ?? 0) + 1;
        });
      }
    }
  }

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
              height: 90,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.spot.isLiked ?? false
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.blue, // bouton bleu conservé
                          ),
                          onPressed: _toggleLike,
                        ),
                        Text(
                          "${widget.spot.likesCount} likes",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
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
