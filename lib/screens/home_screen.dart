import 'package:catsa/screens/Cotizador/cotizacion.dart';
import 'package:catsa/screens/Pedidos/pedido_form.dart';
import 'package:catsa/screens/Pedidos/pedido_linea.dart';
import 'package:catsa/screens/QR/leerQR.dart';
import 'package:catsa/service/api.dart';
//import 'package:catsa/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:catsa/core/app_color.dart';
import '../widgets/app_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:catsa/service/apiLocal.dart' as api_local;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    await recargarPantalla();
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Cotizacion()),
      );
      return; // no cambies _selectedIndex si navegas
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PedidoOnline()),
      );
      return;
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PedidoForm()),
      );
      return;
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LeerQR()),
      );
      return;
    }
    // setState(() {
    //   _selectedIndex = index;
    // });
  }

  @override
  void initState() {
    super.initState();
    verPlantasDebug();
    verCotizacionLoc();
  }

  Future<void> verPlantasDebug() async {
    await syncPlantas();

    // final plantas = await getPlantas();

    // for (final p in plantas) {
    //   print('ID: ${p['id']} | Clave: ${p['clave']} | Planta: ${p['planta']}');
    // }
  }

  Future<void> verCotizacionLoc() async {
    try {
      print('🏴‍☠️👻');
      await api_local.getCotizaciones();
      await api_local.getCotizacionesD();
      await api_local.getCotizacionesDMP();
      await api_local.getCotizacionesEx();
    } catch (e) {
      print('❌ ERROR getPlantas: $e');
    }
  }

  Future<void> recargarPantalla() async {
    print('🏴‍☠️🐦‍🔥🏴‍☠️');
    await api_local.getCotizaciones();
    await api_local.getCotizacionesD();
    await api_local.getCotizacionesDMP();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CatsaApp'),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0F57), Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 150),
              Transform.rotate(
                angle: 0.5, // en radianes
                child: Image.asset('assets/images/logo.png', height: 250),
              ),
              const Text(
                "Bienvenido",
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFBF4141),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.file),
            label: 'Cotización',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.feed),
            label: 'En Línea',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.shoppingBag),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.qrcode),
            label: 'Lector QR',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
