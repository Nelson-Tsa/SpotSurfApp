class SurfSpot {
  final String name;
  final String description;
  final List<String> imageBase64; // <-- pour stocker les images
  final String city;
  final int level;
  final int difficulty;
  bool? isLiked;

  SurfSpot({
    required this.name,
    required this.description,
    required this.imageBase64,
    required this.city,
    required this.level,
    required this.difficulty,
    this.isLiked = false,
  });

  factory SurfSpot.fromJson(Map<String, dynamic> json) {
    return SurfSpot(
      name: json['name'],
      description: json['description'],
      city: json['city'],
      level: int.tryParse(json['level'].toString()) ?? 1,
      difficulty: int.tryParse(json['difficulty'].toString()) ?? 1,
      imageBase64: json['images'] != null
          ? (json['images'] as List)
                .map((img) => img['image_data'] ?? '')
                .where((img) => img != null && img != '')
                .cast<String>()
                .toList()
          : [],
    );
  }
}
