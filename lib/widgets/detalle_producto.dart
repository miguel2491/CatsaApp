import 'package:flutter/material.dart';
import '../model/producto.dart';

class DetalleProductoWidget extends StatelessWidget {
  final Producto producto;

  const DetalleProductoWidget({Key? key, required this.producto})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoRow(label: 'Cantidad', value: producto.cantidad.toStringAsFixed(2)),
        InfoRow(label: 'M3 Bomba', value: producto.m3Bomba.toStringAsFixed(2)),
        InfoRow(label: 'Bomba', value: producto.bomba.toStringAsFixed(2)),
        InfoRow(label: 'MOP', value: producto.mop.toStringAsFixed(2)),
        InfoRow(
          label: 'Precio',
          value: '\$${producto.precio.toStringAsFixed(2)}',
        ),
        InfoRow(label: 'Comentario', value: producto.comentario),
        InfoRow(
          label: 'Flag Imprimir',
          value: producto.flagImprimir ? 'Sí' : 'No',
        ),
        // Agrega más si necesitas
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({Key? key, required this.label, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 6, child: Text(value)),
        ],
      ),
    );
  }
}
