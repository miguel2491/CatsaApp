import 'dart:convert';
import 'package:catsa/model/producto.dart';
import 'package:http/http.dart' as http;
import 'package:catsa/model/planta.dart';
import 'package:catsa/model/cotizador.dart';
import 'package:catsa/model/pedido.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Fijas
Future<List<Planta>> fPlantas() async {
  final prefs = await SharedPreferences.getInstance();
  final userApp = prefs.getString('userApp');
  final response = await http.get(
    Uri.parse(
      'http://apicatsa.catsaconcretos.mx:2543/api/App/GetUserPlanta/${userApp}',
    ),
  );
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    print('✌️ ${data}');
    return data.map((json) => Planta.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar productos');
  }
}

Future<List<Producto>> fProducto(idCot) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userApp = prefs.getString('userApp');

    final response = await http.get(
      Uri.parse(
        'http://apicatsa.catsaconcretos.mx:2543/api/App/GetListProductos/$idCot',
      ),
    );
    print('🌐 Status: ${response.statusCode}');
    print('📦 Body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print('📊 Productos recibidos: ${data.length}');
      return data.map((json) => Producto.fromJson(json)).toList();
    } else {
      throw Exception('Error HTTP al cargar productos: ${response.statusCode}');
    }
  } catch (e, stacktrace) {
    print('❌ Error inesperado en fProducto: $e');
    print(stacktrace);
    return [];
  }
}

Future<List<String>> fElemento() async {
  return [
    '',
    'ALERON',
    'GUARNICION/BANQUETA',
    'BARDA/MURO',
    'BASES/FIRMES',
    'CABEZALES',
    'CADENA',
    'CANAL/DUCTO',
    'CICLOPEO',
    'CIMENTACION',
    'CISTERNA',
    'COLUMNA',
    'DIAFRAGMA',
    'ENCONFRADO',
    'ENTORADO',
    'LOSA/ENTRELOSA',
    'ESCALERA',
    'ESCAMAS',
    'ESTAMPADO',
    'ESTRIBOS',
    'MACHUELO',
    'PARAPETO',
    'PAVIMENTACION',
    'PISO',
    'PILAS/PILOTES',
    'PLACAS/PLANCHAS/TABLETAS',
    'PLANTILLA',
    'PORTANTE',
    'POZO',
    'POSTES',
    'PUENTE',
    'RAMPA',
    'RELLENO/REMATE/NIVELACION',
    'REVESTIMIENTO',
    'TOPES',
    'TRABES',
    'VERTEDOR',
    'VIALIDAD',
    'VIGETAS /VIGA PRECOLADA',
    'ZAMPEADO',
    'ZAPATAS',
    'OTRO..',
  ];
}

Future<List<Cotizador>> fCotizacion(id) async {
  //final prefs = await SharedPreferences.getInstance();
  final response = await http.get(
    Uri.parse(
      'http://apicatsa.catsaconcretos.mx:2543/api/App/GetCotizacion/${id}',
    ),
  );
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    //print('💀🎶 ${data}');
    return data.map((json) => Cotizador.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar productos');
  }
}

Future<List<Cotizador>> fetchProductos() async {
  final response = await http.get(
    Uri.parse(
      'http://apicatsa.catsaconcretos.mx:2543/api/Comercial/GetCotizaciones/2025-06-20,2025-06-24,malonso,PUE1',
    ),
  );
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Cotizador.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar productos');
  }
}

Future<List<Pedido>> fetchPedido({
  required String planta,
  required DateTime fechaInicio,
  required DateTime fechaFin,
}) async {
  final String inicioStr = fechaInicio.toIso8601String().split('T').first;
  final String finStr = fechaFin.toIso8601String().split('T').first;

  final url =
      'http://apicatsa.catsaconcretos.mx:2543/api/Operaciones/GetAllPedidos/$planta,$inicioStr,$finStr';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Pedido.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar pedidos');
  }
}

Future<List<Pedido>> fPedido(id) async {
  final response = await http.get(
    Uri.parse('http://apicatsa.catsaconcretos.mx:2543/api/App/GetPedido/${id}'),
  );
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    print('💀☠️👻 ${data}');
    return data.map((json) => Pedido.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar productos');
  }
}

//UTILS

double calcularSubtotalPed(
  double precioCon,
  double precioBomba,
  double m3,
  double precioExt,
) {
  final subtotal = ((precioCon + precioBomba) * m3) + precioExt;
  return subtotal;
}

double calcularTotalPed(double subtotal) {
  final total = (subtotal * 0.16) + subtotal;
  return total;
}

String calcularTiempo(int tsegundos) {
  int horas = tsegundos ~/ 3600;
  int minutos = (tsegundos - horas * 3600) ~/ 60;

  String tHoras = horas < 10 ? '0$horas' : '$horas';
  String tMinutos = minutos < 10 ? '0$minutos' : '$minutos';

  return '$tHoras:$tMinutos';
}
