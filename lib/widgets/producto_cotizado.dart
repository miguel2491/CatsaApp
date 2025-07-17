import 'package:flutter/material.dart';
import '../model/producto.dart';
import 'package:catsa/widgets/detalle_producto.dart';

class ProductoCotizadoPage extends StatelessWidget {
  final Producto producto;

  const ProductoCotizadoPage({Key? key, required this.producto})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle del Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DetalleProductoWidget(producto: producto),
      ),
    );
  }
}
