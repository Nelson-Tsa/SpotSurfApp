import 'package:flutter/material.dart';

class AddSpotButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddSpotButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: 'Ajouter un spot',
      child: const Icon(Icons.add),
    );
  }
}
