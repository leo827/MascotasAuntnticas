import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperCotizacion {
  static Database? _database;
  static final _tableName = 'cotizaciones';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'cotizaciones.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombreCliente TEXT,
            celular TEXT,
            nombreMascota TEXT,
            tipoServicio TEXT,
            valor INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(_tableName, row);
  }

  Future<Map<String, dynamic>> getCotizacion(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> cotizaciones = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (cotizaciones.isNotEmpty) {
      return cotizaciones.first;
    } else {
      throw Exception('No se encontró la cotización con el ID proporcionado: $id');
    }
  }

  Future<List<Map<String, dynamic>>> getAllCotizaciones() async {
    Database db = await database;
    return await db.query(_tableName);
  }

  Future<int> deleteCotizacion(int id) async {
    Database db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
