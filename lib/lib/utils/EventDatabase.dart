import 'package:spamascotas/lib/utils/Event.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class EventDatabase {
  static final EventDatabase instance = EventDatabase._init();
  static Database? _database;

  EventDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('events.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);
    return await openDatabase(path,
        version: 2, onCreate: _createDB); // Incrementa la versión a 2
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Events(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      date TEXT,
      nombre TEXT,
      celular TEXT
    )
  ''');
  }

  Future<Event> createEvent(Event event) async {
    final db = await instance.database;
    final id = await db.insert('Events', event.toMap());
    return event.copy(id: id);
  }

  Future<List<Event>> getAllEvents() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('Events');
    return List.generate(maps.length, (i) {
      return Event(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        description: maps[i]['description'] != null
            ? maps[i]['description'] as String
            : '',
        date: DateTime.parse(maps[i]['date'] as String),
        nombre: maps[i]['nombre'] != null
            ? maps[i]['nombre'] as String
            : '', // Manejo de caso para nombre null
        celular: maps[i]['celular'] != null
            ? maps[i]['celular'] as String
            : '', // Manejo de caso para celular null
      );
    });
  }

  Future<void> deleteEvent(int id) async {
    final db = await instance.database;
    await db.delete(
      'Events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateEvent(Event event) async {
    final db = await instance.database;
    await db.update(
      'Events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<List<Event>> getEventsForDay(DateTime day) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Events',
      where: 'date = ?',
      whereArgs: [day.toIso8601String()],
    );
    return List.generate(maps.length, (i) {
      return Event(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        date: DateTime.parse(maps[i]['date'] as String),
        description: '',
        nombre: maps[i]['nombre'] as String, // Nuevo campo nombre
        celular: maps[i]['celular'] as String, // Nuevo campo celular
      );
    });
  }
}
