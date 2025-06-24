import 'package:flutter/material.dart';
import '../screens/page1.dart';
import '../screens/page2.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF1C2540),
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFFD92353)),
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(20),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          ListTile(
            title: Text('Cotizador', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Page1()),
            ),
          ),
          ListTile(
            title: Text('Pedidos', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Page2()),
            ),
          ),
          ListTile(
            title: Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
