import 'package:flutter/material.dart';
import 'package:surf_spots_app/auth/login_page.dart';
import 'package:surf_spots_app/auth/register_page.dart';
import 'package:surf_spots_app/pages/add_spots_page.dart';

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String addSpot = '/add-spot';

  static final Map<String, WidgetBuilder> appRoutes = {
    Routes.login: (context) => const LoginPage(),
    Routes.register: (context) => const RegisterPage(),
    Routes.addSpot: (context) => const AddSpotPage(),
  };
}
