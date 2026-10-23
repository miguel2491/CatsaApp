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
  final String Descripcion;
  final int activo;
  final int VistoBueno;

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
    required this.Descripcion,
    required this.activo,
    required this.VistoBueno,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      IdPedido: json['IdPedido'] is int
          ? json['IdPedido']
          : int.tryParse(json['IdPedido']?.toString() ?? '0') ?? 0,
      Planta: parseString(json['Planta']),
      IdCotizacion: json['idCotizacion'] is int
          ? json['idCotizacion']
          : int.tryParse(json['idCotizacion']?.toString() ?? '0') ?? 0,
      NoObra: parseString(json['NoObra']),
      Obra: parseString(json['Obra']),
      NoCliente: parseString(json['NoCliente']),
      Nombre: parseString(json['Cliente']),
      Pago: parseString(json['Pago']),
      PrecioProducto: parseDouble(json['PrecioProducto']),
      PrecioExtra: parseDouble(json['PrecioExtra']),
      Bomba: parseString(json['CodBomba']),
      PrecioBomba: parseDouble(json['PrecioBomba']),
      Elemento: parseString(json['Elemento']),
      Cantidad: parseDouble(json['M3']),
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
      Descripcion: parseString(json['Descripcion']),
      activo: json['activo'] is bool
          ? (json['activo'] ? 1 : 0)
          : json['activo'] is int
          ? json['activo']
          : int.tryParse(json['activo']?.toString() ?? '0') ?? 0,

      VistoBueno: json['VistoBueno'] is bool
          ? (json['VistoBueno'] ? 1 : 0)
          : json['VistoBueno'] is int
          ? json['VistoBueno']
          : int.tryParse(json['VistoBueno']?.toString() ?? '0') ?? 0,
    );
  }

  @override
  String toString() {
    return 'Pedido(Pedido: $IdPedido, Planta: $Planta, NoCliente: $NoCliente, Cliente: $Nombre, idCotizacion: $IdCotizacion, Producto: $Producto, VB: $VistoBueno, Programado: $activo)';
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
