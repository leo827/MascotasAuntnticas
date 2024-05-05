import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:spamascotas/lib/utils/DatabaseHelperCotizacion.dart';

class ExcelExporterCotizaciones {
  static Future<void> exportCotizacionesToExcelAndSendEmail() async {
    try {
      // Obtener los datos de la base de datos
      final dbHelper = DatabaseHelperCotizacion();
      final List<Map<String, dynamic>> cotizaciones =
          await dbHelper.getAllCotizaciones();

      // Crear un nuevo libro de Excel
      final Excel excel = Excel.createExcel();
      final Sheet sheet = excel['Sheet1'];

      // Agregar encabezados
      sheet.appendRow([
        'Nombre del Cliente',
        'Número de Celular',
        'Nombre de la Mascota',
        'Tipo de Servicio',
        'Valor'
      ]);

      // Agregar filas de datos
      for (final cotizacion in cotizaciones) {
        sheet.appendRow([
          cotizacion['nombreCliente'],
          cotizacion['celular'],
          cotizacion['nombreMascota'],
          cotizacion['tipoServicio'],
          cotizacion['valor'],
        ]);
      }

      // Obtener el directorio de descargas
      final Directory? downloadsDirectory = await getExternalStorageDirectory();
      if (downloadsDirectory == null) {
        print('No se pudo acceder al directorio de descargas');
        return;
      }

      // Construir la ruta del archivo Excel
      final String excelFilePath =
          '${downloadsDirectory.path}/cotizaciones.xlsx';

      // Guardar el libro de Excel en el archivo
      final List<int>? excelBytes = await excel.encode();
      if (excelBytes == null) {
        print('Error al codificar el archivo Excel');
        return;
      }

      final File outputFile = File(excelFilePath);
      await outputFile.writeAsBytes(excelBytes);

      print('Cotizaciones exportadas a Excel: $excelFilePath');

      // Enviar el correo electrónico con el archivo adjunto
      final smtpServer =
          hotmail('mascotasautenticas@hotmail.com', '92702689Mascotas*');
      final message = Message()
        ..from = Address('mascotasautenticas@hotmail.com', 'Mascotas')
        ..recipients.add('gatomieles@gmail.com')
        ..subject = 'Cotizaciones Exportadas'
        ..text = 'Adjunto encontrarás el archivo de cotizaciones exportadas.'
        ..attachments.add(FileAttachment(outputFile));

      final sendReport = await send(message, smtpServer);
      print('Correo electrónico enviado: $sendReport');
    } catch (error) {
      print('Error al exportar cotizaciones a Excel y enviar correo: $error');
    }
  }
}
