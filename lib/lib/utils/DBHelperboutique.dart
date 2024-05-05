import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Clase DBHelper para manejar la base de datos de productos
class DBHelper {
  static Database? _database; // Base de datos SQLite
  static const String tableName = 'productos'; // Nombre de la tabla

  // Método para obtener la base de datos
  static Future<Database> get database async {
    if (_database != null) return _database!; // Si la base de datos ya está inicializada, la devuelve
    _database = await initDatabase(); // Si no está inicializada, la inicializa
    return _database!;
  }

  // Método para inicializar la base de datos
  static Future<Database> initDatabase() async {
    final path = await getDatabasesPath(); // Obtiene la ruta de la base de datos
    final databasePath = join(path, 'productos.db'); // Combina la ruta con el nombre de la base de datos

    // Abre la base de datos y crea la tabla si no existe
    return await openDatabase(databasePath, version: 1, onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            registro TEXT,
            valor REAL,
            medioDePago TEXT
          )
          ''');
    });
  }

  // Método para insertar un producto en la base de datos
  static Future<void> insertProducto(String registro, double valor, String medioDePago) async {
    final db = await database;
    await db.insert(
      tableName,
      {
        'registro': registro,
        'valor': valor,
        'medioDePago': medioDePago,
      },
    );
  }

  // Método para consultar todos los productos de la base de datos
  static Future<List<Map<String, dynamic>>> queryProductos() async {
    final db = await database;
    return await db.query(tableName);
  }

  // Método para actualizar un producto en la base de datos
  static Future<void> actualizarProducto(int id, String nuevoRegistro, double nuevoValor, String nuevoMedioDePago) async {
    final db = await database;
    await db.update(
      tableName,
      {
        'registro': nuevoRegistro,
        'valor': nuevoValor,
        'medioDePago': nuevoMedioDePago,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método para eliminar un producto de la base de datos
  static Future<void> eliminarProducto(int id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Método para obtener los gastos mensuales
  static Future<double> getGastosMensuales() async {
    final db = await database;

    // Obtiene el primer y último día del mes actual
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Realiza la consulta para obtener los gastos mensuales
    final result = await db.rawQuery('''
      SELECT SUM(valor) AS total
      FROM $tableName
      WHERE registro BETWEEN ? AND ?
    ''', [firstDayOfMonth.toString(), lastDayOfMonth.toString()]);

    // Obtiene el total de los gastos mensuales
    final total = result[0]['total'] as double? ?? 0.0;
    return total;
  }

  // Método para obtener el total de ventas del boutique
  static Future<double> obtenerTotalVentas() async {
    final db = await database;

    // Realiza la consulta para obtener el total de ventas del boutique
    final result = await db.rawQuery('''
      SELECT SUM(valor) AS total
      FROM $tableName
      WHERE medioDePago = 'boutique'
    ''');

    // Obtiene el total de las ventas del boutique
    final total = result[0]['total'] as double? ?? 0.0;
    return total;
  }
}
