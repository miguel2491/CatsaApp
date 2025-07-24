import 'package:catsa/model/costos.dart';
import 'package:catsa/model/productoC.dart';

class ResultadoCostoPlanta {
  final List<ProductoC> productos;
  final List<CostoC> costos;

  ResultadoCostoPlanta({required this.productos, required this.costos});
  @override
  String toString() {
    return 'Costo(CostoC: $costos)';
  }
}
