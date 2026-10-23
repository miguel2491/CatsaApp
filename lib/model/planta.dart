class Planta {
  final String id; // BMD1
  final String planta; // MERIDA_BCA

  Planta({required this.id, required this.planta});

  /// 🔹 Desde API
  factory Planta.fromJson(Map<String, dynamic> json) {
    return Planta(
      id: json['IdPlanta']?.toString() ?? '',
      planta: json['Planta']?.toString() ?? '',
    );
  }

  /// 🔹 Desde SQLite
  factory Planta.fromMap(Map<String, dynamic> map) {
    return Planta(
      id: map['clave']?.toString() ?? '',
      planta: map['planta']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Planta(planta: $planta, clave: $id)';
  }

  /// 🔹 Para SQLite
  Map<String, dynamic> toMap() {
    return {'clave': id, 'planta': planta};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Planta && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
