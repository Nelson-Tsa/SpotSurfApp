class SurfSpot {
  final String name;
  final String description;
  final List<String> imageUrls; // Changed to list for multiple images
  final String city;
  final int level; // 1-3 for surfboard icons
  final int difficulty; // 1-3 for wave icons
  bool? isLiked;

  SurfSpot({
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.city,
    required this.level,
    required this.difficulty,
    this.isLiked = false,
  });

  // Getter for backward compatibility
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
}
