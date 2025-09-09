
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/surf_spot.dart';

import 'package:surf_spots_app/services/auth_service.dart';
// Garde ta fonction existante
Future<void> createSpotWithImage({
  required String name,
  required String city,
  required String description,
  required String level,
  required String difficulty,
  required String gps,
  required int userId,
  required String imagePath,
}) async {
  var uri = Uri.parse('http://10.0.2.2:4000/api/spot/create');
  var request = http.MultipartRequest('POST', uri)
    ..fields['name'] = name
    ..fields['city'] = city
    ..fields['description'] = description
    ..fields['level'] = level
    ..fields['difficulty'] = difficulty
    ..fields['gps'] = gps
    ..fields['user_id'] = userId.toString()
    ..files.add(await http.MultipartFile.fromPath('image', imagePath));
  var response = await request.send();
  if (response.statusCode == 200) {
    // Spot créé avec succès
  } else {
    // Erreur lors de la création du spot
  }
}



class SpotService {
  static const String baseUrl = 'http://10.0.2.2:4000/api/spot';
static Future<List<dynamic>> getMySpots() async {
    try {
      final response = await AuthService.authenticatedDio.get(
        '/api/spot/my-spots',
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to load spots');
      }
    } catch (e) {
      throw Exception('Error fetching spots: $e');
    }
  }
  static Future<List<SurfSpot>> fetchAllSpots() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/spots'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (json) => SurfSpot(
                id: json['id'].toString(),
                userId: json['user_id'],
                name: json['name'],
                city: json['city'],
                level: int.tryParse(json['level'].toString()) ?? 1,
                difficulty: int.tryParse(json['difficulty'].toString()) ?? 1,
                description: json['description'],
                imageBase64: json['images'] != null
                    ? (json['images'] as List)
                          .map((img) => img['image_data'] ?? '')
                          .where((img) => img != '')
                          .cast<String>()
                          .toList()
                    : [],
                    gps : json['gps'] ?? '',
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to load spots');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static List<SurfSpot> filterSpots(List<SurfSpot> spots, String query) {
    if (query.isEmpty) return spots;

    return spots.where((spot) {
      return spot.name.toLowerCase().contains(query.toLowerCase()) ||
          spot.city.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  static List<SurfSpot> getFavoriteSpots(List<SurfSpot> spots) {
    return spots.where((spot) => spot.isLiked == true).toList();
  }
}
