import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio')),
      drawer: AppDrawer(),
      body: Center(child: Text('Bienvenido a la App')),
    );
  }
}
