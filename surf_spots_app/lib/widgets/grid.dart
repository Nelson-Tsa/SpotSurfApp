import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Une liste factice d’images et de titres
    final List<Map<String, String>> items = [
      {"title": "Montagne", "image": "https://picsum.photos/200/300?1"},
      {"title": "Forêt", "image": "https://picsum.photos/200/300?2"},
      {"title": "Plage", "image": "https://picsum.photos/200/300?3"},
      {"title": "Désert", "image": "https://picsum.photos/200/300?4"},
      {"title": "Ville", "image": "https://picsum.photos/200/300?5"},
      {"title": "Lac", "image": "https://picsum.photos/200/300?6"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Galerie d'images")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // nombre de colonnes
            crossAxisSpacing: 10, // espace horizontal
            mainAxisSpacing: 10, // espace vertical
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        item["image"]!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item["title"]!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
