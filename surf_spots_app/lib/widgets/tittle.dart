import 'package:flutter/material.dart';

class Tittle extends StatelessWidget {
  const Tittle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0), // Ajoute un peu d'espace
      child: Text(
        'Bienvenue sur l\'application de recherche de spots de surf !',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
