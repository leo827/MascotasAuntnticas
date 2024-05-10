import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ExcelExporterClientes {
  static Future<void> exportToExcelAndSendEmail2(
      List<Map<String, dynamic>> data) async {
    try {
      // Obtener los datos de Firebase
      final querySnapshot =
          await FirebaseFirestore.instance.collection('clientes').get();

      // Convertir los documentos a una lista de Map<String, dynamic>
      final data = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Llamar al método existente para exportar a Excel y enviar por correo electrónico
      await exportToExcelAndSendEmail(data);
    } catch (error) {
      print('Error al exportar a Excel y enviar correo: $error');
    }
  }

  static Future<void> exportToExcelAndSendEmail(
      List<Map<String, dynamic>> data) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      sheet.appendRow([
        'Nombre Cliente',
        'Número Celular',
        'Nombre Mascota',
        'Tipo Mascota',
        'Raza',
        'Servicio',
        'Valor a Pagar',
        'Método de Pago',
        'Atendido por',
        'Fecha'
      ]);

      for (var item in data) {
        sheet.appendRow([
          item['nombreCliente'],
          item['numeroCelular'],
          item['nombreMascota'],
          item['tipoMascota'],
          item['raza'],
          item['servicio'],
          item['valorAPagar'],
          item['metodoPago'],
          item['atendidoPor'],
          item['fecha']
        ]);
      }

      var outputBytes = excel.encode();
      if (outputBytes != null) {
        var documentsDirectory = await getApplicationDocumentsDirectory();
        var outputFile = File(join(documentsDirectory.path, 'clientes.xlsx'));
        await outputFile.writeAsBytes(outputBytes);
        print('Datos exportados a Excel: ${outputFile.path}');

        final smtpServer =
            hotmail('mascotasautenticas@hotmail.com', '92702689Mascotas*');
        final message = Message()
          ..from = Address('mascotasautenticas@hotmail.com', 'Mascotas')
          ..recipients.add('gatomieles@gmail.com')
          ..recipients.add('mascotasautenticas@gmail.com')
          ..subject = 'Clientes Exportados'
          ..text = 'Adjunto encontrarás el archivo de clientes exportados.'
          ..attachments.add(FileAttachment(outputFile));

        final sendReport = await send(message, smtpServer);
        print('Correo electrónico enviado: $sendReport');
      } else {
        print('Error al exportar a Excel: bytes nulos.');
      }
    } catch (error) {
      print('Error al exportar a Excel y enviar correo: $error');
    }
  }
}
