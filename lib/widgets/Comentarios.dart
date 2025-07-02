import 'package:flutter/material.dart';

class TextAreaField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const TextAreaField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 5,
    this.hintText,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            border: const OutlineInputBorder(),
            alignLabelWithHint: true, // importante para textarea
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
