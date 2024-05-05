import 'dart:io';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:spamascotas/lib/utils/DBHelperCalendary.dart';

class ExcelExporterAppointments {
  static Future<void> exportAppointmentsToExcel() async {
    try {
      final List<DBHelperAppointment> appointments = await DBHelperCalendary.getAppointments();
      final Excel excel = Excel.createExcel();
      final Sheet sheet = excel['Sheet1'];

      sheet.appendRow(['ID', 'Título', 'Descripción', 'Fecha', 'Hora']);

      for (final appointment in appointments) {
        final formattedDate = '${appointment.day.year}-${appointment.day.month}-${appointment.day.day}';
        sheet.appendRow([
          appointment.id,
          appointment.title,
          appointment.description,
          formattedDate,
          appointment.time,
        ]);
      }

      final Directory? downloadsDirectory = await getExternalStorageDirectory();
      final String excelFilePath = join(downloadsDirectory!.path, 'citas.xlsx');
      final List<int>? excelBytes = await excel.encode();
      final File outputFile = File(excelFilePath);
      await outputFile.writeAsBytes(excelBytes!);

      print('Citas exportadas a Excel: $excelFilePath');

      // Envío por correo electrónico
      final smtpServer = hotmail('mascotasautenticas@hotmail.com', '92702689Mascotas*');
      final message = Message()
        ..from = Address('mascotasautenticas@hotmail.com', 'Mascotas')
        ..recipients.add('gatomieles@gmail.com')
        ..subject = 'Citas Exportadas'
        ..text = 'Adjunto encontrarás el archivo de citas exportadas.'
        ..attachments.add(FileAttachment(outputFile));

      final sendReport = await send(message, smtpServer);
      print('Correo electrónico enviado: $sendReport');
    } catch (error) {
      print('Error al exportar citas a Excel y enviar correo: $error');
    }
  }
}
