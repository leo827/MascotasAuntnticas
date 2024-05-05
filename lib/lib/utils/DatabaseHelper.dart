import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'User.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT)",
        );
      },
    );
  }

  Future<void> insertUser(User user) async {
    final Database db = await database;
    Map<String, dynamic> userData = user.toMap();
    await db.insert(
      'users',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserByUsername(String username) async {
    final Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) {
      return null; // Si no se encuentra el usuario, devuelve null
    }
    return User.fromMap(maps.first); // Devuelve el primer usuario encontrado
  }

  Future<void> logUserAccess(String username) async {
    final Database db = await database;
    await db.insert(
      'access_logs',
      {'username': username, 'access_time': DateTime.now().toString()},
    );
  }

  Future<List<Map<String, dynamic>>> getUserAccessLogs(String username) async {
    final Database db = await database;
    return await db.query(
      'access_logs',
      where: 'username = ?',
      whereArgs: [username],
    );
  }
}
