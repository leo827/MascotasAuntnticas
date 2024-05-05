import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:spamascotas/lib/utils/DBHelperboutique.dart';

class ExcelExporter {
  static Future<void> startExportingAndSending() async {
    try {
      await exportToExcelAndSendEmail();
    } catch (error) {
      print('Error al exportar a Excel y enviar correo: $error');
    }
  }

  static Future<void> exportToExcelAndSendEmail() async {
    try {
      var documentsDirectory = await getApplicationDocumentsDirectory();
      var outputFile = File(join(documentsDirectory.path, 'productos.xlsx'));
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];
      sheet.appendRow(['ID', 'Registro', 'Valor', 'Medio de Pago', 'Estado']); // Agregar columna para el estado

      var productos = await DBHelper.queryProductos();
      for (var producto in productos) {
        var registro = [
          producto['id'],
          producto['registro'],
          producto['valor'],
          producto['medioDePago'],
          'Exitoso' // Supongamos que todas las exportaciones son exitosas inicialmente
        ];
        sheet.appendRow(registro);
      }

      var excelBytes = excel.encode();
      if (excelBytes != null) {
        await outputFile.writeAsBytes(excelBytes);
        print('Datos exportados a Excel: ${outputFile.path}');

        final smtpServer = hotmail('mascotasautenticas@hotmail.com', '92702689Mascotas*');
        final message = Message()
          ..from = Address('mascotasautenticas@hotmail.com', 'Mascotas')
          ..recipients.add('gatomieles@gmail.com')
          ..subject = 'Productos Exportados'
          ..text = 'Adjunto encontrarás el archivo de productos exportados.'
          ..attachments.add(FileAttachment(outputFile));

        final sendReport = await send(message, smtpServer);
        print('Correo electrónico enviado: $sendReport');
      } else {
        print('Error al codificar el archivo de Excel');
      }
    } catch (error) {
      print('Error al exportar a Excel y enviar correo: $error');
    }
  }
}
