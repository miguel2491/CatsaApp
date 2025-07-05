import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const DatePickerTile({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          date != null
              ? DateFormat('dd/MM/yyyy').format(date!)
              : 'Seleccionar fecha',
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: onTap,
      ),
    );
  }
}
