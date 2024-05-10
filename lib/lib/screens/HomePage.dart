import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spamascotas/lib/screens/DetallesCliente.dart';
import 'package:spamascotas/lib/screens/NuevaPantalla.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _filteredJournals = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  void _refreshJournals() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('clientes').get();
      setState(() {
        _filteredJournals = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error al recuperar los registros: $e");
      setState(() {
        _isLoading = false;
      });
    }
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
              child: Column(
                children: [
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
                ],
              ),
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
                          return ListTile(
                            leading:
                                _filteredJournals[index]['imagenUrl'] != null
                                    ? SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Image.network(
                                          _filteredJournals[index]['imagenUrl'],
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetallesCliente(
                                    cliente: _filteredJournals[index],
                                  ),
                                ),
                              );
                            },
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroPage(),
            ),
          ).then((_) {
            // Realiza alguna acción después de que el usuario regrese de la página de registro
            _refreshJournals(); // Por ejemplo, actualiza la lista de clientes
          });
        },
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

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filterJournals('');
    });
  }

  void _filterJournals(String query) {
    setState(() {
      if (query.isEmpty) {
        // Si la consulta está vacía, restaura la lista completa de clientes
        _refreshJournals();
      } else {
        // Filtra los clientes basados en la consulta
        _filteredJournals = _filteredJournals.where((journal) {
          final cliente =
              (journal['nombreCliente'] ?? '').toString().toLowerCase();
          final celular =
              (journal['numeroCelular'] ?? '').toString().toLowerCase();

          return cliente.contains(query.toLowerCase()) ||
              celular.contains(query.toLowerCase());
        }).toList();
      }
    });
  }
}
