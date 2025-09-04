import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:4000/api/users';

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String? role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/register',
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
}
