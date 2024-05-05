import 'package:flutter/material.dart';
import 'package:spamascotas/lib/screens/Menu.dart';
import '../utils/DBHelperboutique.dart';

class BoutiquePage extends StatefulWidget {
  const BoutiquePage({Key? key}) : super(key: key);

  @override
  _BoutiquePageState createState() => _BoutiquePageState();
}

class _BoutiquePageState extends State<BoutiquePage> {
  final _formKey = GlobalKey<FormState>();
  String _registro = '';
  double _valor = 0.0;
  String _medioDePago = '';

  @override
  void initState() {
    super.initState();
    _medioDePago = 'Efectivo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Registro',
                  hintText: 'Ingrese el registro del producto',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un registro';
                  }
                  return null;
                },
                onSaved: (value) {
                  _registro = value!;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  hintText: 'Ingrese el valor del producto',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un valor';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _valor = double.parse(value!);
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Medio de Pago',
                ),
                value: _medioDePago,
                items: ['Efectivo', 'Nequi', 'Daviplata', 'Débito', 'Crédito']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  setState(() {
                    _medioDePago = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione un medio de pago';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await DBHelper.insertProducto(
                        _registro, _valor, _medioDePago);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Producto registrado correctamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Menu(body: menu())),
                    );
                  }
                },
                child:
                    const Text('Registrar', style: TextStyle(fontSize: 16.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
