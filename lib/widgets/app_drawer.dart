import 'package:flutter/material.dart';
import '../screens/page1.dart';
import '../screens/page2.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text('Menú', style: TextStyle(color: Colors.white)),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            title: Text('Página 1'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Page1()),
            ),
          ),
          ListTile(
            title: Text('Página 2'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Page2()),
            ),
          ),
          ListTile(
            title: Text('Cerrar sesión'),
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
