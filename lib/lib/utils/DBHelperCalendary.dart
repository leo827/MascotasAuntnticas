import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

// Clase DBHelperCalendary para manejar la base de datos de citas en el calendario
class DBHelperCalendary {
  static Database? _database; // Base de datos SQLite
  static const String tableName = 'appointments'; // Nombre de la tabla

  // Método para obtener la base de datos
  static Future<Database> get database async {
    if (_database != null) return _database!; // Si la base de datos ya está inicializada, la devuelve
    _database = await initDatabase(); // Si no está inicializada, la inicializa
    return _database!;
  }

  // Método para inicializar la base de datos
  static Future<Database> initDatabase() async {
    final path = await getDatabasesPath(); // Obtiene la ruta de la base de datos
    final databasePath = join(path, 'appointments.db'); // Combina la ruta con el nombre de la base de datos

    // Abre la base de datos y crea la tabla si no existe
    return await openDatabase(databasePath, version: 1, onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            day TEXT,
            time TEXT
          )
          ''');
    });
  }

  // Método para insertar una cita en la base de datos
  static Future<void> insertAppointment(DBHelperAppointment appointment) async {
    final db = await database;
    await db.insert(
      tableName,
      appointment.toMap(),
    );
  }

  // Método para obtener las citas de un día específico
  static Future<List<DBHelperAppointment>> getAppointments({DateTime? day}) async {
    final db = await database;
    final List<Map<String, dynamic>> appointmentsMap;
    if (day != null) {
      appointmentsMap = await db.query(
        tableName,
        where: 'day = ?',
        whereArgs: [day.toString()],
      );
    } else {
      appointmentsMap = await db.query(tableName);
    }
    return appointmentsMap.map((e) => DBHelperAppointment.fromMap(e)).toList();
  }


  // Método para actualizar una cita en la base de datos
  static Future<void> updateAppointment(DBHelperAppointment appointment) async {
    final db = await database;
    await db.update(
      tableName,
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  // Método para eliminar una cita de la base de datos
  static Future<void> deleteAppointment(int id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// Clase DBHelperAppointment para representar una cita en el calendario
class DBHelperAppointment {
  final int? id; // Identificador de la cita
  final String title; // Título de la cita
  final String description; // Descripción de la cita
  final DateTime day; // Día de la cita
  final String time; // Hora de la cita

  // Constructor de la clase DBHelperAppointment
  DBHelperAppointment({
    this.id, // Se puede especificar el identificador o puede ser nulo
    required this.title, // El título es obligatorio
    required this.description, // La descripción es obligatoria
    required this.day, // El día es obligatorio
    required this.time, // La hora es obligatoria
  });

  // Método para convertir un objeto DBHelperAppointment a un mapa (para la base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Se incluye el identificador si está presente
      'title': title,
      'description': description,
      'day': day.toString(),
      'time': time,
    };
  }

  // Método para crear un objeto DBHelperAppointment a partir de un mapa (para la base de datos)
  factory DBHelperAppointment.fromMap(Map<String, dynamic> map) {
    return DBHelperAppointment(
      id: map['id'], // Se obtiene el identificador del mapa
      title: map['title'], // Se obtiene el título del mapa
      description: map['description'], // Se obtiene la descripción del mapa
      day: DateTime.parse(map['day']), // Se convierte la cadena de texto del día en u  n objeto DateTime
      time: map['time'], // Se obtiene la hora del mapa
    );
  }

  // Método para convertir un objeto DBHelperAppointment a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'day': day.toIso8601String(),
      'time': time,
    };
  }

  // Método para crear un objeto DBHelperAppointment a partir de JSON
  factory DBHelperAppointment.fromJson(Map<String, dynamic> json) {
    return DBHelperAppointment(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      day: DateTime.parse(json['day']),
      time: json['time'],
    );
  }
}
