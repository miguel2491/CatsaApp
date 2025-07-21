import 'dart:ffi';

class ProductoC {
  final String producto;
  final String descripcion;
  final String familia;
  final int resistencia;
  final String edad;
  final int tma;
  final int revenimiento;
  final String colocacion;
  final String variante;
  final double costo;
  final int flg_col;

  ProductoC({
    required this.producto,
    required this.descripcion,
    required this.familia,
    required this.resistencia,
    required this.edad,
    required this.tma,
    required this.revenimiento,
    required this.colocacion,
    required this.variante,
    required this.costo,
    required this.flg_col,
  });

  factory ProductoC.fromJson(Map<String, dynamic> json) {
    return ProductoC(
      producto: parseString(json['Producto']),
      descripcion: parseString(json['Descripcion']),
      familia: parseString(json['Familia']),
      resistencia: parseInt(json['Resistencia']),
      edad: parseString(json['Edad']),
      tma: parseInt(json['TMA']),
      revenimiento: parseInt(json['Revenimiento']),
      colocacion: parseString(json['Colocacion']),
      variante: parseString(json['Variante']),
      costo: parseDouble(json['COSTO']),
      flg_col: parseInt(json['FlgCol']),
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
