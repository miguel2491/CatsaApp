class CotizacionDetLoc {
  final int id;
  final int idCotizacion;
  final double cantidad;
  final String producto;
  final double mop;
  final double m3Bomba;
  final double bomba;
  final double precio;
  final double mb;
  final int flagVoBo;
  final String? comentario;
  final int flagImprimir;
  final double costoMP;
  final int enviado;

  CotizacionDetLoc({
    required this.id,
    required this.idCotizacion,
    required this.cantidad,
    required this.producto,
    required this.mop,
    required this.m3Bomba,
    required this.bomba,
    required this.precio,
    required this.mb,
    required this.flagVoBo,
    this.comentario,
    required this.flagImprimir,
    required this.costoMP,
    this.enviado = 0,
  });

  factory CotizacionDetLoc.fromMap(Map<String, dynamic> map) {
    return CotizacionDetLoc(
      id: map['id'],
      idCotizacion: map['idCotizacion'],
      cantidad: map['Cantidad'] ?? 0.0,
      producto: map['Producto'] ?? '-',
      mop: map['Mop'] ?? 0.0,
      m3Bomba: map['M3Bomba'] ?? 0.0,
      bomba: map['Bomba'] ?? 0.0,
      precio: map['Precio'] ?? 0.0,
      mb: map['MB'] ?? 0.0,
      flagVoBo: map['FlagVB'] ?? 0,
      comentario: map['Comentario'] ?? '',
      flagImprimir: map['FlagImprimir'] ?? 0,
      costoMP: map['CostoMP'] ?? 0.0,
      enviado: map['enviado'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idCotizacion': idCotizacion,
      'Cantidad': cantidad,
      'Producto': producto,
      'MOP': mop,
      'M3Bomba': m3Bomba,
      'Bomba': bomba,
      'Precio': precio,
      'MB': mb,
      'FlagVB': flagVoBo,
      'Comentario': comentario,
      'FlagImprimir': flagImprimir,
      'CostoMP': costoMP,
      'enviado': enviado,
    };
  }
}
