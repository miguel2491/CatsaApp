class CotizacionExtLoc {
  final int id;
  final int idCotizacion;
  final int idExtra;
  final String producto;
  final double cantidadUser;
  final double cantidadCot;
  final double precio;
  final double precioUser;
  final int enviado;

  CotizacionExtLoc({
    required this.id,
    required this.idCotizacion,
    required this.idExtra,
    required this.producto,
    required this.cantidadUser,
    required this.cantidadCot,
    required this.precio,
    required this.precioUser,
    this.enviado = 0,
  });

  factory CotizacionExtLoc.fromMap(Map<String, dynamic> map) {
    return CotizacionExtLoc(
      id: map['id'],
      idCotizacion: map['idCotizacion'],
      idExtra: map['Cantidad'] ?? 0.0,
      producto: map['Producto'] ?? '-',
      cantidadUser: map['Mop'] ?? 0.0,
      cantidadCot: map['M3Bomba'] ?? 0.0,
      precioUser: map['Bomba'] ?? 0.0,
      precio: map['Precio'] ?? 0.0,
      enviado: map['enviado'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idCotizacion': idCotizacion,
      'IdExtra': idExtra,
      'Producto': producto,
      'CantidadUser': cantidadUser,
      'CantidadCot': cantidadCot,
      'PrecioUser': precioUser,
      'Precio': precio,
      'enviado': enviado,
    };
  }
}
