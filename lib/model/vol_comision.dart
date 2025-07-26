import 'package:catsa/model/comision.dart';
import 'package:catsa/model/comision_vendedor.dart';
import 'package:catsa/model/volumen.dart';

class RVolumenComision {
  final List<ComisionVendedor> comisionVendedor;
  final List<Comision> comision;
  final List<Volumen> volumen;

  RVolumenComision({
    required this.comisionVendedor,
    required this.comision,
    required this.volumen,
  });
  @override
  String toString() {
    return 'RVolCom(ComisionVendedor: $comisionVendedor Comision: $comision Volumén: $volumen)';
  }
}
