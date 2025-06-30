import 'package:flutter/material.dart';

class PedidoForm extends StatefulWidget {
  const PedidoForm({super.key});

  @override
  State<PedidoForm> createState() => _PedidoFormState();
}

class _PedidoFormState extends State<PedidoForm> {
  String? _selectedPlanta; // Variable para almacenar la planta seleccionada
  final List<String> _plantas = [
    'Planta 1',
    'Planta 2',
    'Planta 3',
    'Planta 4',
  ]; // Lista de plantas disponibles

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Pedido'),
        backgroundColor: const Color(0xFF0D0F57),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildPlantaDropdown(), // Widget personalizado para el dropdown
            _buildDetail('Cotización', ''),
            _buildDetail('Cliente', ''),
            // Resto de tus campos...
          ],
        ),
      ),
    );
  }

  Widget _buildPlantaDropdown() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Planta', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedPlanta,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              hint: Text('Selecciona una planta'),
              items: _plantas.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedPlanta = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isNotEmpty ? value : ' '),
      ),
    );
  }
}
