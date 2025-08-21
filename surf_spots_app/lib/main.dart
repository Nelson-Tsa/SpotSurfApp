import 'package:flutter/material.dart';
import 'package:surf_spots_app/auth/login_page.dart';
import 'package:surf_spots_app/auth/register_page.dart';
import 'package:surf_spots_app/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.register,
      routes: Routes.appRoutes,
      home: Routes.home == '/' ? const RegisterPage() : const LoginPage(),
    );
  }
}
