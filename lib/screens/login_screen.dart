import 'package:flutter/material.dart';
import './home_screen.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Iniciar sesión'),
              onPressed: () {
                // luego harás la petición
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
