import 'dart:io';
import 'package:flutter/material.dart';
import 'package:spamascotas/lib/screens/DetallesPantalla.dart';
import 'package:spamascotas/lib/screens/NuevaPantalla.dart';
import 'package:spamascotas/lib/utils/SQLHelper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];
  List<Map<String, dynamic>> _filteredJournals = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filterJournals('');
    });
  }

  void _refreshJournals() async {
    print("Actualizando listas...");
    final data = await SQLHelper.getRegistros();
    setState(() {
      _journals = data;
      _filteredJournals = data;
      _isLoading = false;
    });
    print("Listas actualizadas: $_journals");
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _clienteController.text = existingJournal['nombreCliente'];
      _celularController.text = existingJournal['numeroCelular'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _clienteController,
              decoration: const InputDecoration(hintText: 'Nombre del Cliente'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _celularController,
              decoration: const InputDecoration(hintText: 'Número de Celular'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (id != null) {
                  await _updateItem(id);
                }
                _clienteController.text = '';
                _celularController.text = '';

                if (!mounted) return;
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Crear Nuevo' : 'Actualizar'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _updateItem(int id) async {
    if (_clienteController.text.isNotEmpty) {
      String? numeroCelular = _celularController.text;

      await SQLHelper.updateItem(id, _clienteController.text, numeroCelular);
      _refreshJournals();
    } else {
      print("Error: Datos incompletos");
    }
  }

  Future<void> _deleteItem(int id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que quieres eliminar este cliente?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await SQLHelper.deleteItem(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cliente eliminado exitosamente!'),
      ));
      _refreshJournals();
    }
  }

  void _navigateToNewScreen() {
    _searchFocusNode.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroPage(),
      ),
    ).then((_) {
      _refreshJournals();
    });
  }

  void _mostrarDetalles(Map<String, dynamic> registro) {
    _searchFocusNode.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetallesPantalla(
          registro: registro,
          imagenPath: registro['imagen'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Registro Clientes'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              width: width * 0.4,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _filterJournals,
                decoration: InputDecoration(
                  hintText: 'Buscar cliente',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.transparent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    subheading('Mis Clientes'),
                    const SizedBox(
                      width: 100,
                    ),
                  ],
                ),
              ]),
            ),
            Expanded(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: _filteredJournals.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 16.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading:
                                    _filteredJournals[index]['imagen'] != null
                                        ? SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: Image.file(
                                              File(_filteredJournals[index]
                                                  ['imagen']),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Colors.green[300],
                                            child: const Icon(
                                              Icons.pets,
                                              color: Colors.white,
                                            ),
                                          ),
                                title: Text(
                                  'Cliente: ${_filteredJournals[index]['nombreCliente']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  'Celular: ${_filteredJournals[index]['numeroCelular']}',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Wrap(
                                  spacing: -8,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showForm(
                                          _filteredJournals[index]['id']),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteItem(
                                          _filteredJournals[index]['id']),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _mostrarDetalles(_filteredJournals[index]);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _navigateToNewScreen(),
      ),
    );
  }

  Text subheading(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color.fromRGBO(94, 114, 228, 1.0),
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  void _filterJournals(String query) {
    print("Filtrando registros con query: $query");
    setState(() {
      _filteredJournals = _journals.where((journal) {
        final cliente =
            (journal['nombreCliente'] ?? '').toString().toLowerCase();
        final celular =
            (journal['numeroCelular'] ?? '').toString().toLowerCase();

        return cliente.contains(query.toLowerCase()) ||
            celular.contains(query.toLowerCase());
      }).toList();
    });
    print("Registros filtrados: $_filteredJournals");
  }
}
