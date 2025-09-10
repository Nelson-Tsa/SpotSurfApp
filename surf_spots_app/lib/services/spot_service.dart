import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:surf_spots_app/services/auth_service.dart';
import 'package:surf_spots_app/models/surf_spot.dart';

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

class LikeService {
  static const String baseUrl = 'http://10.0.2.2:4000';

  static Future<bool> toggleLike(int spotId) async {
    try {
      final response = await AuthService.authenticatedDio.post('/api/spot/like/$spotId');

      if (response.statusCode == 200) {
        return response.data['liked'] ?? false;
      }
      return false;
    } catch (e) {
      print('Erreur toggleLike: $e');
      throw Exception('Erreur lors du toggle like: $e');
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
      print('Erreur isLiked: $e');
      return false;
    }
  }

  static Future<int> getLikesCount(int spotId) async {
    try {
      // Utiliser Dio normal pour les compteurs publics
      final dio = Dio();
      dio.options.baseUrl = baseUrl;
      
      final response = await dio.get('/api/spot/likes/$spotId');

      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Erreur getLikesCount: $e');
      return 0;
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
      print('Erreur getUserFavorites: $e');
      return [];
    }
  }
}
