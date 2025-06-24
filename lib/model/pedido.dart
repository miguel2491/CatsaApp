class Pedido {
  final int IdPedido;
  final double Cantidad;
  final DateTime Fecha;
  final String Planta;
  final String Asesor;
  final String UsuarioCreo;
  final String NoObra;
  final String Obra;
  final String Producto;

  Pedido({
    required this.IdPedido,
    required this.Cantidad,
    required this.Fecha,
    required this.Planta,
    required this.Asesor,
    required this.UsuarioCreo,
    required this.Obra,
    required this.Producto,
    required this.NoObra,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      IdPedido: json['IdPedido'] is int
          ? json['IdPedido']
          : int.tryParse(json['IdPedido']?.toString() ?? '0') ?? 0,
      Cantidad: json['M3'] is double
          ? json['M3']
          : double.tryParse(json['CantidadM3']?.toString() ?? '0') ?? 0.0,
      Fecha: DateTime.parse(json['FechaHoraPedido']),
      Planta: parseString(json['Planta']),
      Asesor: parseString(json['Asesor']),
      UsuarioCreo: parseString(json['UsuarioCreo']),
      NoObra: parseString(json['NoObra']),
      Obra: parseString(json['Obra']),
      Producto: parseString(json['Producto']),
    );
  }
}

String parseString(dynamic value) {
  if (value == null || value is Map || value is List) return '';
  return value.toString();
}
