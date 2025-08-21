import 'package:flutter/material.dart';

class ReturnButton extends StatelessWidget {
  const ReturnButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        minimumSize: const Size(80, 30),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: Colors.black.withValues(alpha: 0.25), // couleur de l’ombre
        elevation: 8, // intensité de l’ombre
      ),
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text(
        "Retour",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
