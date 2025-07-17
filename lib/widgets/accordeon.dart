import 'package:flutter/material.dart';
import '../model/producto.dart'; // Asegúrate de que esta ruta sea correcta

class ProductoAccordion extends StatelessWidget {
  final Producto producto;
  final VoidCallback onDetallePressed;

  const ProductoAccordion({
    Key? key,
    required this.producto,
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
          producto.producto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Costo Total: \$${producto.precio.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.blue),
            ),
            Text(
              'Costo Total: \$${producto.precio.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green),
            ),
            Text(
              'Otro dato: ', // Aquí el dato extra que quieres mostrar
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        children: [
          _buildDetailRowI(
            'Cantidad (m³):',
            TextFormField(
              initialValue: producto.cantidad.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {},
            ),
          ),
          _buildDetailRow('Bomba (m³):', producto.m3Bomba.toString()),
          _buildDetailRow('MOP:', producto.mop.toString()),
          _buildDetailRow('Comentario:', producto.comentario),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onDetallePressed,
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar'),
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

  Widget _buildDetailRowI(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label)),
          Expanded(flex: 5, child: valueWidget),
        ],
      ),
    );
  }
}
