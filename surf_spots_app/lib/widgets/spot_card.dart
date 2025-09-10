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
    try {
      final spotId = int.parse(widget.spot.id);

      // Récupérer le compteur et l'état du like en parallèle
      final futures = await Future.wait([
        LikeService.getLikesCount(spotId),
        LikeService.isLiked(spotId),
      ]);

      final count = futures[0] as int;
      final isLiked = futures[1] as bool;

      if (mounted) {
        setState(() {
          widget.spot.likesCount = count;
          widget.spot.isLiked = isLiked;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des likes: $e');
      // En cas d'erreur (pas connecté), initialiser à false
      if (mounted) {
        setState(() {
          widget.spot.isLiked = false;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    try {
      final spotId = int.parse(widget.spot.id);
      final newLikedState = await LikeService.toggleLike(spotId);

      if (mounted) {
        setState(() {
          widget.spot.isLiked = newLikedState;
          // Mettre à jour le compteur selon le nouvel état
          if (newLikedState) {
            widget.spot.likesCount += 1;
          } else {
            widget.spot.likesCount = (widget.spot.likesCount > 0)
                ? widget.spot.likesCount - 1
                : 0;
          }
        });
      }
    } catch (e) {
      print('Erreur lors du toggle like: $e');
      // Afficher un message à l'utilisateur si non connecté
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous devez être connecté pour liker un spot'),
            backgroundColor: Colors.orange,
          ),
        );
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
              child:
                  (widget.spot.imageBase64.isNotEmpty &&
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
                            color: widget.spot.isLiked ?? false
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          onPressed: _toggleLike,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.spot.likesCount}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
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
