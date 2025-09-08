import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/spots_provider.dart';

class SearchBarSpot extends StatefulWidget {
  final String hintText;

  const SearchBarSpot({super.key, this.hintText = 'Rechercher un spot...'});

  @override
  State<SearchBarSpot> createState() => _SearchBarSpotState();
}

class _SearchBarSpotState extends State<SearchBarSpot> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Synchroniser le contrôleur avec l'état du provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SpotsProvider>(context, listen: false);
      _controller.text = provider.searchQuery;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    Provider.of<SpotsProvider>(
                      context,
                      listen: false,
                    ).clearSearch();
                    setState(() {}); // Pour retirer le bouton clear
                  },
                )
              : null,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white70,
        ),
        onChanged: (value) {
          setState(() {}); // Pour afficher/masquer le bouton clear
          Provider.of<SpotsProvider>(context, listen: false).searchSpots(value);
        },
      ),
    );
  }
}
