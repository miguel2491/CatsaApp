import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> _login() async {
    final username = emailController.text.trim();
    final password = passwordController.text;

    setState(() => loading = true);
    // Obtener el token FCM guardado
    final url = Uri.parse(
      'http://apicatsa.catsaconcretos.mx:2543/api/Login/GetUsuario',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'usuario': username, 'pass': password}),
    );

    setState(() => loading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //print(data);
      if (data['mensaje'] == "Bienvenido") {
        final token = data['id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        _tokenUpd();
      } else {
        _showError('Usuario o contraseña incorrectos');
      }
    } else {
      _showError('Error del servidor (${response.statusCode})');
    }
  }

  Future<void> _tokenUpd() async {
    final username = emailController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final fcmToken = prefs.getString('fcm_token') ?? '';
    // Obtener el token FCM guardado
    print('✅ LOGIN Token FCM: $fcmToken');
    final url = Uri.parse(
      'http://apicatsa.catsaconcretos.mx:2543/api/Login/UpdTokenLogin',
    );
    print(username);
    print(fcmToken);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'usuario': username, 'fcm_token': fcmToken}),
    );
    //print(response.statusCode);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //print(data);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      _showError('Error del servidor (${response.statusCode})');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F57),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 20),
                const Text(
                  'Bienvenido',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 20),
                _buildTextField(label: 'Usuario', controller: emailController),
                const SizedBox(height: 10),
                _buildTextField(
                  label: 'Password',
                  controller: passwordController,
                  obscure: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  onPressed: loading ? null : _login,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Iniciar sesión',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
