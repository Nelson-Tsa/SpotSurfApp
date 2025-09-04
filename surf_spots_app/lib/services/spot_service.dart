import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/surf_spot.dart';

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

class SpotService {
  static const String baseUrl = 'http://10.0.2.2:4000/api/spot';

  static Future<List<SurfSpot>> fetchAllSpots() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/spots'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SurfSpot.fromJson(json)).toList();
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
