import 'package:flutter/material.dart';

class SearchBarSpot extends StatefulWidget {
  final String hintText; // Pour modifier le hintText (Page Favoris)
  const SearchBarSpot({super.key, this.hintText = 'Rechercher un spot...'});

  @override
  State<SearchBarSpot> createState() => _SearchBarSpotState();
}

class _SearchBarSpotState extends State<SearchBarSpot> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: widget.hintText, // utilise le paramètre
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white70,
        ),
      ),
    );
  }
}
