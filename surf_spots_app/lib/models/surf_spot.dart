class SurfSpot {
  final String id;
  final String name;
  final String city;
  final String description;
  final int level;
  final int difficulty;
  final List<String> imageBase64;
  final int userId;
  final String gps; // <-- Ajoute ce champ

  bool? isLiked;

  SurfSpot({
    required this.id,
    required this.name,
    required this.city,
    required this.description,
    required this.level,
    required this.difficulty,
    required this.imageBase64,
    required this.userId,
    required this.gps, // <-- Ajoute dans le constructeur
    this.isLiked,
  });

  factory SurfSpot.fromJson(Map<String, dynamic> json) {
    return SurfSpot(
      id: json['id'].toString(),
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
      userId:
          json['user_id'] ?? 0, // <-- adapte selon le nom exact du champ JSON
      gps: json['gps'] ?? '', // <-- Ajoute ici
      isLiked: json['isLiked'], // optionnel selon ton API
    );
  }
}
