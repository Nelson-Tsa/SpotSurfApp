import 'package:flutter/material.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/return_button.dart';

class ContainerForms extends StatelessWidget {
  final TextEditingController gpsController;
  final VoidCallback onPickLocation;

  const ContainerForms({
    super.key,
    required this.gpsController,
    required this.onPickLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Ajout spot de surf',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              'Ville',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            CustomInputField(label: 'Ville', keyboardType: TextInputType.text),

            const SizedBox(height: 4),
            const Text(
              'Nom du spot',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            CustomInputField(
              label: 'Nom du spot',
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 4),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            CustomInputField(
              label: 'Description',
              keyboardType: TextInputType.multiline,
            ),

            const SizedBox(height: 4),
            const Text(
              'Niveau',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            CustomInputField(label: 'Niveau', keyboardType: TextInputType.text),

            const SizedBox(height: 4),
            const Text(
              'Difficulté',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            CustomInputField(
              label: 'Difficulté',
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 4),

            // ======== GPS FIELD =========
            GestureDetector(
              onTap: onPickLocation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.near_me_rounded, color: Colors.blue, size: 28),
                  const SizedBox(height: 8),
                  CustomInputField(
                    controller: gpsController,
                    label: 'Point GPS',
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
            ),

            // ============================
            const SizedBox(height: 4),
            const Text(
              'Photo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Déposer vos images ici',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Center(child: Text('Spot ajouté !')),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    backgroundColor: const Color(0xFF1A73E8),
                  ),
                  child: const Text(
                    'Valider',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
