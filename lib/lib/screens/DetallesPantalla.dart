import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class DetallesPantalla extends StatelessWidget {
  final Map<String, dynamic> registro;
  final String? imagenPath;

  const DetallesPantalla({Key? key, required this.registro, this.imagenPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Registro'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(173, 216, 230, 1.0), // Light Turquoise
              Color.fromRGBO(144, 238, 144, 1.0), // Light Green
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imagenPath != null && imagenPath!.isNotEmpty)
                _buildImageWidget(imagenPath!),
              const SizedBox(height: 16),
              _buildDetallesItem('Fecha', registro['fecha'] ?? ''),
              _buildDetallesItem(
                  'Nombre Cliente', registro['nombreCliente'] ?? ''),
              _buildDetallesItem(
                  'Número de Celular', registro['numeroCelular'] ?? ''),
              _buildDetallesItem(
                  'Nombre Mascota', registro['nombreMascota'] ?? ''),
              _buildDetallesItem(
                  'Tipo de Mascota', registro['tipoMascota'] ?? ''),
              _buildDetallesItem('Raza', registro['raza'] ?? ''),
              _buildDetallesItem('Servicio', registro['servicio'] ?? ''),
              _buildDetallesItem(
                  'Valor a Pagar', registro['valorAPagar'] ?? ''),
              _buildDetallesItem(
                  'Metodo de Pago', registro['metodoPago'] ?? ''),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        _enviarWhatsApp(registro['numeroCelular'] ?? ''),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green, // Color del texto
                      padding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24), // Ajustar el padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Bordes redondeados
                      ),
                      elevation: 3, // Agregar sombra
                    ),
                    child: const Text(
                      'Enviar WhatsApp',
                      style:
                          TextStyle(fontSize: 16), // Ajustar tamaño del texto
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () =>
                        _realizarLlamada(registro['numeroCelular'] ?? ''),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue, // Color del texto
                      padding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24), // Ajustar el padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Bordes redondeados
                      ),
                      elevation: 3, // Agregar sombra
                    ),
                    child: const Text(
                      'Llamar',
                      style:
                          TextStyle(fontSize: 16), // Ajustar tamaño del texto
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildImageWidget(String imagePath) {
  final file = File(imagePath);
  if (file.existsSync()) {
    return Image.file(
      file,
      width: double.infinity,
      height: 200,
      fit: BoxFit.contain,
    );
  } else {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}

Widget _buildDetallesItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    ),
  );
}

Future<void> _enviarWhatsApp(String phoneNumber) async {
  final url = 'https://wa.me/$phoneNumber';
  await canLaunch(url) ? await launch(url) : throw 'No se puede abrir WhatsApp';
}

Future<void> _realizarLlamada(String phoneNumber) async {
  await FlutterPhoneDirectCaller.callNumber(phoneNumber);
}
