class Pedido {
  final int IdPedido;
  final String Planta;
  final int IdCotizacion;
  final String NoObra;
  final String Obra;
  final String NoCliente;
  final String Nombre;
  final String Pago;
  final double PrecioProducto;
  final double PrecioExtra;
  final String Bomba;
  final double PrecioBomba;
  final String Elemento;
  final double Cantidad;
  final DateTime FechaHoraPedido;
  final DateTime HrSalida;
  final int M3Viaje;
  final int TRecorrido;
  final int TDescarga;
  final int Espaciado;
  final String Observaciones;
  final String Recibe;
  final String Asesor;
  final String UsuarioCreo;
  final String Producto;

  Pedido({
    required this.IdPedido,
    required this.Planta,
    required this.IdCotizacion,
    required this.NoObra,
    required this.Obra,
    required this.NoCliente,
    required this.Nombre,
    required this.Pago,
    required this.PrecioProducto,
    required this.PrecioExtra,
    required this.Bomba,
    required this.PrecioBomba,
    required this.Elemento,
    required this.Cantidad,
    required this.FechaHoraPedido,
    required this.HrSalida,
    required this.M3Viaje,
    required this.TRecorrido,
    required this.TDescarga,
    required this.Espaciado,
    required this.Observaciones,
    required this.Recibe,
    required this.Asesor,
    required this.UsuarioCreo,
    required this.Producto,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      IdPedido: json['IdPedido'] is int
          ? json['IdPedido']
          : int.tryParse(json['IdPedido']?.toString() ?? '0') ?? 0,
      Planta: parseString(json['Planta']),
      IdCotizacion: json['IdCotizacion'] is int
          ? json['IdCotizacion']
          : int.tryParse(json['IdCotizacion']?.toString() ?? '0') ?? 0,
      NoObra: parseString(json['NoObra']),
      Obra: parseString(json['Obra']),
      NoCliente: parseString(json['NoCliente']),
      Nombre: parseString(json['Nombre']),
      Pago: parseString(json['Pago']),
      PrecioProducto: parseDouble(json['PrecioProducto']),
      PrecioExtra: parseDouble(json['PrecioExtra']),
      Bomba: parseString(json['CodBomba']),
      PrecioBomba: parseDouble(json['PrecioBomba']),
      Elemento: parseString(json['Elemento']),
      Cantidad: parseDouble(json['CantidadM3']),
      FechaHoraPedido: json['FechaHoraPedido'] != null
          ? DateTime.parse(json['FechaHoraPedido'])
          : DateTime(2000), // o DateTime.now() o lo que definas como seguro
      HrSalida: json['HrSalida'] != null
          ? DateTime.parse(json['HrSalida'])
          : DateTime(2000),
      M3Viaje: json['M3Viaje'] is int
          ? json['M3Viaje']
          : int.tryParse(json['M3Viaje']?.toString() ?? '0') ?? 0,
      TRecorrido: json['TRecorrido'] is int
          ? json['TRecorrido']
          : int.tryParse(json['TRecorrido']?.toString() ?? '0') ?? 0,
      TDescarga: json['TDescarga'] is int
          ? json['TDescarga']
          : int.tryParse(json['TDescarga']?.toString() ?? '0') ?? 0,
      Espaciado: json['Espaciado'] is int
          ? json['Espaciado']
          : int.tryParse(json['Espaciado']?.toString() ?? '0') ?? 0,
      Observaciones: parseString(json['Observaciones']),
      Recibe: parseString(json['Recibe']),
      Asesor: parseString(json['Asesor']),
      UsuarioCreo: parseString(json['UsuarioCreo']),
      Producto: parseString(json['Producto']),
    );
  }
}

String parseString(dynamic value) {
  if (value == null || value is Map || value is List) return '';
  return value.toString();
}

double parseDouble(dynamic value) {
  if (value == null || value is Map || value is List) return 0.0;
  return double.tryParse(value.toString()) ?? 0.0;
}
