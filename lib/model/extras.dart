class Extras {
  final String concepto;
  final double cantidad;
  final String descripcion;

  Extras({
    required this.concepto,
    required this.cantidad,
    required this.descripcion,
  });

  factory Extras.fromJson(Map<String, dynamic> json) {
    return Extras(
      concepto: parseString(json['Concepto']),
      cantidad: parseDouble(json['Cantidad']),
      descripcion: parseString(json['Descripcion']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Extras &&
          runtimeType == other.runtimeType &&
          concepto == other.concepto;

  @override
  int get hashCode => concepto.hashCode;
}

String parseString(dynamic value) {
  if (value == null || value is Map || value is List) return '';
  return value.toString();
}

double parseDouble(dynamic value) {
  if (value == null || value is Map || value is List) return 0.0;
  return double.tryParse(value.toString()) ?? 0.0;
}
