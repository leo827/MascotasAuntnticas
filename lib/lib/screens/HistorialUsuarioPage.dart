import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClienteData {
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> clientesFiltrados = [];
  bool datosCargados = false;
  static final ClienteData _instance = ClienteData._internal();

  factory ClienteData() {
    return _instance;
  }

  ClienteData._internal();
}

class HistorialUsuarioPage extends StatefulWidget {
  @override
  _HistorialUsuarioPageState createState() => _HistorialUsuarioPageState();
}

class _HistorialUsuarioPageState extends State<HistorialUsuarioPage> {
  late ClienteData clienteData;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    clienteData = ClienteData();
    _cargarDatosGuardados();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Historial de Clientes'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.file_upload),
              onPressed: _importarExcel,
            ),
          ],
        ),
        body: clienteData.datosCargados
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              labelText: 'Buscar Cliente',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: _filtrarClientes,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            _filtrarClientes('');
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: clienteData.clientesFiltrados.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text(
                              clienteData.clientesFiltrados[index]['Cliente'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(clienteData.clientesFiltrados[index]
                                ['Celular']),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetallesClientePage(
                                    cliente:
                                        clienteData.clientesFiltrados[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const Center(
                child: Text(
                  'No hay datos disponibles',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
      ),
    );
  }

  Future<void> _importarExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      PlatformFile? file = result.files.first;
      String filePath = file.path!;
      await _cargarDatosExcel(filePath);
    }
  }

  Future<void> _cargarDatosExcel(String filePath) async {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    clienteData.clientes.clear(); // Limpiar lista antes de agregar nuevos datos

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        clienteData.clientes.add({
          'ID': row[0]?.value?.toString() ?? '',
          'Cliente': row[1]?.value?.toString() ?? '',
          'Celular': row[2]?.value?.toString() ?? '',
          'Nombre Mascota': row[3]?.value?.toString() ?? '',
          'Tipo de Mascota': row[4]?.value?.toString() ?? '',
          'Raza': row[5]?.value?.toString() ?? '',
          'Servicio': row[6]?.value?.toString() ?? '',
          'Valor a Pagar': row[7]?.value?.toString() ?? '',
          'Método de Pago': row[8]?.value?.toString() ?? '',
          'Fecha': row[9]?.value?.toString() ?? '',
        });
      }
    }

    setState(() {
      clienteData.datosCargados = true;
      clienteData.clientesFiltrados = List.from(clienteData.clientes);
    });

    _guardarDatos(); // Guardar los datos
  }

  void _filtrarClientes(String value) {
    setState(() {
      clienteData.clientesFiltrados = clienteData.clientes
          .where((cliente) => cliente['Cliente']
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  Future<void> _guardarDatos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'clientes', json.encode(clienteData.clientes.map((e) => e).toList()));
  }

  Future<void> _cargarDatosGuardados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('clientes');
    if (jsonData != null) {
      List<dynamic> decodedData = json.decode(jsonData);
      clienteData.clientes = decodedData.cast<Map<String, dynamic>>();
      clienteData.clientesFiltrados = List.from(clienteData.clientes);
      setState(() {
        clienteData.datosCargados = true;
      });
    }
  }
}

class DetallesClientePage extends StatelessWidget {
  final Map<String, dynamic> cliente;

  const DetallesClientePage({required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Cliente'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('ID', cliente['ID']),
              _buildDetailItem('Nombre', cliente['Cliente']),
              _buildDetailItem('Celular', cliente['Celular']),
              _buildDetailItem('Nombre Mascota', cliente['Nombre Mascota']),
              _buildDetailItem('Tipo de Mascota', cliente['Tipo de Mascota']),
              _buildDetailItem('Raza', cliente['Raza']),
              _buildDetailItem('Servicio', cliente['Servicio']),
              _buildDetailItem('Valor a Pagar', cliente['Valor a Pagar']),
              _buildDetailItem('Método de Pago', cliente['Método de Pago']),
              _buildDetailItem('Fecha', cliente['Fecha']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
