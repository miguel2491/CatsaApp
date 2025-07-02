import 'package:flutter/material.dart';

class CenteredDivider extends StatelessWidget {
  final String title;

  const CenteredDivider({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(thickness: 1.2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        const Expanded(child: Divider(thickness: 1.2)),
      ],
    );
  }
}
