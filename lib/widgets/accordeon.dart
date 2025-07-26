import 'package:flutter/material.dart';
import '../model/productoC.dart'; // Asegúrate de que esta ruta sea correcta

class ProductoAccordion extends StatefulWidget {
  final ProductoC producto;
  final double mbminimo;
  final double mop;
  final double comision;
  final bool isSelected;
  final VoidCallback onToggleSeleccion;
  final VoidCallback onDetallePressed;
  final VoidCallback onEliminar;

  const ProductoAccordion({
    super.key,
    required this.producto,
    required this.mbminimo,
    required this.mop,
    required this.comision,
    required this.isSelected,
    required this.onToggleSeleccion,
    required this.onDetallePressed,
    required this.onEliminar,
  });

  @override
  State<ProductoAccordion> createState() => _ProductoAccordionState();
}

class _ProductoAccordionState extends State<ProductoAccordion> {
  double precio = 0.0;
  double mtotal = 0.0;
  double sugemop = 0.0;
  double precioSE = 0.0;
  double ext = 0.0;
  double mb = 0.0;

  @override
  void initState() {
    super.initState();
    _fnVars();
    // calcularComision();
  }

  Future<void> _fnVars() async {
    final mtotal_ = widget.producto.costo + widget.mbminimo;
    final sugemop_ = 100.00 - widget.mop;
    final precioSE_ = mtotal_ / sugemop_ * 100;
    final ext_ = 0.0;
    final mb_ = precioSE_ - (widget.producto.costo + ext_);
    setState(() {
      mtotal = mtotal_;
      sugemop = sugemop_;
      precioSE = precioSE_;
      ext = ext_;
      mb = mb_;
      //comision = calcularC; // Aquí puedes usar un cálculo real si lo necesitas
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          widget.producto.producto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Costo MP: \$${widget.producto.costo.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.blue),
            ),
            Text(
              'MB Mínimo: \$${widget.mbminimo.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green),
            ),
            Text(
              'Costo Total: \$${mtotal.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        children: [
          _buildDetailRow(
            'Precio Sugerido + Extras:',
            precioSE.toStringAsFixed(2),
          ),
          _buildDetailRow('Precio Sugerido (m³):', precioSE.toStringAsFixed(2)),
          _buildDetailRowI(
            'Precio Venta m3:',
            TextFormField(
              initialValue: precioSE.toStringAsFixed(2),
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
          _buildDetailRowI(
            '% Venta:',
            TextFormField(
              initialValue: widget.mop.toStringAsFixed(2),
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
          _buildDetailRow('Comisión:', widget.comision.toStringAsFixed(2)),
          _buildDetailRowI(
            'Margen Bruto:',
            TextFormField(
              initialValue: mb.toStringAsFixed(2),
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
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: widget.onEliminar,
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
                foregroundColor: Colors.white,
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
