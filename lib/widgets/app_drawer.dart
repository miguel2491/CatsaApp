import 'package:catsa/service/apiLocal.dart' as ApiLocal;
import 'package:flutter/material.dart';
import '../screens/Cotizador/cotizaciones.dart';
import '../screens/Pedidos/pedidos.dart';
import '../screens/login_screen.dart';

Future<void> _cerrarSesion(BuildContext context) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text(
        'Se eliminarán todas las cotizaciones y pedidos almacenados localmente que aún no hayan sido enviados. Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );

  if (confirmar == true) {
    await ApiLocal.borrarTodo();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }
}

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
              MaterialPageRoute(builder: (_) => Cotizaciones()),
            ),
          ),
          ListTile(
            title: Text('Pedidos', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Pedidos()),
            ),
          ),
          ListTile(
            title: Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
            onTap: () => _cerrarSesion(context),
          ),
        ],
      ),
    );
  }
}
