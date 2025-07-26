class Volumen {
  final double volumen;
  final double mbdir;
  final double p1min;
  final double p1max;
  final double p2min;
  final double p2max;
  final double p3min;
  final double p3max;

  Volumen({
    required this.volumen,
    required this.mbdir,
    required this.p1min,
    required this.p1max,
    required this.p2min,
    required this.p2max,
    required this.p3min,
    required this.p3max,
  });

  factory Volumen.fromJson(Map<String, dynamic> json) {
    return Volumen(
      volumen: parseDouble(json['VOLUMEN']),
      mbdir: parseDouble(json['MBDIR']),
      p1min: parseDouble(json['P1MIN']),
      p1max: parseDouble(json['P1MAX']),
      p2min: parseDouble(json['P2MIN']),
      p2max: parseDouble(json['P2MAX']),
      p3min: parseDouble(json['P3MIN']),
      p3max: parseDouble(json['P3MAX']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Volumen &&
          runtimeType == other.runtimeType &&
          volumen == other.volumen;

  @override
  int get hashCode => volumen.hashCode;

  @override
  String toString() {
    return 'Volumen(VOLUMEN: $volumen P3Min: $p3min)';
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
