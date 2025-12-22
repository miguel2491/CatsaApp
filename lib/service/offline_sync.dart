import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class OfflineSync {
  static final OfflineSync _instance = OfflineSync._internal();
  factory OfflineSync() => _instance;
  OfflineSync._internal();

  Database? _db;

  // ---------------------------------------------------------
  // 🔹 Inicializa todo (BD + Listener)
  // ---------------------------------------------------------
  Future<void> init() async {
    await _initDB();
    _listenConnectionChanges();
  }

  // ---------------------------------------------------------
  // 🔹 Crear base de datos SQLite
  // ---------------------------------------------------------
  Future<void> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "cotizaciones.db");

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // Se ejecuta solo la primera vez
        await db.execute("""
      CREATE TABLE cotizaciones(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente TEXT,
        total REAL,
        fecha TEXT,
        data TEXT,
        enviado INTEGER DEFAULT 0
      )
    """);

        await db.execute("""
      CREATE TABLE pedidos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        precio REAL,
        cantidad INTEGER
      )
    """);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("""
        CREATE TABLE pedidos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT,
          precio REAL,
          cantidad INTEGER
        )
      """);
        }
      },
    );

    print("📦 Base local lista en: $path");
  }

  // ---------------------------------------------------------
  // 🔹 Guardar cotización localmente
  // ---------------------------------------------------------
  Future<void> guardarCotizacion(Map data) async {
    await _db?.insert("cotizaciones", {
      "cliente": data["cliente"],
      "total": data["total"],
      "fecha": DateTime.now().toIso8601String(),
      "data": data.toString(),
      "enviado": 0,
    });

    print("📝 Cotización guardada localmente");
    await sincronizar(); // intentar enviar por si hay internet
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
    // ... tu proceso de sync...
    final pendientes = await _db?.query(
      "cotizaciones",
      where: "enviado = ?",
      whereArgs: [0],
    );
    print("🧪 PENDIENTES EN BD: $pendientes");
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
    while (_chequeandoInternet) {
      await Future.delayed(Duration(seconds: 2));

      if (await _tengoInternetReal()) {
        print("🟢 Conexión detectada → sincronizando…");
        _chequeandoInternet = false;
        await sincronizar();
        break;
      } else {
        print("⏳ Buscando internet...");
      }
    }
  }
}
