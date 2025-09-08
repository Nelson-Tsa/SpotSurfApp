import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_spots_app/models/user.dart';

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:4000/api/users';
  static const String _loginKey = 'is_logged_in';

  static final Dio _dio = Dio()..interceptors.add(CookieManager(CookieJar()));

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        await _setLoggedIn(true);
        return {
          'success': true,
          'message': response.data['message'] ?? 'Connexion réussie',
        };
      } else {
        return {
          'success': false,
          'message': response.data['error'] ?? 'Erreur de connexion',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de réseau'};
    }
  }

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String? role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/register',
        ), // Assure-toi que cette route existe dans ton backend
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role ?? 'user',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    // TODO: Intégrer avec l'API Golang
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/logout'),
    //   headers: {'Content-Type': 'application/json'},
    // );

    await _setLoggedIn(false);
    return {'success': true, 'message': 'Déconnexion réussie'};
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  static Future<void> _setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, value);
  }

  static Future<User?> getUser() async {
    try {
      print('🔄 Appel de getUser() avec URL: $_baseUrl/user');
      final response = await _dio.get('$_baseUrl/user');

      print('📡 Status Code: ${response.statusCode}');
      print('📊 Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['user'];
        print('👤 User Data: $userData');

        if (userData != null) {
          print('✅ Création de l\'objet User...');
          final user = User.fromJson(userData);
          print('✅ User créé: ${user.name} (${user.email})');
          return user;
        } else {
          print('❌ Pas de propriété "user" dans la réponse');
          return null;
        }
      }
      print('❌ Status code: ${response.statusCode} ou response.data null');
      return null;
    } catch (e) {
      print('💥 Erreur dans getUser(): $e');
      return null;
    }
  }
}
