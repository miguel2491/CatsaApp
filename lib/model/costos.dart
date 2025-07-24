class CostoC {
  final String fecha;
  final double cpc;

  CostoC({required this.fecha, required this.cpc});

  factory CostoC.fromJson(Map<String, dynamic> json) {
    return CostoC(fecha: json['Fecha'], cpc: (json['CPC'] as num).toDouble());
  }
}
