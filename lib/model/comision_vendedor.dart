class ComisionVendedor {
  final String vendedor;
  final double M3Especial;
  final double M3Normal;
  final double M3;
  final double Total;

  ComisionVendedor({
    required this.vendedor,
    required this.M3Especial,
    required this.M3Normal,
    required this.M3,
    required this.Total,
  });

  factory ComisionVendedor.fromJson(Map<String, dynamic> json) {
    return ComisionVendedor(
      vendedor: parseString(json['VENDEDOR']),
      M3Especial: parseDouble(json['M3Especial']),
      M3Normal: parseDouble(json['M3Normal']),
      M3: parseDouble(json['M3']),
      Total: parseDouble(json['Total']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComisionVendedor &&
          runtimeType == other.runtimeType &&
          vendedor == other.vendedor;

  @override
  int get hashCode => vendedor.hashCode;
}

String parseString(dynamic value) {
  if (value == null || value is Map || value is List) return '';
  return value.toString();
}

double parseDouble(dynamic value) {
  if (value == null || value is Map || value is List) return 0.0;
  return double.tryParse(value.toString()) ?? 0.0;
}
