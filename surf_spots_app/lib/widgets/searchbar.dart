import 'package:flutter/material.dart';

class SearchBarSpot extends StatefulWidget {
  const SearchBarSpot({super.key});

  @override
  State<SearchBarSpot> createState() => _SearchBarSpotState();
}

class _SearchBarSpotState extends State<SearchBarSpot> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un spot...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  borderSide: BorderSide.none, // Pas de bordure visible
                ),
                filled:
                    true, // Important pour que la couleur de remplissage s'affiche
                fillColor: Colors.white70, // Couleur de fond de la barre
              ),
            ),
          );
  }
}