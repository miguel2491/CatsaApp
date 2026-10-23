import 'dart:io';
import 'package:catsa/db/database_helper.dart';
import 'package:catsa/model/planta.dart';
import 'package:catsa/service/apiLocal.dart' as ApiLocal;
import 'package:catsa/service/api.dart' as Api;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class OfflineSync {
  static final OfflineSync _instance = OfflineSync._internal();
  factory OfflineSync() => _instance;
  OfflineSync._internal();

  // ---------------------------------------------------------
  // 🔹 Inicializa todo (BD + Listener)
  // ---------------------------------------------------------
  Future<void> init() async {
    await DatabaseHelper.instance.database;
    _listenConnectionChanges();
  }

  // ---------------------------------------------------------------------------
  // 🔹 Guardar Planta localmente
  // ---------------------------------------------------------------------------
  Future<void> savePlanta(Planta planta) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      "plantas",
      planta.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("📝 Plantas guardadas localmente");
  }

  Future<void> insertPlantas(List<Planta> plantas) async {
    final _db = await DatabaseHelper.instance.database;
    final batch = _db.batch();

    for (final p in plantas) {
      batch.insert(
        'plantas',
        p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getPlantas() async {
    final db = await DatabaseHelper.instance.database;

    return await db.query("plantas", orderBy: "clave DESC");
  }

  Future<Map<String, dynamic>?> getPlantaById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.query('plantas', where: 'id = ?', whereArgs: [id]);

    return res.isNotEmpty ? res.first : null;
  }

  Future<int> updatePlanta(int id, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update('plantas', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePlantas(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('plantas', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------
  // 🔹 Guardar Pedidos localmente
  // ---------------------------------------------------------
  Future<int> insertPedido(Map<String, dynamic> data) async {
    final _db = await DatabaseHelper.instance.database;
    return await _db.insert(
      "pedidos",
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deletePedido(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete("pedidos", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getPedidosL() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query("pedidos", orderBy: "fechaHoraPedido DESC");
  }

  // ---------------------------------------------------------
  // 🔹 Guardar cotización localmente
  // ---------------------------------------------------------
  Future<void> guardarCotizacion(Map data) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert("cotizaciones", {
      "idCotizacion": data["cliente"],
      "Planta": data["total"],
      "NoCliente": DateTime.now().toIso8601String(),
      "NoObra": data["total"],
      "Cliente": data["total"],
      "Municipio": data["total"],
      "Contacto": data["total"],
      "Obra": data["total"],
      "Direccion": data["total"],
      "IdVendedor": data["total"],
      "UsuarioCreo": data["total"],
      "FlagIVA": data["total"],
      "FlagTotal": data["total"],
      "FlagCondiciones": data["total"],
      "Estatus": data["total"],
      "IdMotivo": data["total"],
      "Observaciones": data["total"],
      "GradoLlenado": data["total"],
      "TiempoCiclo": data["total"],
      "CotAnterior": data["total"],
      "Fuente": data["total"],
      "Email": data["total"],
      "Telefono": data["total"],
      "Coordenadas": data["total"],
      "FlagObservaciones": data["total"],
      "Segmento": data["total"],
      "Canal": data["total"],
      "PreCot": data["total"],
      "Elemento": data["total"],
      "AutorizarPedido": data["total"],
      "enviado": 0,
    });

    print("📝 Cotización guardada localmente");
    //await sincronizar(); // intentar enviar por si hay internet
  }

  Future<void> guardarCotizacionD(Map data) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert("cotizaciones_detalle", {
      "id_cotizacion": data["cliente"],
      "Cantidad": data["total"],
      "Producto": DateTime.now().toIso8601String(),
      "MOP": data.toString(),
      "M3Bomba": data["total"],
      "Precio": data["total"],
      "MB": data["total"],
      "FlagVoBo": data["total"],
      "UsuarioAutoriza": data["total"],
      "Autoriza": data["total"],
      "Comentario": data["total"],
      "FlagImprimir": data["total"],
      "CostoMP": data["total"],
      "enviado": 0,
    });

    print("📝 Cotización guardada localmente");
    await sincronizar(); // intentar enviar por si hay internet
  }

  Future<void> guardarCotizacionMP(Map data) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert("cotizaciones_detalle_MP", {
      "id_cotizacion": data["cliente"],
      "Descripcion": data["total"],
      "CPC": DateTime.now().toIso8601String(),
      "H2O": data.toString(),
      "GRAVAS": data["total"],
      "ARENAS": data["total"],
      "ADITIVOS": data["total"],
      "COSTO": data["total"],
      "MOP0": data["total"],
      "enviado": 0,
    });

    print("📝 Cotización guardada localmente");
    await sincronizar(); // intentar enviar por si hay internet
  }

  Future<void> guardarCotizacionEx(Map data) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert("cotizaciones_extras", {
      "id_cotizacion": data["cliente"],
      "IdExtra": data["total"],
      "Producto": data["total"],
      "CantidadUser": data["total"],
      "CantidadCot": data["total"],
      "Precio": data["total"],
      "CantMin": data["total"],
      "Nivel": data["total"],
      "Tipo": data["total"],
      "PrecioUser": data["total"],
      "enviado": 0,
    });

    print("📝 Cotización ID Extra");
    //await sincronizar(); // intentar enviar por si hay internet
  }

  //----------------------------------------------------------
  Future<int> deleteCotizacion(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete("cotizaciones", where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteCotizacionDetalle(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      "cotizaciones_detalle",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteCotizacionMP(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      "cotizaciones_detalle_MP",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteCotizacionEx(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      "cotizaciones_extras",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------
  // 🔹 Verifica si hay WiFi/datos
  // ---------------------------------------------------------
  Future<bool> _tengoConexion() async {
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi;
  }

  // ---------------------------------------------------------
  // 🔹 Verifica internet real (ping)
  // ---------------------------------------------------------
  Future<bool> _tengoInternetReal() async {
    try {
      final resp = await InternetAddress.lookup("google.com");
      return resp.isNotEmpty && resp[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(Duration(seconds: 3));

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------
  // 🔹 Sincronizar cotizaciones pendientes
  // ---------------------------------------------------------
  Future<void> sincronizar() async {
    final connectivity = await Connectivity().checkConnectivity();
    final prefs = await SharedPreferences.getInstance();
    if (connectivity == ConnectivityResult.none) {
      print("⛔ Sin conexión detectada por connectivity_plus");
      return;
    }

    final internetOk = await hasRealInternet();

    if (!internetOk) {
      print("⛔ No hay internet real, pero sí red (WiFi/datos sin salida)");
      return;
    }

    print("🟢 Internet ok → sincronizando…");
    await prefs.setString('coneccion', 'SI');
    // ... tu proceso de sync...
    final db = await DatabaseHelper.instance.database;
    final pendientes = await db.query(
      "pedidos",
      where: "enviado = ?",
      whereArgs: [0],
    );
    print("🧪 PENDIENTES EN BD: $pendientes");
    sincronizarCotizaciones();
  }

  Future<void> sincronizarCotizaciones() async {
    final pendientes = await ApiLocal.getCotizacionesPen();
    for (final cotizacion in pendientes) {
      final ok = await Api.sendCotizacion(cotizacion);

      if (ok) {
        final idLocal = cotizacion['cabecera']['id'];

        await ApiLocal.eliminarCotizacion(idLocal);

        // o marcar como enviada
        // await ApiLocal.marcarComoEnviada(idLocal);
      }
    }
  }

  // ---------------------------------------------------------
  // 🔹 Llamada a tu API (aquí personalizas tu endpoint)
  // ---------------------------------------------------------
  Future<bool> _enviarALaAPI(Map cotizacion) async {
    try {
      final url = Uri.parse("https://TU-API.com/api/cotizaciones");
      final resp = await http.post(
        url,
        body: {
          "cliente": cotizacion["cliente"].toString(),
          "total": cotizacion["total"].toString(),
          "fecha": cotizacion["fecha"],
          "data": cotizacion["data"],
        },
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        print(
          "📤 Cotización enviada correctamente (ID local: ${cotizacion["id"]})",
        );
        return true;
      }

      print("⚠ Error al enviar: ${resp.statusCode}");
      return false;
    } catch (e) {
      print("❌ Error enviando cotización: $e");
      return false;
    }
  }

  // ---------------------------------------------------------
  // 🔹 Listener: cuando vuelva el internet → sincroniza
  // ---------------------------------------------------------
  bool _chequeandoInternet = false;

  void _listenConnectionChanges() {
    Connectivity().onConnectivityChanged.listen((status) async {
      if (status == ConnectivityResult.none) {
        print("🔴 Sin conexión");

        if (!_chequeandoInternet) {
          _chequeandoInternet = true;
          _iniciarMonitoreoInternet();
        }
      } else {
        print("⚠ Hay red, pero verificaré si realmente hay internet…");
        // Evita sincronizar antes de que el internet esté disponible
        if (!_chequeandoInternet) {
          _chequeandoInternet = true;
          _iniciarMonitoreoInternet();
        }
      }
    });
  }

  void _iniciarMonitoreoInternet() async {
    final prefs = await SharedPreferences.getInstance();
    while (_chequeandoInternet) {
      await Future.delayed(Duration(seconds: 2));

      if (await _tengoInternetReal()) {
        print("🟢 Conexión detectada → sincronizando…");
        _chequeandoInternet = false;
        await sincronizar();
        break;
      } else {
        print("⏳ Buscando internet...");
        await prefs.setString('coneccion', 'NO');
      }
    }
  }
}
