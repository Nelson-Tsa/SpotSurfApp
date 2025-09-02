import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  final void Function(String)? onChanged;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLines: maxLines,
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
