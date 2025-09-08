import 'package:dio/dio.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'package:surf_spots_app/services/api_client.dart';

class VisitedService {
  static const String baseUrl = "http://10.0.2.2:4000/api/spot";

  static Dio get _dio => ApiClient.dio;

  // Ajouter un spot visité
  static Future<void> addVisited(int spotId) async {
    final response = await _dio.post(
      "$baseUrl/visited",
      data: {"spot_id": spotId},
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to add visited spot: ${response.data}");
    }
  }

  // Récupérer la liste des spots visités
  static Future<List<SurfSpot>> getVisited() async {
    final response = await _dio.get("$baseUrl/visited");
    if (response.statusCode == 200) {
      final List data = response.data;
      return data
          .map(
            (v) => SurfSpot.fromJson(v["spot"]),
          ) // on récupère bien le "spot"
          .toList();
    } else {
      throw Exception("Failed to fetch visited spots: ${response.data}");
    }
  }

  // Supprimer un spot visité
  static Future<void> deleteVisited(int visitedId) async {
    final response = await _dio.delete("$baseUrl/visited/$visitedId");
    if (response.statusCode != 200) {
      throw Exception("Failed to delete visited spot: ${response.data}");
    }
  }
}
