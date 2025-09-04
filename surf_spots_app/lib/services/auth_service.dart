import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:4000/api/users/login';
  static const String _loginKey = 'is_logged_in';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _setLoggedIn(true);
        return {
          'success': true,
          'message': data['message'] ?? 'Connexion réussie',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur de connexion',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de réseau'};
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
}
