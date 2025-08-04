class Online {
  final String planta;
  final int idpedido;
  final String obra;
  final double ordenado;
  final double enviado;
  final DateTime fecha;
  final String orden;
  final int noremision;
  final int linea;
  final String producto;
  final double cantidad;
  final String tr;
  final String conductor;
  final String solicitado;
  final String espaciado;
  final String inicio_carga;
  final String fin_carga;
  final String salida_planta;
  final String llega_obra;
  final String regreso_obra;
  final String llega_planta;
  final String tiempo_ciclo;
  final String re_trabajo;
  final String no_cancel;
  final String motivo_retardo;
  final String km_inicial;
  final String km_final;
  final double distanciaKm;
  final String odo_inicial;
  final String odo_final;
  final String estatus;
  final String status;

  Online({
    required this.planta,
    required this.idpedido,
    required this.obra,
    required this.ordenado,
    required this.enviado,
    required this.fecha,
    required this.orden,
    required this.noremision,
    required this.linea,
    required this.producto,
    required this.cantidad,
    required this.tr,
    required this.conductor,
    required this.solicitado,
    required this.espaciado,
    required this.inicio_carga,
    required this.fin_carga,
    required this.salida_planta,
    required this.llega_obra,
    required this.regreso_obra,
    required this.llega_planta,
    required this.tiempo_ciclo,
    required this.re_trabajo,
    required this.no_cancel,
    required this.motivo_retardo,
    required this.km_inicial,
    required this.km_final,
    required this.distanciaKm,
    required this.odo_inicial,
    required this.odo_final,
    required this.estatus,
    required this.status,
  });

  factory Online.fromJson(Map<String, dynamic> json) {
    return Online(
      planta: parseString(json['Planta']),
      idpedido: parseInt(json['IdPedido']),
      obra: parseString(json['Obra']),
      ordenado: parseDouble(json['Ordenado']),
      enviado: parseDouble(json['Enviado']),
      fecha: parseDateTime(json['Fecha']),
      orden: parseString(json['Orden']),
      noremision: parseInt(json['NoRemision']),
      linea: parseInt(json['Linea']),
      producto: parseString(json['Producto']),
      cantidad: parseDouble(json['Cantidad']),
      tr: parseString(json['TR']),
      conductor: parseString(json['Conductor']),
      solicitado: parseString(json['Solicitado']),
      espaciado: parseString(json['Espaciado']),
      inicio_carga: parseString(json['InicioCarga']),
      fin_carga: parseString(json['FinCarga']),
      salida_planta: parseString(json['SalioDePlanta']),
      llega_obra: parseString(json['LlegoAObra']),
      regreso_obra: parseString(json['RegresaDeObra']),
      llega_planta: parseString(json['LlegoAPlanta']),
      tiempo_ciclo: parseString(json['TiempoCiclo']),
      re_trabajo: parseString(json['Retrabajo']),
      no_cancel: parseString(json['NoCancel']),
      motivo_retardo: parseString(json['MotivoRetardo']),
      km_inicial: parseString(json['KmInicial']),
      km_final: parseString(json['KmFinal']),
      distanciaKm: parseDouble(json['DistanciaKm']),
      odo_inicial: parseString(json['OdoInicial']),
      odo_final: parseString(json['OdoFinal']),
      estatus: parseString(json['Estatus']),
      status: parseString(json['Status']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Online &&
          runtimeType == other.runtimeType &&
          idpedido == other.idpedido;

  @override
  int get hashCode => idpedido.hashCode;
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

DateTime parseDateTime(dynamic value) {
  if (value == null || value.toString().isEmpty) {
    return DateTime(1900); // O algún valor por defecto
  }

  try {
    return DateTime.parse(value.toString());
  } catch (e) {
    return DateTime(1900); // O lanza un error si prefieres
  }
}
