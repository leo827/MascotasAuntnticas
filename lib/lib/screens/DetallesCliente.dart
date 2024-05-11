import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class DetallesCliente extends StatelessWidget {
  final Map<String, dynamic> cliente;

  const DetallesCliente({required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles del Cliente',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black, // Color del texto del título
          ),
        ),
        elevation: 0, // Sin sombra
        centerTitle: true,
        backgroundColor: Color(0xFF7133A0), // Color de fondo del AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Fecha', cliente['fecha']),
            const SizedBox(height: 8), // Espacio reducido
            _buildImageItem(cliente['imagenUrl']),
            const SizedBox(height: 16),
            _buildRow('Nombre Cliente', cliente['nombreCliente']),
            _buildRow('Número Celular', cliente['numeroCelular']),
            _buildRow('Nombre Mascota', cliente['nombreMascota']),
            _buildRow('Tipo Mascota', cliente['tipoMascota']),
            _buildRow('Raza', cliente['raza']),
            _buildRow('Servicio', cliente['servicio']),
            _buildRow('Valor a Pagar', cliente['valorAPagar']),
            _buildRow('Método de Pago', cliente['metodoPago']),
            _buildRow('Atendido por', cliente['atendidoPor']),
            const SizedBox(height: 16),
            _buildButtons(cliente['numeroCelular']),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Espacio reducido
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black, // Color del texto del título
            ),
          ),
          Text(
            value != null ? value.toString() : 'N/A',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem(String? imageUrl) {
    return imageUrl != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          )
        : const SizedBox();
  }

  Widget _buildButtons(String? phoneNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              _launchWhatsApp(phoneNumber);
            },
            child: Image.asset(
              'assets/whatsapp.png', // Ruta de la imagen de WhatsApp
              width: 40, // Ancho de la imagen
              height: 40, // Alto de la imagen
              fit: BoxFit
                  .contain, // Ajustar la imagen para que quepa dentro del contenedor
            ),
          ),
          IconButton(
            onPressed: () {
              if (cliente['numeroCelular'] != null) {
                _launchCall(cliente['numeroCelular'].toString());
              }
            },
            icon: Icon(Icons.phone), // Icono de teléfono
            iconSize: 40,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _launchWhatsApp(String? phoneNumber) async {
    if (phoneNumber != null) {
      // Eliminar cualquier signo "+" al principio del número de teléfono
      phoneNumber = phoneNumber.replaceAll('+', '');

      String url = 'https://wa.me/$phoneNumber';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'No se pudo abrir WhatsApp.';
      }
    }
  }

  void _launchCall(String phoneNumber) {
    FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }
}
