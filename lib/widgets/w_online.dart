import 'package:catsa/model/pedido_online.dart';
import 'package:flutter/material.dart';

class OnlineAccordion extends StatelessWidget {
  final Online extra;
  final VoidCallback onDetallePressed;

  const OnlineAccordion({
    Key? key,
    required this.extra,
    required this.onDetallePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          extra.idpedido.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Obra: ${extra.obra}',
              style: const TextStyle(color: Colors.blue),
            ),
            Text(
              'Producto: ${extra.producto}',
              style: const TextStyle(color: Colors.green),
            ),
            Text(
              'M3: ${extra.cantidad}',
              style: const TextStyle(color: Colors.green),
            ),
            Text(
              'Enviados: ${extra.enviado}',
              style: const TextStyle(color: Colors.blue),
            ),
            Text(
              'Solicitado: ${extra.solicitado}',
              style: const TextStyle(color: Colors.blue),
            ),
            Text(
              'Hora Salida: ${extra.salida_planta}',
              style: const TextStyle(color: Colors.red),
            ),
            Text(
              'Tiempo Real: ${extra.tiempo_ciclo}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        children: [
          _buildDetailRow('Remisión:', extra.cantidad.toStringAsFixed(2)),
          const SizedBox(height: 10),
          _buildDetailRow('TR:', extra.tr),
          const SizedBox(height: 10),
          _buildDetailRow('Conductor:', extra.conductor),
          const SizedBox(height: 10),
          _buildDetailRow('Acumulado:', extra.cantidad.toStringAsFixed(2)),
          const SizedBox(height: 10),
          _buildDetailRow('Inicio Carga:', extra.inicio_carga),
          const SizedBox(height: 10),
          _buildDetailRow('Inicio Carga:', extra.inicio_carga),
          const SizedBox(height: 10),
          _buildDetailRow('Inicio Carga:', extra.inicio_carga),
          const SizedBox(height: 10),
          _buildDetailRow('Inicio Carga:', extra.inicio_carga),
          const SizedBox(height: 10),
          _buildDetailRow('Inicio Carga:', extra.inicio_carga),

          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onDetallePressed,
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 6, child: Text(value)),
        ],
      ),
    );
  }
}
