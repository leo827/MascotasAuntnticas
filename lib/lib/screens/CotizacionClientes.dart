import 'package:flutter/material.dart';
import 'package:spamascotas/lib/screens/Menu.dart';
import 'package:spamascotas/lib/utils/DatabaseHelperCotizacion.dart';

class CotizacionClientes extends StatefulWidget {
  @override
  _CotizacionClientesState createState() => _CotizacionClientesState();
}

class _CotizacionClientesState extends State<CotizacionClientes> {
  final _formKey = GlobalKey<FormState>();
  final _nombreClienteController = TextEditingController();
  final _celularController = TextEditingController();
  final _nombreMascotaController = TextEditingController();
  String? _selectedTipoServicio;
  final _valorController = TextEditingController();

  final dbHelper = DatabaseHelperCotizacion();

  @override
  void dispose() {
    _nombreClienteController.dispose();
    _celularController.dispose();
    _nombreMascotaController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cotización para Clientes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreClienteController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Cliente',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del cliente';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _celularController,
                decoration: InputDecoration(
                  labelText: 'Número de Celular',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el número de celular';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nombreMascotaController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Mascota',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre de la mascota';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedTipoServicio,
                decoration: InputDecoration(
                  labelText: 'Tipo de Servicio',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Baño',
                  'Baño Deslanado',
                  'Baño corte y Deslanado',
                  'Baño seco',
                  'Baño anti pulgas',
                  'Baño medicado',
                  'Corte de uñas',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTipoServicio = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione el tipo de servicio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _valorController,
                decoration: InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el valor';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Por favor ingrese un valor válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _guardarRegistro();
                  }
                },
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _guardarRegistro() async {
    await dbHelper.insert({
      'nombreCliente': _nombreClienteController.text,
      'celular': _celularController.text,
      'nombreMascota': _nombreMascotaController.text,
      'tipoServicio': _selectedTipoServicio,
      'valor': int.parse(_valorController.text),
    });

    _limpiarCampos();

    // Mostrar el mensaje de registro exitoso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registro exitoso'),
        duration: Duration(seconds: 2), // Duración del mensaje
      ),
    );

    // Navegar a la clase Menu
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Menu(body: menu())),
    );
  }

  void _limpiarCampos() {
    _nombreClienteController.clear();
    _celularController.clear();
    _nombreMascotaController.clear();
    _valorController.clear();
    setState(() {
      _selectedTipoServicio = null;
    });
  }
}
