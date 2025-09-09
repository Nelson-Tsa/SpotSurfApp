import 'package:http/http.dart' as http;
import 'package:surf_spots_app/services/http_client.dart';
import 'package:surf_spots_app/services/auth_service.dart';

class SpotService {
  // Récupère les spots de l'utilisateur connecté
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
}

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
