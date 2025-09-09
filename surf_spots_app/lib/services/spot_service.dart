import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

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
  static late Dio _dio;
  static bool _initialized = false;

  static Future<void> _initializeDio() async {
    if (_initialized) return;

    _dio = Dio();
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    // Ajouter le gestionnaire de cookies
    final cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(cookieJar));

    _initialized = true;
  }

  static Future<bool> toggleLike(int spotId) async {
    try {
      await _initializeDio();

      final response = await _dio.post('/api/spot/like/$spotId');

      if (response.statusCode == 200) {
        return response.data['liked'] ?? false;
      }
      return false;
    } catch (e) {
      print('Erreur toggleLike: $e');
      return false;
    }
  }

  static Future<int> getLikesCount(int spotId) async {
    try {
      await _initializeDio();

      final response = await _dio.get('/api/spot/likes/$spotId');

      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Erreur getLikesCount: $e');
      return 0;
    }
  }
}
