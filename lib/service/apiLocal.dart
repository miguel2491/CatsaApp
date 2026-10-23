import 'package:catsa/db/database_helper.dart';
import 'package:catsa/model/cotizacionLoc.dart';
import 'package:catsa/model/planta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

//DATATBASE
//****************    INSERT    ********************************************* */
Future<List<Planta>> getPlantas() async {
  final db = await DatabaseHelper.instance.database;

  final res = await db.query('plantas', orderBy: 'planta ASC');
  return res.map((e) => Planta.fromMap(e)).toList();
}

Future<List<CotizacionLoc>> fLCotizaciones({
  String? planta,
  DateTime? fechaInicio,
  DateTime? fechaFin,
}) async {
  final db = await DatabaseHelper.instance.database;

  final res = await db.query('cotizaciones');
  print(res);
  return res.map((e) => CotizacionLoc.fromMap(e)).toList();
}

Future<void> getCotizaciones() async {
  final db = await DatabaseHelper.instance.database;

  final res = await db.query('cotizaciones', orderBy: 'Planta ASC');
  print(res);
}

Future<void> getCotizacionesD() async {
  final db = await DatabaseHelper.instance.database;

  final res = await db.query('cotizaciones_detalle');
  print(res);
}

Future<void> getCotizacionesDMP() async {
  final db = await DatabaseHelper.instance.database;

  final res = await db.query('cotizaciones_detalle_MP');
  print(res);
}

Future<void> getCotizacionesEx() async {
  final db = await DatabaseHelper.instance.database;

  final res = await db.query('cotizaciones_extras');
  print(res);
}

//COTIZADOR
//-------------- CREATE
Future<void> guardarCotizacion(
  Map<String, dynamic> cotizacion,
  List<Map<String, dynamic>> detalle,
  List<Map<String, dynamic>> detalleMP,
  List<Map<String, dynamic>> extras,
) async {
  final db = await DatabaseHelper.instance.database;

  await db.transaction((txn) async {
    int id = await txn.insert('cotizaciones', cotizacion);

    for (var d in detalle) {
      d['idCotizacion'] = id;
      await txn.insert('cotizaciones_detalle', d);
    }

    for (var d in detalleMP) {
      d['idCotizacion'] = id;
      await txn.insert('cotizaciones_detalle_MP', d);
    }

    for (var e in extras) {
      e['idCotizacion'] = id;
      await txn.insert('cotizaciones_extras', e);
    }
  });
}

//-------------- DELETE
Future<void> eliminarCotizacion(int idCotizacion) async {
  final db = await DatabaseHelper.instance.database;

  await db.transaction((txn) async {
    await txn.delete(
      'cotizaciones_detalle',
      where: 'id_cotizacion = ?',
      whereArgs: [idCotizacion],
    );

    await txn.delete(
      'cotizaciones_detalle_MP',
      where: 'id_cotizacion = ?',
      whereArgs: [idCotizacion],
    );

    await txn.delete(
      'cotizaciones_extras',
      where: 'id_cotizacion = ?',
      whereArgs: [idCotizacion],
    );

    await txn.delete(
      'cotizaciones',
      where: 'id = ?',
      whereArgs: [idCotizacion],
    );
  });
}

//UTILS
Future<void> borrarTodo() async {
  final db = await DatabaseHelper.instance.database;

  await db.transaction((txn) async {
    await txn.delete('cotizaciones_detalle');
    await txn.delete('cotizaciones_detalle_MP');
    await txn.delete('cotizaciones_extras');
    await txn.delete('cotizaciones');
    await txn.delete('pedidos');
  });
}

//LOCALES
Future<List<Map<String, dynamic>>> getCotizacionesPen() async {
  final db = await DatabaseHelper.instance.database;

  final cotizaciones = await db.query(
    'cotizaciones',
    where: 'enviado = ?',
    whereArgs: [0],
  );

  List<Map<String, dynamic>> resultado = [];

  for (var cot in cotizaciones) {
    final id = cot['id'];

    final detalle = await db.query(
      'cotizaciones_detalle',
      where: 'idCotizacion = ?',
      whereArgs: [id],
    );

    final detalleMP = await db.query(
      'cotizaciones_detalle_MP',
      where: 'idCotizacion = ?',
      whereArgs: [id],
    );

    final extras = await db.query(
      'cotizaciones_extras',
      where: 'idCotizacion = ?',
      whereArgs: [id],
    );

    resultado.add({
      'cabecera': cot,
      'detalle': detalle,
      'detalleMP': detalleMP,
      'extras': extras,
    });
  }
  return resultado;
}

//===================================================================================================================================================================================================
