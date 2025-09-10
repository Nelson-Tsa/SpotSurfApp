import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:surf_spots_app/models/user.dart';

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:4000/api/users';
  static const String _loginKey = 'is_logged_in';

  static final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:4000'))
    ..interceptors.add(CookieManager(CookieJar()));

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/users/login',
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
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/logout'),

        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _setLoggedIn(false);

        return {
          'success': true,
          'message': data['message'] ?? 'Déconnexion réussie',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la déconnexion',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
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
      developer.log('🔄 Appel de getUser() avec URL: $_baseUrl/user', name: 'AuthService');
      final response = await _dio.get('/api/users/user');

      developer.log('📡 Status Code: ${response.statusCode}', name: 'AuthService');
      developer.log('📊 Response Data: ${response.data}', name: 'AuthService');

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['user'];

        if (userData != null) {
          final user = User.fromJson(userData);
          return user;
        } else {
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> updateUser({
    required String name,
    required String email,
  }) async {
    try {
      final response = await _dio.put(
        '/api/users/user',
        data: {'name': name, 'email': email},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              response.data['message'] ?? 'Utilisateur mis à jour avec succès',
        };
      } else {
        return {
          'success': false,
          'message': response.data['error'] ?? 'Erreur lors de la mise à jour',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de réseau'};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.put(
        '/api/users/user',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              response.data['message'] ?? 'Mot de passe modifié avec succès',
        };
      } else {
        return {
          'success': false,
          'message':
              response.data['error'] ??
              'Erreur lors du changement de mot de passe',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de réseau'};
    }
  }

  // Méthode pour obtenir l'instance Dio avec les cookies d'authentification
  static Dio get authenticatedDio => _dio;
}
