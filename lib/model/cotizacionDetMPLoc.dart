class CotizacionDetMPLoc {
  final int id;
  final int idCotizacion;
  final double cantidad;
  final String producto;
  final String descripcion;
  final double cpc;
  final double h2o;
  final double gravas;
  final double arenas;
  final double aditivos;
  final double costo;
  final double mop0;
  final int enviado;

  CotizacionDetMPLoc({
    required this.id,
    required this.idCotizacion,
    required this.cantidad,
    required this.producto,
    required this.descripcion,
    required this.cpc,
    required this.h2o,
    required this.gravas,
    required this.arenas,
    required this.aditivos,
    required this.costo,
    required this.mop0,
    this.enviado = 0,
  });

  factory CotizacionDetMPLoc.fromMap(Map<String, dynamic> map) {
    return CotizacionDetMPLoc(
      id: map['id'],
      idCotizacion: map['idCotizacion'],
      cantidad: map['Cantidad'] ?? 0.0,
      producto: map['Producto'] ?? '-',
      descripcion: map['Descripcion'] ?? 0.0,
      cpc: map['CPC'] ?? 0.0,
      h2o: map['H2O'] ?? 0.0,
      gravas: map['GRAVAS'] ?? 0.0,
      arenas: map['ARENAS'] ?? 0.0,
      aditivos: map['ADITIVOS'] ?? 0,
      costo: map['COSTO'] ?? '',
      mop0: map['MOP0'] ?? 0,
      enviado: map['enviado'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idCotizacion': idCotizacion,
      'Cantidad': cantidad,
      'Producto': producto,
      'Descripcion': descripcion,
      'CPC': cpc,
      'H2O': h2o,
      'GRAVAS': gravas,
      'ARENAS': arenas,
      'ADITIVOS': aditivos,
      'COSTO': costo,
      'MOP0': mop0,
      'enviado': enviado,
    };
  }
}
