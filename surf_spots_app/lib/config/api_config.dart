import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:4000';
  }
  
  static String get apiUrl => '$baseUrl/api';
  static String get usersUrl => '$apiUrl/users';
  static String get spotsUrl => '$apiUrl/spot';
}
