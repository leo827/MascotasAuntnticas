import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:spamascotas/lib/screens/ExcelExporterClientes.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:cloud_firestore/cloud_firestore.dart';

class SQLHelper {
  static Future<void> closeDatabase() async {
    final db = await SQLHelper.db();
    await db.close();
  }

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
    CREATE TABLE items(
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  fecha TEXT,
  nombreCliente TEXT,  
  numeroCelular TEXT,
  nombreMascota TEXT,
  tipoMascota TEXT,
  raza TEXT,
  servicio TEXT,
  valorAPagar TEXT,
  metodoPago TEXT,
  imagen TEXT,
  atendidoPor TEXT, 
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)

  """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'kindacode.db',
      version: 2,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
      onUpgrade: (sql.Database database, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          // Añadir aquí cualquier cambio adicional en la estructura de la base de datos al actualizar
        }
      },
    );
  }

  static Future<int> createItem(Map<String, dynamic> data) async {
    final db = await SQLHelper.db();
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print('Nuevo registro guardado con ID: $id');
    return id;
  }

  static Future<void> exportToExcelFile() async {
    try {
      final registros = await getRegistros();
      await ExcelExporterClientes.exportToExcelAndSendEmail2(registros);
    } catch (error) {
      print('Error al exportar a Excel: $error');
    }
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
      int id, String nombreCliente, String? numeroCelular) async {
    final db = await SQLHelper.db();
    final data = {
      'nombreCliente': nombreCliente,
      'numeroCelular': numeroCelular,
      'createdAt': DateTime.now().toString()
    };
    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    print('Elemento actualizado. Resultado: $result');
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
      print('Registro eliminado con ID: $id');
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<int> guardarRegistro({
    required String fecha,
    required String nombreCliente,
    required String numeroCelular,
    required String nombreMascota,
    required String tipoMascota,
    required String raza,
    required String servicio,
    required String valorAPagar,
    required String metodoPago,
    String? rutaImagen,
    required String atendidoPor,
  }) async {
    final db = await SQLHelper.db();

    String? nuevaRutaImagen;
    if (rutaImagen != null) {
      // Obtener el directorio de documentos de la aplicación
      final Directory directorio = await getApplicationDocumentsDirectory();
      // Crear un directorio específico para las imágenes si no existe
      final String rutaAlmacenamiento = p.join(directorio.path, 'imagenes');
      await Directory(rutaAlmacenamiento).create(recursive: true);
      // Copiar la imagen al nuevo directorio con un nombre único
      final String rutaNuevaImagen = p.join(
          rutaAlmacenamiento, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(rutaImagen).copy(rutaNuevaImagen);
      nuevaRutaImagen = rutaNuevaImagen;
    }

    final data = {
      'fecha': fecha,
      'nombreCliente': nombreCliente,
      'numeroCelular': numeroCelular,
      'nombreMascota': nombreMascota,
      'tipoMascota': tipoMascota,
      'raza': raza,
      'servicio': servicio,
      'valorAPagar': valorAPagar,
      'metodoPago': metodoPago,
      'imagen': nuevaRutaImagen,
      'atendidoPor': atendidoPor,
    };
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print('Nuevo elemento creado con ID: $id');
    return id;
  }

  static Future<List<Map<String, dynamic>>> getRegistros() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: 'id DESC');
  }

  static Future<int> actualizarRegistro(
    int id, {
    required String fecha,
    required String nombreCliente,
    required String numeroCelular,
    required String nombreMascota,
    required String tipoMascota,
    required String raza,
    required String servicio,
    required String valorAPagar,
    required String metodoPago,
    required String atendidoPor,
  }) async {
    final db = await SQLHelper.db();
    final data = {
      'fecha': fecha,
      'nombreCliente': nombreCliente,
      'numeroCelular': numeroCelular,
      'nombreMascota': nombreMascota,
      'tipoMascota': tipoMascota,
      'raza': raza,
      'servicio': servicio,
      'valorAPagar': valorAPagar,
      'metodoPago': metodoPago,
      'atendidoPor': atendidoPor,
    };
    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    print('Registro actualizado. Resultado: $result');
    return result;
  }

  static Future<void> eliminarRegistro(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting a record: $err");
    }
  }

  static Future<List<Map<String, dynamic>>> getRegistrosUsuario(
      String username) async {
    final db = await SQLHelper.db();
    return db.query('items', where: 'nombreCliente = ?', whereArgs: [username]);
  }

  static Future<Object> getVentasMensuales() async {
    final db = await SQLHelper.db();
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final result = await db.rawQuery('''
      SELECT SUM(valorAPagar) as total 
      FROM items 
      WHERE fecha >= ? AND fecha < ?
    ''', [firstDayOfMonth.toIso8601String(), nextMonth.toIso8601String()]);

    return result[0]['total'] ?? 0.0;
  }
}

class FirebaseHelper {
  static Future<void> initialize() async {
    // Agregar cualquier inicialización necesaria para Firebase aquí
    // Por ejemplo, inicializar Firebase Auth, Firebase Storage, etc.
    // Aquí un ejemplo de inicialización de Firestore (no olvides importar 'package:cloud_firestore/cloud_firestore.dart')
    await FirebaseFirestore.instance.settings;
  }

  static Future<void> uploadDataToFirestore() async {
    // Obtener los datos de la base de datos SQLite
    final registros = await SQLHelper.getRegistros();

    // Subir los datos a Firestore
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('registros');

    registros.forEach((registro) async {
      // Crear un nuevo documento en la colección 'registros' con los datos del registro
      await collection.add({
        'fecha': registro['fecha'],
        'nombreCliente': registro['nombreCliente'],
        'numeroCelular': registro['numeroCelular'],
        'nombreMascota': registro['nombreMascota'],
        'tipoMascota': registro['tipoMascota'],
        'raza': registro['raza'],
        'servicio': registro['servicio'],
        'valorAPagar': registro['valorAPagar'],
        'metodoPago': registro['metodoPago'],
        'imagen': registro['imagen'],
        'atendidoPor': registro['atendidoPor'],
        // Agregar los demás campos aquí
      });
    });
  }
}
