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
              _buildTextField('Registro', 'Ingrese el registro del producto',
                  (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un registro';
                }
                return null;
              }, (value) {
                _registro = value!;
              }),
              const SizedBox(height: 16.0),
              _buildTextField('Valor', 'Ingrese el valor del producto',
                  (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un valor';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un número válido';
                }
                return null;
              }, (value) {
                _valor = double.parse(value!);
              }, keyboardType: TextInputType.number),
              const SizedBox(height: 16.0),
              _buildDropdown('Medio de Pago', [
                'Efectivo',
                'Nequi',
                'Daviplata',
                'Débito',
                'Crédito'
              ], (String? value) {
                setState(() {
                  _medioDePago = value!;
                });
              }, (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor seleccione un medio de pago';
                }
                return null;
              }),
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

  Widget _buildTextField(String labelText, String hintText,
      FormFieldValidator<String>? validator, FormFieldSetter<String> onSaved,
      {TextInputType? keyboardType}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      validator: validator,
      onSaved: onSaved,
      keyboardType: keyboardType,
    );
  }

  Widget _buildDropdown(String labelText, List<String> items,
      ValueChanged<String?> onChanged, FormFieldValidator<String>? validator) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      value: _medioDePago,
      items: items
          .map<DropdownMenuItem<String>>(
            (String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
