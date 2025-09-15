import 'dart:ffi';

class ExtraServ {
  final int IdExtra;
  final double Costo;
  final String Descripcion;
  final double CantMin;
  final int Nivel;
  final int Tipo;
  final String Unidad;
  final String Observaciones;

  ExtraServ({
    required this.IdExtra,
    required this.Costo,
    required this.Descripcion,
    required this.CantMin,
    required this.Nivel,
    required this.Tipo,
    required this.Unidad,
    required this.Observaciones,
  });

  factory ExtraServ.fromJson(Map<String, dynamic> json) {
    return ExtraServ(
      IdExtra: parseInt(json['IdExtra']),
      Costo: parseDouble(json['Costo']),
      Descripcion: parseString(json['Descripcion']),
      CantMin: parseDouble(json['CantMin']),
      Nivel: parseInt(json['Nivel']),
      Tipo: parseInt(json['Tipo']),
      Unidad: parseString(json['Unidad']),
      Observaciones: parseString(json['Observaciones']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtraServ &&
          runtimeType == other.runtimeType &&
          IdExtra == other.IdExtra;

  @override
  int get hashCode => IdExtra.hashCode;
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
