import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ExcelExporterClientes {
  static Future<void> exportToExcelAndSendEmail2(
      List<Map<String, dynamic>> data) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      sheet.appendRow([
        'ID',
        'Cliente',
        'Celular',
        'Nombre Mascota',
        'Tipo de Mascota',
        'Raza',
        'Servicio',
        'Valor a Pagar',
        'Método de Pago',
        'Fecha'
      ]);

      for (var item in data) {
        sheet.appendRow([
          item['id'],
          item['nombreCliente'],
          item['numeroCelular'],
          item['nombreMascota'],
          item['tipoMascota'],
          item['raza'],
          item['servicio'],
          item['valorAPagar'],
          item['metodoPago'],
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
