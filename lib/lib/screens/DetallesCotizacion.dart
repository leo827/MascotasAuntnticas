import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:spamascotas/lib/utils/DatabaseHelperCotizacion.dart';

class DetallesCotizacion extends StatefulWidget {
  final int cotizacionId;

  DetallesCotizacion({required this.cotizacionId});

  @override
  _DetallesCotizacionState createState() => _DetallesCotizacionState();
}

class _DetallesCotizacionState extends State<DetallesCotizacion> {
  late Map<String, dynamic> _cotizacionData = {};

  @override
  void initState() {
    super.initState();
    _getCotizacionData();
  }

  Future<void> _getCotizacionData() async {
    try {
      final databaseHelper = DatabaseHelperCotizacion();
      final cotizacionData =
          await databaseHelper.getCotizacion(widget.cotizacionId);
      setState(() {
        _cotizacionData = cotizacionData;
      });
    } catch (e) {
      print('Error al obtener los datos de la cotización: $e');
    }
  }

  pdfLib.Widget _buildInfo(String label, String value) {
    return pdfLib.Row(
      mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
      children: [
        pdfLib.Text(
          '$label:',
          style: pdfLib.TextStyle(
            fontSize: 18,
            fontWeight: pdfLib.FontWeight.bold,
          ),
        ),
        pdfLib.Text(
          value,
          style: const pdfLib.TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cotizacionData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalles de la Cotización')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Cotización'),
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                'Nombre del Cliente', _cotizacionData['nombreCliente'] ?? ''),
            _buildInfoRow(
                'Número de Celular', _cotizacionData['celular'] ?? ''),
            _buildInfoRow(
                'Nombre de la Mascota', _cotizacionData['nombreMascota'] ?? ''),
            _buildInfoRow(
                'Tipo de Servicio', _cotizacionData['tipoServicio'] ?? ''),
            _buildInfoRow('Valor', '\$${_cotizacionData['valor'] ?? ''}'),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              '¡Gracias por su preferencia!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label + ':',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
