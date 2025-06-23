import 'package:flutter/material.dart';

class LoginImg extends StatelessWidget {
  const LoginImg({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 50.0, right: 20),
          child: Container(
            decoration: BoxDecoration(color: Colors.white10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [Image.asset("assets/images/logo.png", width: 220)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
