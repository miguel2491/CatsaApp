class Cotizador {
  final int idCotizacion;
  final String planta;
  final String noCotizacion;
  final String noCliente;
  final String cliente;
  final String noObra;
  final String obra;
  final String estatus;

  Cotizador({
    required this.idCotizacion,
    required this.planta,
    required this.noCotizacion,
    required this.noCliente,
    required this.cliente,
    required this.noObra,
    required this.obra,
    required this.estatus,
  });

  factory Cotizador.fromJson(Map<String, dynamic> json) {
    return Cotizador(
      idCotizacion: json['IdCotizacion'] is int
          ? json['IdCotizacion']
          : int.tryParse(json['IdCotizacion']?.toString() ?? '0') ?? 0,
      planta: parseString(json['Planta']),
      noCotizacion: parseString(json['NoObra']),
      noCliente: parseString(json['NoCliente']),
      cliente: parseString(json['Cliente']),
      noObra: parseString(json['NoObra']),
      obra: parseString(json['Obra']),
      estatus: parseString(json['Estatus']),
    );
  }
  @override
  String toString() {
    return 'Cotizacion(id: $idCotizacion, planta: $planta, cliente: $cliente, nocliente: $noCliente, obra:$obra, noobra:$noObra)';
  }
}

String parseString(dynamic value) {
  if (value == null || value is Map || value is List) return '';
  return value.toString();
}
