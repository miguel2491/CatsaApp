import 'package:flutter/material.dart';

class DetailTile extends StatelessWidget {
  final String label;
  final String value;

  const DetailTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isNotEmpty ? value : ' '),
      ),
    );
  }
}
