class Clientes {
  final String no_cliente;
  final String nombre;

  Clientes({required this.no_cliente, required this.nombre});

  factory Clientes.fromJson(Map<String, dynamic> json) {
    return Clientes(
      no_cliente: parseString(json['NoCliente']),
      nombre: parseString(json['Nombre']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Clientes &&
          runtimeType == other.runtimeType &&
          no_cliente == other.no_cliente;

  @override
  int get hashCode => no_cliente.hashCode;
}

String parseString(dynamic value) {
  if (value == null || value is Map || value is List) return '';
  return value.toString();
}
