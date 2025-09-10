import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/services/auth_service.dart';
import 'package:surf_spots_app/config/api_config.dart';

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
  var uri = Uri.parse('${ApiConfig.spotsUrl}/create');
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
  static String get baseUrl => ApiConfig.spotsUrl;
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

class LikeService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<bool> toggleLike(int spotId) async {
    try {
      final response = await AuthService.authenticatedDio.post('/api/spot/like/$spotId');

      if (response.statusCode == 200) {
        return response.data['liked'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<int> getLikesCount(int spotId) async {
    try {
      final response = await AuthService.authenticatedDio.get('/api/spot/likes/$spotId');

      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> isLiked(int spotId) async {
    try {
      final response = await AuthService.authenticatedDio.get('/api/spot/isliked/$spotId');
      if (response.statusCode == 200) {
        return response.data['isLiked'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<SurfSpot>> getUserFavorites() async {
    try {
      final response = await AuthService.authenticatedDio.get('/api/spot/favorites');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SurfSpot.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Erreur getUserFavorites
      return [];
    }
  }
}
