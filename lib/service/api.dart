import 'dart:convert';
import 'package:catsa/db/database_helper.dart';
import 'package:catsa/model/clientes.dart';
import 'package:catsa/model/comision.dart';
import 'package:catsa/model/comision_vendedor.dart';
import 'package:catsa/model/costos.dart';
import 'package:catsa/model/costos_res.dart';
import 'package:catsa/model/obras.dart';
import 'package:catsa/model/pedidoDB.dart';
import 'package:catsa/model/pedido_online.dart';
import 'package:catsa/model/plantaInfo.dart';
import 'package:catsa/model/producto.dart';
import 'package:catsa/model/productoC.dart';
import 'package:catsa/model/vol_comision.dart';
import 'package:catsa/model/volumen.dart';
import 'package:catsa/model/bitacora.dart';
import 'package:catsa/service/offline_sync.dart' as ApiLocal;
import 'package:http/http.dart' as http;
import 'package:catsa/model/planta.dart';
import 'package:catsa/model/cotizador.dart';
import 'package:catsa/model/pedido.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

const String baseUrl = 'http://apicatsa.catsaconcretos.mx:2543/api/App';
const String baseUrlGn = 'http://apicatsa.catsaconcretos.mx:2543/api';

//DATATBASE
Future<void> syncPlantas() async {
  final plantasApi = await fPlantas();
  final db = await DatabaseHelper.instance.database;
  final batch = db.batch();

  for (final p in plantasApi) {
    if (p.id.isEmpty || p.planta.isEmpty) continue;

    batch.insert(
      'plantas',
      p.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  await batch.commit(noResult: true);
}

Future<List<Planta>> getPlantas() async {
  final db = await DatabaseHelper.instance.database;

  final res = await db.query('plantas', orderBy: 'planta ASC');
  return res.map((e) => Planta.fromMap(e)).toList();
}

//FIJAS
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
    print("💀 $data");
    return data.map((json) => Planta.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar productos');
  }
}

Future<List<Producto>> fProducto(idCot) async {
  try {
    //final prefs = await SharedPreferences.getInstance();
    //final userApp = prefs.getString('userApp');

    final response = await http.get(
      Uri.parse(
        'http://apicatsa.catsaconcretos.mx:2543/api/App/GetListProductos/$idCot',
      ),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Producto.fromJson(json)).toList();
    } else {
      throw Exception('Error HTTP al cargar productos: ${response.statusCode}');
    }
  } catch (e, stacktrace) {
    //print('❌ Error inesperado en fProducto: $e');
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

Future<Map<String, dynamic>> fCotizacion(int id) async {
  final response = await http.get(
    Uri.parse(
      'http://apicatsa.catsaconcretos.mx:2543/api/App/GetCotizacion/$id',
    ),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    return {
      'cotizacion': (data['Cotizacion'] as List)
          .map((e) => Cotizador.fromJson(e))
          .toList(),
      'producto': (data['Producto'] as List)
          .map((e) => Producto.fromJson(e))
          .toList(),
    };
  } else {
    throw Exception('Error al cargar cotización');
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
  final prefs = await SharedPreferences.getInstance();
  final userApp = prefs.getString('userApp');
  final url =
      'http://apicatsa.catsaconcretos.mx:2543/api/Operaciones/GetAllPedidos/$planta,$inicioStr,$finStr,$userApp,1';

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
    return data.map((json) => Pedido.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar productos');
  }
}

//CHECK
Future<bool> comprobarPedPend(Map<String, dynamic> pedido) async {
  final url = '$baseUrl/addPedido';
  final response = await http.post(
    Uri.parse('$url'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(pedido),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    await ApiLocal.OfflineSync().deletePedido(pedido['id']);
    return true;
  } else {
    //print('❌ Error API: ${response.statusCode}');
    return false;
  }
}

Future<bool> autorizarPedido(idPedido, tipo, estado) async {
  final dataP = {'id': idPedido, 'activo': estado, 'tipo': tipo};
  final url = '$baseUrlGn/Operaciones/setVB';
  final response = await http.post(
    Uri.parse('$url'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(dataP),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  } else {
    print('❌ Error API: ${response.statusCode}');
    return false;
  }
}

//COTIZADOR
Future<List<Clientes>> fClientes(planta) async {
  try {
    final response = await http.get(
      Uri.parse(
        'http://apicatsa.catsaconcretos.mx:2543/api/App/GetListCliente/$planta',
      ),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Clientes.fromJson(json)).toList();
    } else {
      throw Exception('Error HTTP al cargar productos: ${response.statusCode}');
    }
  } catch (e, stacktrace) {
    return [];
  }
}

Future<List<Obras>> fObras(planta) async {
  try {
    final response = await http.get(
      Uri.parse(
        'http://apicatsa.catsaconcretos.mx:2543/api/App/GetListObra/$planta',
      ),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Obras.fromJson(json)).toList();
    } else {
      throw Exception('Error HTTP al cargar productos: ${response.statusCode}');
    }
  } catch (e, stacktrace) {
    return [];
  }
}

Future<List<ProductoC>> fProductosPlanta(planta) async {
  try {
    final response = await http.get(
      Uri.parse(
        'http://apicatsa.catsaconcretos.mx:2543/api/App/GetListProductosPlanta/$planta',
      ),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => ProductoC.fromJson(json)).toList();
    } else {
      throw Exception('Error HTTP al cargar productos: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error inesperado en fPlanta: $e');
    return [];
  }
}

Future<ResultadoCostoPlanta?> fCostoPlanta(planta) async {
  try {
    final response = await http.get(
      Uri.parse(
        'http://apicatsa.catsaconcretos.mx:2543/api/App/GetCostoPlanta/$planta',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> allData = jsonDecode(response.body);
      final productos = (allData[0] as List)
          .map((json) => ProductoC.fromJson(json))
          .toList();

      final costos = (allData[1] as List)
          .map((json) => CostoC.fromJson(json))
          .toList();

      return ResultadoCostoPlanta(productos: productos, costos: costos);
    } else {
      throw Exception('Error HTTP al cargar productos: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error inesperado en fCostoPlanta: $e');
    return null;
  }
}

Future<List<List<Map<String, dynamic>>>> fInfoPlanta(planta, fecha, cpc) async {
  final prefs = await SharedPreferences.getInstance();
  final usuario = prefs.getString('userApp');
  try {
    final response = await http.get(
      Uri.parse(
        'http://apicatsa.catsaconcretos.mx:2543/api/App/GetInfoPlanta/C,$planta,$usuario,$fecha,$cpc',
      ),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final data = jsonResponse["data"] as List;
      return data
          .map(
            (resultSet) => (resultSet as List)
                .map((e) => e as Map<String, dynamic>)
                .toList(),
          )
          .toList();
    } else {
      throw Exception('Error HTTP al cargar productos: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error inesperado en fInfoPlanta: $e');
    return [];
  }
}

Future<RVolumenComision?> fVolumenComision(planta, obra) async {
  final prefs = await SharedPreferences.getInstance();
  final userApp = prefs.getString('userApp');
  print('🪴$planta 🎡$obra 〽️$userApp');
  try {
    final response = await http.get(
      Uri.parse(
        'http://apicatsa.catsaconcretos.mx:2543/api/app/GetVolumenComision/$planta,$obra,$userApp',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> allData = jsonDecode(response.body);

      final Comision_vendedor = (allData[0] as List)
          .map((json) => ComisionVendedor.fromJson(json))
          .toList();

      final comision = (allData[1] as List)
          .map((json) => Comision.fromJson(json))
          .toList();

      final volumen = (allData[2] as List)
          .map((json) => Volumen.fromJson(json))
          .toList();

      return RVolumenComision(
        comisionVendedor: Comision_vendedor,
        comision: comision,
        volumen: volumen,
      );
    } else {
      throw Exception('Error HTTP al cargar productos: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error inesperado en fVolumenComision: $e');
    return null;
  }
}

Future<List<Online>> fPOnline(planta, fecha) async {
  print('⚽☠️🎃 $planta 🩻 $fecha');
  final response = await http.get(
    Uri.parse(
      'http://apicatsa.catsaconcretos.mx:2543/api/Logistica/GetPLineaR/$planta,$fecha',
    ),
  );
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    print('⚽☠️🎃 $data');
    return data.map((json) => Online.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar Pedidos OnLine');
  }
}

Future<List<Cotizador>> fCotizaciones({
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
    return data.map((json) => Cotizador.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar pedidos');
  }
}

//--CREATE
Future<bool> sendCotizacion(Map<String, dynamic> cotizacion) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/Cotizaciones/GuardarOffline'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(cotizacion),
  );

  if (response.statusCode == 200) {
    return true;
  }

  return false;
}

// QR
Future<String> sendBitacora(send) async {
  print('⚽☠️🎃 $send');
  final response = await http.post(
    Uri.parse(
      'http://apicatsa.catsaconcretos.mx:2543/api/Administracion/setBitacoraEquipo',
    ),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(send),
  );

  print('💀 ${response.statusCode} ${response.body}');

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map && decoded.containsKey('message')) {
      return decoded['message'];
    }
    return 'Operación exitosa';
  } else {
    throw Exception('Error al cargar la bitácora (${response.statusCode})');
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

//===================================================================================================================================================================================================
