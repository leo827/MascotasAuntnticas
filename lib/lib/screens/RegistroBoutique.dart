import 'package:flutter/material.dart';
import 'package:spamascotas/lib/utils/DBHelperboutique.dart';
import 'BoutiquePage.dart';

class RegistroBoutique extends StatefulWidget {
  const RegistroBoutique({Key? key}) : super(key: key);

  @override
  _RegistroBoutiqueState createState() => _RegistroBoutiqueState();
}

class _RegistroBoutiqueState extends State<RegistroBoutique> {
  List<Map<String, dynamic>> _productos = [];

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    final db = await DBHelper.database;
    final productos = await db.query(DBHelper.tableName);
    setState(() {
      _productos = productos;
    });
  }

  Future<void> _eliminarProducto(int id) async {
    await DBHelper.eliminarProducto(id);
    _loadProductos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Producto eliminado con éxito'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Boutique'),
        automaticallyImplyLeading: false, // Esta línea quita la flecha de retroceso
      ),

      body: ListView.builder(
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final producto = _productos[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: Text(
                producto['registro'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat', fontSize: 16),
              ),
              subtitle: Text(
                'Valor: ${producto['valor']}, Medio de Pago: ${producto['medioDePago']}',
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.pink[200],
                child: const Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _confirmarEliminarProducto(producto['id']);
                },
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BoutiquePage()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _confirmarEliminarProducto(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que deseas eliminar este producto?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                _eliminarProducto(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
