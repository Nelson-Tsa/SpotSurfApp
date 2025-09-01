import 'package:flutter/material.dart';
import '../widgets/custom_input_field.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ContainerForms extends StatelessWidget {
  final TextEditingController gpsController;
  final TextEditingController villeController;
  final TextEditingController spotController;
  final TextEditingController descriptionController;
  final VoidCallback onPickLocation;

  final int? selectedNiveau;
  final int? selectedDifficulte;
  final ValueChanged<int?> onNiveauChanged;
  final ValueChanged<int?> onDifficulteChanged;

  final GlobalKey<FormState> formKey;
  final VoidCallback onValidate; // AJOUTE CE PARAMÈTRE

  final List<XFile> images;
  final VoidCallback onAddImage;
  final void Function(XFile) onRemoveImage;

  const ContainerForms({
    super.key,
    required this.formKey,
    required this.gpsController,
    required this.villeController,
    required this.spotController,
    required this.descriptionController,
    required this.onPickLocation,
    required this.selectedNiveau,
    required this.selectedDifficulte,
    required this.onNiveauChanged,
    required this.onDifficulteChanged,
    required this.onValidate, // AJOUTE CE PARAMÈTRE
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
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
        child: Form(
          key: formKey,
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
              CustomInputField(
                controller: villeController,
                label: 'Ville',
                keyboardType: TextInputType.text,
                validator: (value) => value == null || value.isEmpty
                    ? 'Ce champ est requis'
                    : null,
              ),
              const SizedBox(height: 4),
              const Text(
                'Nom du spot',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              CustomInputField(
                controller: spotController,
                label: 'Nom du spot',
                keyboardType: TextInputType.text,
                validator: (value) => value == null || value.isEmpty
                    ? 'Ce champ est requis'
                    : null,
              ),
              const SizedBox(height: 4),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              CustomInputField(
                controller: descriptionController,
                label: 'Description',
                keyboardType: TextInputType.multiline,
                validator: (value) => value == null || value.isEmpty
                    ? 'Ce champ est requis'
                    : null,
              ),
              const SizedBox(height: 8),
              const Text(
                'Niveau',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    DropdownButton<int>(
                      value: selectedNiveau,
                      items: [1, 2, 3]
                          .map(
                            (val) => DropdownMenuItem(
                              value: val,
                              child: Text('$val'),
                            ),
                          )
                          .toList(),
                      onChanged: onNiveauChanged,
                      underline: Container(),
                      dropdownColor: Colors.white,
                    ),
                  ],
                ),
              ),
              if (selectedNiveau == null)
                const Padding(
                  padding: EdgeInsets.only(left: 12.0, top: 4.0),
                  child: Text(
                    'Ce champ est requis',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const Text(
                'Difficulté',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    DropdownButton<int>(
                      value: selectedDifficulte,
                      items: [1, 2, 3]
                          .map(
                            (val) => DropdownMenuItem(
                              value: val,
                              child: Text('$val'),
                            ),
                          )
                          .toList(),
                      onChanged: onDifficulteChanged,
                      underline: Container(),
                      dropdownColor: Colors.white,
                    ),
                  ],
                ),
              ),
              if (selectedDifficulte == null)
                const Padding(
                  padding: EdgeInsets.only(left: 12.0, top: 4.0),
                  child: Text(
                    'Ce champ est requis',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 4),
              const Text(
                'Point GPS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ce champ est requis'
                          : null,
                    ),
                  ],
                ),
              ),
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
                      GestureDetector(
                        onTap: onAddImage,
                        child: Container(
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
                      ),
                      const SizedBox(height: 8),
                      // Affiche les images sélectionnées
                      Wrap(
                        spacing: 8,
                        children: images
                            .map(
                              (img) => Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Image.file(
                                    File(img.path),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: -10,
                                    top: -10,
                                    child: GestureDetector(
                                      onTap: () => onRemoveImage(img),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                      if (images.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 3.0),
                          child: Text(
                            'Veuillez ajouter au moins une photo',
                            style: TextStyle(color: Colors.red, fontSize: 12),
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
                    onPressed: onValidate, // UTILISE LE CALLBACK ICI
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
      ),
    );
  }
}

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
