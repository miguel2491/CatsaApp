class Producto {
  final String producto;
  final double cantidad;
  final double m3Bomba;
  final double bomba;
  final double mop;
  final double precio;
  final bool flagVoBo;
  final int autoriza;
  final String comentario;
  final bool flg;
  final bool flagImprimir;
  final double mb;

  Producto({
    required this.producto,
    required this.cantidad,
    required this.m3Bomba,
    required this.bomba,
    required this.mop,
    required this.precio,
    required this.flagVoBo,
    required this.autoriza,
    required this.comentario,
    required this.flg,
    required this.flagImprimir,
    required this.mb,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      producto: parseString(json['Producto']),
      cantidad: parseDouble(json['Cantidad']),
      m3Bomba: parseDouble(json['M3Bomba']),
      bomba: parseDouble(json['Bomba']),
      mop: parseDouble(json['MOP']),
      precio: parseDouble(json['Precio']),
      flagVoBo: parseBool(json['FlagVoBo']),
      autoriza: parseInt(json['Autoriza']),
      comentario: parseString(json['Comentario']),
      flg: parseBool(json['Flg']),
      flagImprimir: parseBool(json['FlagImprimir']),
      mb: parseDouble(json['MB']),
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

int parseInt(dynamic value) {
  if (value == null || value is Map || value is List) return 0;
  return int.tryParse(value.toString()) ?? 0;
}

bool parseBool(dynamic value) {
  if (value == null || value is Map || value is List) return false;
  if (value is bool) return value;
  final str = value.toString().toLowerCase();
  return str == 'true' || str == '1';
}
