import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

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
  static Future<bool> toggleLike(int spotId) async {
    try {
      final response = await http.post(Uri.parse('/api/spot/like/$spotId'));
      final data= jsonDecode(response.body);
      return data['liked'] ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<int> getLikesCount(int spotId) async {
    try {
      final response = await http.get(Uri.parse('/api/spot/like/$spotId'));
      final data= jsonDecode(response.body);
      return data['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}