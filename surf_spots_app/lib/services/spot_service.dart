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

Future<bool> likeSpot(String spotId, int userId) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:4000/api/spot/$spotId/like?user_id=$userId'),
  );
  return response.statusCode == 200;
}

Future<bool> unlikeSpot(String spotId, int userId) async {
  final response = await http.delete(
    Uri.parse('http://10.0.2.2:4000/api/spot/$spotId/unlike?user_id=$userId'),
  );
  return response.statusCode == 200;
}

Future<int> getLikes(String spotId) async {
  final response =
      await http.get(Uri.parse('http://10.0.2.2:4000/api/spot/$spotId/likes'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['likes'] ?? 0;
  }
  return 0;
}
