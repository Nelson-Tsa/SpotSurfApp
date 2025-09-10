import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:surf_spots_app/services/auth_service.dart';
import 'package:surf_spots_app/models/surf_spot.dart';

// Création d'un spot avec image
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
    print('Spot créé avec succès');
  } else {
    print('Erreur lors de la création du spot');
  }
}

class LikeService {
  static const String baseUrl = 'http://10.0.2.2:4000';

  static Future<bool> toggleLike(int spotId) async {
    try {
      final response = await AuthService.authenticatedDio.post(
        '/api/spot/like/$spotId',
      );

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
      final response = await AuthService.authenticatedDio.get(
        '/api/spot/isliked/$spotId',
      );

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
      final response = await AuthService.authenticatedDio.get(
        '/api/spot/favorites',
      );

      print('getUserFavorites - Status: ${response.statusCode}');
      print('getUserFavorites - Data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('getUserFavorites - Nombre de favoris: ${data.length}');
        return data.map((json) => SurfSpot.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur getUserFavorites: $e');
      return [];
    }
  }
}
