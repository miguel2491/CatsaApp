class Planta {
  final String id;
  final String nombre;

  Planta({required this.id, required this.nombre});

  factory Planta.fromJson(Map<String, dynamic> json) {
    return Planta(nombre: json['Planta'], id: json['IdPlanta']);
  }
}
