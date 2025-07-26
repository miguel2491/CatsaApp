class Comision {
  final String planta;
  final double p1min;
  final double p1max;
  final double p2min;
  final double p2max;
  final double p3min;
  final double p3max;
  final String mes;
  final String ejercicio;
  final double mbdir;

  Comision({
    required this.planta,
    required this.p1min,
    required this.p1max,
    required this.p2min,
    required this.p2max,
    required this.p3min,
    required this.p3max,
    required this.mes,
    required this.ejercicio,
    required this.mbdir,
  });

  factory Comision.fromJson(Map<String, dynamic> json) {
    return Comision(
      planta: parseString(json['planta']),
      p1min: parseDouble(json['P1MIN']),
      p1max: parseDouble(json['P1MAX']),
      p2min: parseDouble(json['P2MIN']),
      p2max: parseDouble(json['P2MAX']),
      p3min: parseDouble(json['P3MIN']),
      p3max: parseDouble(json['P3MAX']),
      mes: parseString(json['MES']),
      ejercicio: parseString(json['EJERCICIO']),
      mbdir: parseDouble(json['MBDIR']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comision &&
          runtimeType == other.runtimeType &&
          planta == other.planta;

  @override
  int get hashCode => planta.hashCode;

  @override
  String toString() {
    return 'Comision(Planta: $planta P1Min: $p1min)';
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
