import 'package:flutter/material.dart';
import 'package:surf_spots_app/auth/login_page.dart';
import 'package:surf_spots_app/auth/register_page.dart';
import 'package:surf_spots_app/main.dart';

class Routes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';

  static final Map<String, WidgetBuilder> appRoutes = {
    Routes.home: (context) => const MyApp(),
    Routes.login: (context) => const LoginPage(),
    Routes.register: (context) => const RegisterPage(),
  };
}
