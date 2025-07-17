class ProductoC {
  final String producto;
  final double precio;

  ProductoC({required this.producto, required this.precio});

  factory ProductoC.fromJson(Map<String, dynamic> json) {
    return ProductoC(
      producto: parseString(json['Producto']),
      precio: parseDouble(json['Precio']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductoC &&
          runtimeType == other.runtimeType &&
          producto == other.producto;

  @override
  int get hashCode => producto.hashCode;
}

String parseString(dynamic value) {
  if (value == null || value is Map || value is List) return '';
  return value.toString();
}

double parseDouble(dynamic value) {
  if (value == null || value is Map || value is List) return 0.0;
  return double.tryParse(value.toString()) ?? 0.0;
}

int parseInt(dynamic value) {
  if (value == null || value is Map || value is List) return 0;
  return int.tryParse(value.toString()) ?? 0;
}

bool parseBool(dynamic value) {
  if (value == null || value is Map || value is List) return false;
  if (value is bool) return value;
  final str = value.toString().toLowerCase();
  return str == 'true' || str == '1';
}
