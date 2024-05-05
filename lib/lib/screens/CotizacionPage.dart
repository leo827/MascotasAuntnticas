import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spamascotas/lib/screens/CotizacionClientes.dart';
import 'package:spamascotas/lib/screens/DetallesCotizacion.dart';
import 'package:spamascotas/lib/utils/DatabaseHelperCotizacion.dart';


class CotizacionPage extends StatefulWidget {
  @override
  _CotizacionPageState createState() => _CotizacionPageState();
}

class _CotizacionPageState extends State<CotizacionPage> {
  final dbHelper = DatabaseHelperCotizacion();
  late List<Map<String, dynamic>> _cotizaciones;
  late List<Map<String, dynamic>> _filteredCotizaciones;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _cotizaciones = [];
    _filteredCotizaciones = [];
    _fetchCotizaciones();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCotizaciones() async {
    final cotizaciones = await dbHelper.getAllCotizaciones();
    setState(() {
      _cotizaciones = cotizaciones;
      _filteredCotizaciones = cotizaciones;
    });
  }

  void _filterCotizaciones(String searchTerm) {
    setState(() {
      _filteredCotizaciones = _cotizaciones.where((cotizacion) {
        final nombreCliente = cotizacion['nombreCliente'].toString().toLowerCase();
        return nombreCliente.contains(searchTerm.toLowerCase());
      }).toList();
    });
  }

  Future<void> _confirmDelete(int index) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Está seguro de que desea eliminar esta cotización?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar eliminación
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                await _deleteCotizacion(index);
                Navigator.of(context).pop(); // Cerrar diálogo de confirmación
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCotizacion(int index) async {
    final cotizacionId = _filteredCotizaciones[index]['id'];
    await dbHelper.deleteCotizacion(cotizacionId);
    _fetchCotizaciones();
    _showDeleteSuccessMessage();
  }

  void _showDeleteSuccessMessage() {
    Fluttertoast.showToast(
      msg: "Cotización eliminada exitosamente",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotización'),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: TextField(
                controller: _searchController,
                onChanged: _filterCotizaciones,
                decoration: InputDecoration(
                  hintText: 'Buscar cotización...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterCotizaciones('');
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CotizacionClientes()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cotizaciones',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCotizaciones.length,
              itemBuilder: (context, index) {
                final cotizacion = _filteredCotizaciones[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.pets, color: Colors.green),
                    title: Text(
                      cotizacion['nombreCliente'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      cotizacion['celular'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetallesCotizacion(cotizacionId: cotizacion['id']),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        _confirmDelete(index);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
