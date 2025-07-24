class PlantaInfo {
  final String mobilealias;
  final String rolename;
  final double mop;
  final double fijos;
  final double corporativo;
  final double disel;
  final int cpc;
  final double precio;
  final double factor;
  final double vendedor;
  final double gerenteplanta;
  final double regional;
  final int direccion;
  final double llenado;
  final double ciclo;
  final int nivel;
  final String fecha;
  final String vigencia;
  final double mbs;
  final double mba;
  final double mdir;
  final String lat;
  final String lon;

  PlantaInfo({
    required this.mobilealias,
    required this.rolename,
    required this.mop,
    required this.fijos,
    required this.corporativo,
    required this.disel,
    required this.cpc,
    required this.precio,
    required this.factor,
    required this.vendedor,
    required this.gerenteplanta,
    required this.llenado,
    required this.regional,
    required this.direccion,
    required this.ciclo,
    required this.nivel,
    required this.fecha,
    required this.vigencia,
    required this.mbs,
    required this.mba,
    required this.mdir,
    required this.lat,
    required this.lon,
  });

  factory PlantaInfo.fromJson(Map<String, dynamic> json) {
    return PlantaInfo(
      mobilealias: json['MobileAlias'] ?? '-',
      rolename: json['RoleName'] ?? '-',
      mop: json['MOP'] ?? 0,
      fijos: json['FIJOS'] ?? 0,
      corporativo: json['CORPORATIVO'] ?? 0,
      disel: json['DISEL'] ?? 0,
      cpc: json['CPC'] ?? 0,
      precio: json['PRECIO'] ?? 0,
      factor: json['FACTOR'] ?? 0,
      vendedor: json['Vendedor'] ?? 0,
      gerenteplanta: json['GerentePlanta'] ?? 0,
      regional: json['Regional'] ?? 0,
      direccion: json['Direccion'] ?? '-',
      llenado: json['Llenado'] ?? 0,
      ciclo: json['Ciclo'] ?? 0,
      nivel: json['Nivel'] ?? 0,
      fecha: json['Fecha'] ?? '-',
      vigencia: json['Vigencia'] ?? 0,
      mbs: json['MBS'] ?? 0,
      mba: json['MBA'] ?? 0,
      mdir: json['MDIR'] ?? 0,
      lat: json['Lat'] ?? '0',
      lon: json['Lon'] ?? '0',
    );
  }

  @override
  String toString() {
    return 'Info(Role: $rolename)';
  }
}
