class SurfSpot {
  final String name;
  final String description;
  final String imageUrl; // Ajouter le champ pour l'image
  bool? isLiked;

  SurfSpot({
    required this.name,
    required this.description,
    required this.imageUrl,
    this.isLiked = false,
  });
}
