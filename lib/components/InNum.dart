import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputNumerico extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool decimales; // Para permitir decimales
  final String? hintText;

  const InputNumerico({
    super.key,
    required this.label,
    required this.controller,
    this.decimales = false,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimales, // Permitir decimales si es true
      ),
      inputFormatters: [
        decimales
            ? FilteringTextInputFormatter.allow(
                RegExp(r'^\d*\.?\d{0,2}'),
              ) // 2 decimales
            : FilteringTextInputFormatter.digitsOnly, // Solo enteros
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? 'Ingrese un número',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => controller.clear(),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obligatorio';
        if (decimales && double.tryParse(value) == null) {
          return 'Ingrese un número válido';
        }
        if (!decimales && int.tryParse(value) == null) {
          return 'Ingrese un número entero';
        }
        return null;
      },
    );
  }
}
