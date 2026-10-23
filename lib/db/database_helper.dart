import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // ---------------------------------------------------------
  // 🔹 Singleton
  // ---------------------------------------------------------
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;

  // ---------------------------------------------------------
  // 🔹 Getter público de la BD
  // ---------------------------------------------------------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // ---------------------------------------------------------
  // 🔹 Inicialización
  // ---------------------------------------------------------
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cotizaciones.db');

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    print('📦 SQLite lista en: $path');
    return db;
  }

  // ---------------------------------------------------------
  // 🔹 Creación de tablas
  // ---------------------------------------------------------
  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
    CREATE TABLE cotizaciones(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      Planta TEXT,
      NoCliente TEXT,
      NoObra TEXT,
      Cliente TEXT,
      Municipio TEXT,
      Contacto TEXT,
      Obra TEXT,
      Direccion TEXT,
      IdVendedor TEXT,
      FlagIVA NUMERIC,
      FlagTotal NUMERIC,
      FlagCondiciones NUMERIC,
      IdMotivo int,
      Fuente INTEGER,
      Coordenadas TEXT,
      FlagObservaciones NUMERIC,
      Segmento INTEGER,
      Canal INTEGER,
      PreCot INTEGER, 
      Elemento TEXT,
      enviado INTEGER DEFAULT 0
    )
    """);

    await db.execute("""
      CREATE TABLE cotizaciones_detalle(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idCotizacion INTEGER,
        Cantidad REAL,
        Producto TEXT,
        MOP REAL,
        M3Bomba REAL,
        Bomba REAL,
        Precio REAL,
        MB REAL,
        FlagVoBo NUMERIC,
        Comentario TEXT,
        FlagImprimir NUMERIC,
        CostoMP REAL,
        enviado INTEGER DEFAULT 0
      )
    """);

    await db.execute("""
      CREATE TABLE cotizaciones_detalle_MP(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idCotizacion INTEGER,
        Producto TEXT,
        Descripcion TEXT,
        CPC REAL,
        H2O REAL,
        GRAVAS REAL,
        ARENAS REAL,
        ADITIVOS REAL,
        COSTO REAL,
        MOP0 REAL,
        enviado INTEGER DEFAULT 0
      )
    """);

    await db.execute("""
      CREATE TABLE cotizaciones_extras(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idCotizacion INTEGER,
        IdExtra INTEGER,
        Producto TEXT,
        CantidadUser REAL,
        CantidadCot REAL,
        Precio REAL,
        PrecioUser REAL,
        enviado INTEGER DEFAULT 0
      )
    """);

    await db.execute("""
    CREATE TABLE pedidos(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      idPedido TEXT,
      planta TEXT,
      noobra TEXT,
      producto TEXT,
      precioProducto TEXT,
      cantidad TEXT,
      codBomba TEXT,
      precioBomba TEXT,
      fechaHoraPedido TEXT,
      tRecorrido TEXT,
      m3Viaje TEXT,
      espaciado TEXT,
      usuarioCreo TEXT,
      tDescarga TEXT,
      hrSalida TEXT,
      precioExtra TEXT,
      observaciones TEXT,
      recibe TEXT,
      elemento TEXT,
      pago TEXT,
      UTM TEXT,
      plantaEnvio TEXT,
      archivos TEXT,
      tiempoReal TEXT,
      distancia TEXT,
      idCotizacion TEXT,
      statusEliminado INTEGER,
      enviado INTEGER DEFAULT 0
    )
    """);

    await db.execute("""
    CREATE TABLE plantas(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      planta TEXT,
      clave TEXT UNIQUE
    )
    """);
  }

  // ---------------------------------------------------------
  // 🔹 Migraciones
  // ---------------------------------------------------------
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("""
      CREATE TABLE IF NOT EXISTS plantas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        planta TEXT,
        clave TEXT UNIQUE
      )
      """);
    }
  }

  // ---------------------------------------------------------
  // 🔹 Cerrar BD (opcional)
  // ---------------------------------------------------------
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
