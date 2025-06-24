import 'package:flutter/material.dart';
import '../../model/pedido.dart';

class PedidoDetail extends StatelessWidget {
  final Pedido pedido;

  const PedidoDetail({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido # ${pedido.IdPedido}'),
        backgroundColor: const Color(0xFF0D0F57),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildDetail('Usuario Creo', pedido.UsuarioCreo),
            _buildDetail('Obra', pedido.Obra),
            _buildDetail('Planta', pedido.Planta),
            _buildDetail('Creo', pedido.UsuarioCreo),
            _buildDetail('Producto', pedido.Producto),
            _buildDetail('Cantidad M3', pedido.Cantidad.toStringAsFixed(2)),
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
