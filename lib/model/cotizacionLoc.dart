class CotizacionLoc {
  final int? id;
  final String planta;
  final String? noCliente;
  final String? noObra;
  final String? cliente;
  final String? municipio;
  final String? contacto;
  final String? obra;
  final String? direccion;
  final String? idVendedor;
  final int flagIva;
  final int flagTotal;
  final int flagCondiciones;
  final int? idMotivo;
  final int fuente;
  final String coordenadas;
  final int flagObservaciones;
  final int segmento;
  final int? canal;
  final int? preCot;
  final String elemento;
  final int enviado;

  CotizacionLoc({
    this.id,
    required this.planta,
    this.noCliente,
    this.noObra,
    this.cliente,
    this.municipio,
    this.contacto,
    this.obra,
    this.direccion,
    this.idVendedor,
    required this.flagIva,
    required this.flagTotal,
    required this.flagCondiciones,
    this.idMotivo,
    required this.fuente,
    required this.coordenadas,
    required this.flagObservaciones,
    required this.segmento,
    this.canal,
    this.preCot,
    required this.elemento,
    this.enviado = 0,
  });

  factory CotizacionLoc.fromMap(Map<String, dynamic> map) {
    return CotizacionLoc(
      id: map['id'],
      planta: map['Planta'] ?? '',
      noCliente: map['NoCliente'] ?? '',
      noObra: map['NoObra'] ?? '',
      cliente: map['Cliente'] ?? '',
      municipio: map['Municipio'] ?? '',
      contacto: map['Contacto'] ?? '',
      obra: map['Obra'] ?? '',
      direccion: map['Direccion'] ?? '',
      idVendedor: map['IdVendedor'] ?? '',
      flagIva: map['FlagIVA'] ?? 0,
      flagTotal: map['FlagTotal'] ?? 0,
      flagCondiciones: map['FlagCondiciones'] ?? 0,
      idMotivo: map['IdMotivo'] ?? 0,
      fuente: map['Fuente'],
      coordenadas: map['Coordenadas'] ?? 0,
      flagObservaciones: map['FlagObservaciones'] ?? 0,
      segmento: map['Segmento'],
      canal: map['Canal'],
      preCot: map['PreCot'] ?? 0,
      elemento: map['Elemento'] ?? '-',
      enviado: map['enviado'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Planta': planta,
      'NoCliente': noCliente,
      'NoObra': noObra,
      'Cliente': cliente,
      'Municipio': municipio,
      'Contacto': contacto,
      'Obra': obra,
      'Direccion': direccion,
      'IdVendedor': idVendedor,
      'FlagIVA': flagIva,
      'FlagTotal': flagTotal,
      'FlagCondiciones': flagCondiciones,
      'IdMotivo': idMotivo,
      'Fuente': fuente,
      'Coordenadas': coordenadas,
      'FlagObservaciones': flagObservaciones,
      'Segmento': segmento,
      'Canal': canal,
      'PreCot': preCot,
      'Elemento': elemento,
      'enviado': enviado,
    };
  }
}
