import 'package:flutter/material.dart';
import 'package:surf_spots_app/widgets/grid.dart';
// import 'package:surf_spots_app/widgets/return_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surf Spots App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Surf App")),
      // body: const Center(child: ReturnButton()),
      body: const Center(child: GalleryPage()),
    );
  }
}
