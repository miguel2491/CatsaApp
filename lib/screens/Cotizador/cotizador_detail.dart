import 'package:flutter/material.dart';
import '../../model/cotizador.dart';

class CotizadorDetail extends StatelessWidget {
  final Cotizador cotizador;

  const CotizadorDetail({super.key, required this.cotizador});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle Cotización ${cotizador.idCotizacion}'),
        backgroundColor: const Color(0xFF0D0F57),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildDetail('Cliente', cotizador.cliente),
            _buildDetail('Obra', cotizador.obra),
            _buildDetail('Planta', cotizador.planta),
            _buildDetail('No. Cotización', cotizador.noCotizacion),
            _buildDetail('Estatus', cotizador.estatus),
            // Puedes agregar más campos si quieres
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
        subtitle: Text(value.isNotEmpty ? value : 'Sin información'),
      ),
    );
  }
}
