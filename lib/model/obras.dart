class Obras {
  final String no_obra;
  final String obra;
  final String no_cliente;
  final String vendedor;

  Obras({
    required this.no_obra,
    required this.obra,
    required this.no_cliente,
    required this.vendedor,
  });

  factory Obras.fromJson(Map<String, dynamic> json) {
    return Obras(
      no_obra: parseString(json['NoObra']),
      obra: parseString(json['Obra']),
      no_cliente: parseString(json['NoCliente']),
      vendedor: parseString(json['Vendedor']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Obras &&
          runtimeType == other.runtimeType &&
          no_obra == other.no_obra;

  @override
  int get hashCode => no_obra.hashCode;
  @override
  String toString() {
    return 'Obra(obra:$obra, noobra:$no_obra)';
  }
}

String parseString(dynamic value) {
  if (value == null || value is Map || value is List) return '';
  return value.toString();
}
