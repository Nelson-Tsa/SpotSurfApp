import 'package:flutter/material.dart';
import 'package:surf_spots_app/models/user.dart'; // adapte le chemin si besoin

class UserProvider with ChangeNotifier {
  User? currentUser;

  void setUser(User user) {
    currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    currentUser = null;
    notifyListeners();
  }
}
