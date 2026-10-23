class Pedidodb {
  final int id;
  final String planta;
  final String noObra;
  final String producto;
  final double precioProducto;
  final double cantidad;
  final String codBomba;
  final double precioBomba;
  final String fechaHoraPedido;
  final String tRecorrido;
  final double m3Viaje;
  final String espaciado;
  final String usuarioCreo;
  final String tDescarga;
  final String hraSalida;
  final double precioExtra;
  final String observaciones;
  final String idPedido;
  final String recibe;
  final String elemento;
  final String pago;
  final String utm;
  final String plantaEnvio;
  final int archivos;
  final String tiempoReal;
  final String distancia;
  final String idCotizacion;
  final int statusEliminado;
  final int enviado;

  Pedidodb({
    required this.id,
    required this.planta,
    required this.noObra,
    required this.producto,
    required this.precioProducto,
    required this.cantidad,
    required this.codBomba,
    required this.precioBomba,
    required this.fechaHoraPedido,
    required this.tRecorrido,
    required this.m3Viaje,
    required this.espaciado,
    required this.usuarioCreo,
    required this.tDescarga,
    required this.hraSalida,
    required this.precioExtra,
    required this.observaciones,
    required this.idPedido,
    required this.recibe,
    required this.elemento,
    required this.pago,
    required this.utm,
    required this.plantaEnvio,
    required this.archivos,
    required this.tiempoReal,
    required this.distancia,
    required this.idCotizacion,
    required this.statusEliminado,
    required this.enviado,
  });

  /// 🔽 DESDE SQLITE / API
  factory Pedidodb.fromJson(Map<String, dynamic> json) {
    return Pedidodb(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      planta: json['planta']?.toString() ?? '',
      noObra: json['noobra']?.toString() ?? '',
      producto: json['producto']?.toString() ?? '',
      precioProducto:
          double.tryParse(json['precioProducto']?.toString() ?? '0') ?? 0,
      cantidad: double.tryParse(json['cantidad']?.toString() ?? '0') ?? 0,
      codBomba: json['codBomba']?.toString() ?? '',
      precioBomba: double.tryParse(json['precioBomba']?.toString() ?? '0') ?? 0,
      fechaHoraPedido: json['fechaHoraPedido']?.toString() ?? '',
      tRecorrido: json['tRecorrido']?.toString() ?? '',
      m3Viaje: double.tryParse(json['m3Viaje']?.toString() ?? '0') ?? 0,
      espaciado: json['espaciado']?.toString() ?? '',
      usuarioCreo: json['usuarioCreo']?.toString() ?? '',
      tDescarga: json['tDescarga']?.toString() ?? '',
      hraSalida: json['hraSalida']?.toString() ?? '',
      precioExtra: double.tryParse(json['precioExtra']?.toString() ?? '0') ?? 0,
      observaciones: json['observaciones']?.toString() ?? '',
      idPedido: json['idPedido']?.toString() ?? '',
      recibe: json['recibe']?.toString() ?? '',
      elemento: json['elemento']?.toString() ?? '',
      pago: json['pago']?.toString() ?? '',
      utm: json['UTM']?.toString() ?? '',
      plantaEnvio: json['plantaEnvio']?.toString() ?? '',
      archivos: int.tryParse(json['archivos']?.toString() ?? '0') ?? 0,
      tiempoReal: json['tiempoReal']?.toString() ?? '',
      distancia: json['distancia']?.toString() ?? '',
      idCotizacion: json['idCotizacion']?.toString() ?? '',
      statusEliminado:
          int.tryParse(json['statusEliminado']?.toString() ?? '0') ?? 0,
      enviado: int.tryParse(json['enviado']?.toString() ?? '0') ?? 0,
    );
  }

  /// 🔼 PARA GUARDAR EN SQLITE / API
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "planta": planta,
      "noobra": noObra,
      "producto": producto,
      "precioProducto": precioProducto,
      "cantidad": cantidad,
      "codBomba": codBomba,
      "precioBomba": precioBomba,
      "fechaHoraPedido": fechaHoraPedido,
      "tRecorrido": tRecorrido,
      "m3Viaje": m3Viaje,
      "espaciado": espaciado,
      "usuarioCreo": usuarioCreo,
      "tDescarga": tDescarga,
      "hraSalida": hraSalida,
      "precioExtra": precioExtra,
      "observaciones": observaciones,
      "idPedido": idPedido,
      "recibe": recibe,
      "elemento": elemento,
      "pago": pago,
      "UTM": utm,
      "plantaEnvio": plantaEnvio,
      "archivos": archivos,
      "tiempoReal": tiempoReal,
      "distancia": distancia,
      "idCotizacion": idCotizacion,
      "statusEliminado": statusEliminado,
      "enviado": enviado,
    };
  }
}
