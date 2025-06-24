import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:catsa/model/cotizador.dart';
import 'package:catsa/model/pedido.dart';

Future<List<Cotizador>> fetchProductos() async {
  final response = await http.get(
    Uri.parse(
      'http://apicatsa.catsaconcretos.mx:2543/api/Comercial/GetCotizaciones/2025-06-20,2025-06-24,malonso,PUE1',
    ),
  );
  print(response.body);
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
  print(response.body);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Pedido.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar pedidos');
  }
}
