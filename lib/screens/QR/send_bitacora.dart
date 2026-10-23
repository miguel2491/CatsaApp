import 'package:flutter/material.dart';
import 'package:catsa/service/api.dart' as api_service;
import 'package:catsa/model/planta.dart';
import 'package:catsa/widgets/dropdown.dart';
import '../home_screen.dart';

class SendQR extends StatefulWidget {
  final String qrCode;

  const SendQR({super.key, required this.qrCode});

  @override
  State<SendQR> createState() => _SendQRState();
}

class _SendQRState extends State<SendQR> {
  Planta? _selectedPlanta;
  List<Planta> _plantas = [];
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();
  final TextEditingController comentarioController = TextEditingController();

  bool _enviando = false;
  //----------------------------------------------------------------------------
  String? _selectedArea;
  final List<String> _area = [
    'Sistemas',
    'Operaciones',
    'Finanzas',
    'Compras',
    'Ventas',
  ];
  String? _selectedMov;
  final List<String> _movimiento = [
    'Resguardo',
    'Prestación',
    'Asiganción',
    'Baja',
    'Mantenimiento',
  ];
  //============================================================================
  Future<void> _loadPlantas() async {
    try {
      final plantas = await api_service.fPlantas();
      setState(() {
        _plantas = plantas;
      });
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    var partes = widget.qrCode.split('-');
    var idEquipo = int.tryParse(partes[0]) ?? 0;
    try {
      final data = {
        "id_bitacora": 0,
        "id_equipo": idEquipo,
        "planta": "PUE1",
        "usuario": usuarioController.text,
        "fecha": "2025-10-31",
        "observaciones": observacionesController.text,
        "tipoMov": _selectedMov,
        "comentario": comentarioController.text,
        "area": _selectedArea,
      };

      print('📦 Datos a enviar: $data');

      // 🔹 Aquí harías la llamada a tu API .NET
      final resp = await api_service.sendBitacora(data);
      if (resp.toString().toLowerCase().contains('exitosa')) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(resp.toString())));

        // Espera un momento para que se vea el mensaje
        await Future.delayed(const Duration(milliseconds: 800));

        //Navigator.pop(context); // volver al escáner
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // Si no contiene "exitosa", muestra como error
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Respuesta inesperada: $resp')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar: $e')));
    } finally {
      setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario QR'),
        backgroundColor: const Color(0xFF0D0F57),
        foregroundColor: Colors.white,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Código leído: ${widget.qrCode}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Planta>(
              value: _selectedPlanta,
              decoration: const InputDecoration(
                labelText: 'Planta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.factory),
              ),
              hint: const Text('Selecciona una planta'),
              items: _plantas.map((Planta planta) {
                return DropdownMenuItem<Planta>(
                  value: planta,
                  child: Text(planta.planta),
                );
              }).toList(),
              onChanged: (Planta? newValue) {
                setState(() {
                  _selectedPlanta = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una planta';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usuarioController,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Dropdown(
              label: 'Movimiento',
              selectedValue: _selectedMov,
              items: _movimiento,
              onChanged: (newValue) {
                setState(() {
                  _selectedMov = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            Dropdown(
              label: 'Área',
              selectedValue: _selectedArea,
              items: _area,
              onChanged: (newValue) {
                setState(() {
                  _selectedArea = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: comentarioController,
              decoration: const InputDecoration(
                labelText: 'Comentario',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _enviando ? null : _enviar,
              icon: const Icon(Icons.send),
              label: Text(_enviando ? 'Enviando...' : 'Enviar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D0F57),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
