import 'package:flutter/material.dart';
import 'package:surf_spots_app/constants/colors.dart';

class ReturnButton extends StatelessWidget {
  const ReturnButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(30, 30),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: Colors.black.withValues(alpha: 0.25), // couleur de l’ombre
        elevation: 8, // intensité de l’ombre
      ),
      onPressed: () {
        Navigator.pop(context);
      },
      child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
    );
  }
}
