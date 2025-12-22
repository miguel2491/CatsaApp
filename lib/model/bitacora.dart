import 'package:catsa/model/extra_serv.dart';

class Bitacora {
  final int idbitacora;
  final int idequipo;
  final String planta;
  final String usuario;
  final String fecha;
  final String observaciones;
  final String tipoMov;
  final String comentario;
  final String area;

  Bitacora({
    required this.idbitacora,
    required this.idequipo,
    required this.planta,
    required this.usuario,
    required this.fecha,
    required this.observaciones,
    required this.tipoMov,
    required this.comentario,
    required this.area,
  });

  factory Bitacora.fromJson(Map<String, dynamic> json) {
    return Bitacora(
      idbitacora: parseInt(json['id_bitacora']),
      idequipo: parseInt(json['id_equipo']),
      planta: parseString(json['planta']),
      usuario: parseString(json['usuario']),
      fecha: parseString(json['fecha']),
      observaciones: parseString(json['observaciones']),
      tipoMov: parseString(json['tipoMov']),
      comentario: parseString(json['comentario']),
      area: parseString(json['area']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bitacora &&
          runtimeType == other.runtimeType &&
          idbitacora == other.idbitacora;

  @override
  int get hashCode => idbitacora.hashCode;
}

String parseString(dynamic value) {
  if (value == null || value is Map || value is List) return '';
  return value.toString();
}
