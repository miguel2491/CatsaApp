import 'package:flutter/material.dart';

class TimeInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const TimeInputField({
    super.key,
    required this.label,
    required this.controller,
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
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            hintText: 'HH:mm (ej. 1:20)',
          ),
          onChanged: onChanged,
          validator: (value) {
            final regex = RegExp(r'^([0-9]{1,2}):([0-5][0-9])$');
            if (value == null || !regex.hasMatch(value)) {
              return 'Ingresa un tiempo válido (ej. 1:20)';
            }
            return null;
          },
        ),
      ),
    );
  }
}
