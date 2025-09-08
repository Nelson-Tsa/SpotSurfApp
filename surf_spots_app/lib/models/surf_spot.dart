class SurfSpot {
  final String id;
  final String name;
  final String city;
  final String description;
  final int level;
  final int difficulty;
  final List<String> imageBase64;
  final int userId; // ou creatorId selon ton choix

  bool? isLiked; // <-- Ajoute ce champ

  SurfSpot({
    required this.id,
    required this.name,
    required this.city,
    required this.description,
    required this.level,
    required this.difficulty,
    required this.imageBase64,
    required this.userId,
    this.isLiked, // <-- Ajoute dans le constructeur
  });

  factory SurfSpot.fromJson(Map<String, dynamic> json) {
    return SurfSpot(
      id: json['id'],
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
      userId: json['userId'] ?? '', // <-- Assurez-vous de gérer ce champ
    );
  }
}
