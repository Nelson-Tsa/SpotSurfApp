import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../widgets/custom_input_field.dart';

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
  final VoidCallback onValidate;

  final List<String> existingImagesBase64;
  final List<XFile> images;
  final VoidCallback onAddImage;
  final void Function(XFile) onRemoveImage;
  final void Function(String) onRemoveExistingImage;

  final bool isSubmitting;
  final String? formTitle;

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
    required this.onValidate,
    required this.existingImagesBase64,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
    required this.onRemoveExistingImage,
    required this.isSubmitting,
    this.formTitle,
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
              Padding(padding: const EdgeInsets.only(top: 8.0, bottom: 16.0)),
              if (formTitle != null)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.blue),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Fermer',
                    ),
                    Expanded(
                      child: Text(
                        formTitle!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              if (formTitle == null)
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
              const SizedBox(height: 14),
              // Champs du formulaire...
              CustomInputField(
                controller: spotController,
                label: 'Nom du spot',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 10),
              CustomInputField(
                controller: villeController,
                label: 'Ville',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ville requise' : null,
              ),
              const SizedBox(height: 10),
              CustomInputField(
                controller: descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Description requise'
                    : null,
              ),
              const SizedBox(height: 10),
              CustomInputField(
                controller: gpsController,
                label: 'Coordonnées GPS',
                validator: (value) => value == null || value.isEmpty
                    ? 'Coordonnées requises'
                    : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Niveau : '),
                  DropdownButton<int>(
                    value: selectedNiveau,
                    items: [1, 2, 3]
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(level.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: onNiveauChanged,
                  ),
                  const SizedBox(width: 20),
                  const Text('Difficulté : '),
                  DropdownButton<int>(
                    value: selectedDifficulte,
                    items: [1, 2, 3]
                        .map(
                          (diff) => DropdownMenuItem(
                            value: diff,
                            child: Text(diff.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: onDifficulteChanged,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Photos',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  // Images existantes (base64)
                  ...existingImagesBase64.map(
                    (imgBase64) => Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(imgBase64),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => onRemoveExistingImage(imgBase64),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Images ajoutées (XFile)
                  ...images.map(
                    (img) => Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(img.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => onRemoveImage(img),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bouton d'ajout
                  GestureDetector(
                    onTap: onAddImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(Icons.add_a_photo, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : onValidate,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Valider'),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
