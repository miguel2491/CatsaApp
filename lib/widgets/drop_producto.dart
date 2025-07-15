import 'package:flutter/material.dart';
import '../model/producto.dart';

// Widget reutilizable
class ProductoDropdown extends StatelessWidget {
  final List<Producto> producto;
  final Producto? selectedProducto;
  final ValueChanged<Producto?> onChanged;
  final String hintText;

  const ProductoDropdown({
    Key? key,
    required this.producto,
    required this.selectedProducto,
    required this.onChanged,
    this.hintText = 'Selecciona un Producto',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Producto>(
          value: selectedProducto,
          hint: Text(hintText, style: TextStyle(color: Colors.grey.shade600)),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
          style: TextStyle(color: Colors.black, fontSize: 16),
          items: producto.map((producto) {
            return DropdownMenuItem<Producto>(
              value: producto,
              child: Text(producto.producto),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
