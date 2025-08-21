import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const CustomInputField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
