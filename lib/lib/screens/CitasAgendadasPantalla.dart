import 'package:flutter/material.dart';
import '../utils/Cita.dart';
import '../utils/CitasManager.dart';

class CitasAgendadasPantalla extends StatefulWidget {
  @override
  _CitasAgendadasPantallaState createState() => _CitasAgendadasPantallaState();
}

class _CitasAgendadasPantallaState extends State<CitasAgendadasPantalla> {
  late List<Cita> citas;
  late List<Cita> citasFiltradas;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    citas = CitasManager.obtenerCitas();
    citasFiltradas = List.from(citas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas Agendadas'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
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
              onChanged: (value) {
                _filtrarCitas();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: citasFiltradas.length,
              itemBuilder: (context, index) {
                final cita = citasFiltradas[index];
                return ListTile(
                  title: Text('Cliente: ${cita.nombreCliente}'),
                  subtitle: Text('Fecha: ${cita.fecha}, Hora: ${cita.hora}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _mostrarDialogoEliminacion(context, cita);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminacion(BuildContext context, Cita cita) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Cita'),
          content: Text('¿Estás seguro de que deseas eliminar esta cita?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                CitasManager.eliminarCita(cita);
                setState(() {
                  citas.remove(cita);
                  citasFiltradas.remove(cita);
                });
                Navigator.of(context).pop();
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _filtrarCitas() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      citasFiltradas = citas
          .where(
              (cita) => cita.nombreCliente.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      citasFiltradas = List.from(citas);
    });
  }
}
