import 'package:flutter/material.dart';
import 'package:spamascotas/lib/screens/Menu.dart';
import 'HomePage.dart';
import '../utils/SQLHelper.dart';
import 'dart:io'; // Importamos dart:io para trabajar con archivos
import 'package:image_picker/image_picker.dart'; // Importamos el paquete image_picker

class RegistroPage extends StatefulWidget {
  const RegistroPage({Key? key}) : super(key: key);

  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  File? _imagenSeleccionada; // Variable para almacenar la imagen seleccionada
  TextEditingController _nombreClienteController = TextEditingController();
  TextEditingController _numeroCelularController = TextEditingController();
  TextEditingController _nombreMascotaController = TextEditingController();
  String? _tipoMascota;
  TextEditingController _razaController = TextEditingController();
  String? _servicio;
  TextEditingController _valorAPagarController = TextEditingController();
  String? _metodoPago;
  DateTime fecha = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Widget para seleccionar la fecha
                _buildDatePickerWithIcon(
                  labelText: 'Fecha',
                  icon: Icons.calendar_today,
                ),
                // Widget para seleccionar la imagen
                _buildImagePicker(),
                // Widget para el campo de nombre del cliente
                _buildTextFieldWithIcon(
                  controller: _nombreClienteController,
                  labelText: 'Nombre cliente',
                  icon: Icons.person,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el nombre del cliente';
                    }
                    return null;
                  },
                ),
                // Widget para el campo de número de celular
                _buildTextFieldWithIcon(
                  controller: _numeroCelularController,
                  labelText: 'Número de celular',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el número de celular';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Por favor, ingrese un número de celular válido';
                    }
                    return null;
                  },
                ),
                // Widget para el campo de nombre de la mascota
                _buildTextFieldWithIcon(
                  controller: _nombreMascotaController,
                  labelText: 'Nombre mascota',
                  icon: Icons.pets,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el nombre de la mascota';
                    }
                    return null;
                  },
                ),
                // Widget para seleccionar el tipo de mascota
                _buildDropdownWithIcon(
                  value: _tipoMascota,
                  onChanged: (value) {
                    setState(() {
                      _tipoMascota = value;
                    });
                  },
                  items: ['Perro', 'Gato'],
                  labelText: 'Tipo de mascota',
                  icon: Icons.pets,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione el tipo de mascota';
                    }
                    return null;
                  },
                ),
                // Widget para el campo de raza
                _buildTextFieldWithIcon(
                  controller: _razaController,
                  labelText: 'Raza',
                  icon: Icons.pets_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese la raza de la mascota';
                    }
                    return null;
                  },
                ),
                // Widget para seleccionar el tipo de servicio
                _buildDropdownWithIcon(
                  value: _servicio,
                  onChanged: (value) {
                    setState(() {
                      _servicio = value;
                    });
                  },
                  items: [
                    'Baño',
                    'Baño Deslanado',
                    'Baño corte y Deslanado',
                    'Baño seco',
                    'Baño anti pulgas',
                    'Baño medicado',
                    'Corte de uñas',
                  ],
                  labelText: 'Servicio',
                  icon: Icons.business_center,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione el tipo de servicio';
                    }
                    return null;
                  },
                ),
                // Widget para el campo de valor a pagar
                _buildTextFieldWithIcon(
                  controller: _valorAPagarController,
                  labelText: 'Valor a pagar',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el valor a pagar';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor, ingrese un valor numérico válido';
                    }
                    return null;
                  },
                ),
                // Widget para seleccionar el método de pago
                _buildDropdownWithIcon(
                  value: _metodoPago,
                  onChanged: (value) {
                    setState(() {
                      _metodoPago = value;
                    });
                  },
                  items: [
                    'Efectivo',
                    'Nequi',
                    'Daviplata',
                    'Débito',
                    'Crédito'
                  ],
                  labelText: 'Método de pago',
                  icon: Icons.payment,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione el método de pago';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Botón para guardar los datos
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _guardarDatos,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                    ),
                    child: const Text(
                      'Registrar',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para seleccionar una imagen desde la galería o la cámara
  Future<void> _seleccionarImagen(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imagenSeleccionada = File(pickedFile.path);
      } else {
        print('No se seleccionó ninguna imagen.');
      }
    });
  }

// Widget para el selector de imagen
  Widget _buildImagePicker() {
    return Column(
      children: [
        _imagenSeleccionada == null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: () => _seleccionarImagen(ImageSource.gallery),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () => _seleccionarImagen(ImageSource.camera),
                  ),
                ],
              )
            : Image.file(_imagenSeleccionada!), // Mostrar imagen seleccionada
        const Text(
          'Seleccione una imagen',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Método para guardar los datos del formulario
  Future<void> _guardarDatos() async {
    if (_formKey.currentState?.validate() ?? false) {
      final datosCliente = {
        'nombreCliente': _nombreClienteController.text,
        'numeroCelular': _numeroCelularController.text,
        'nombreMascota': _nombreMascotaController.text,
        'tipoMascota': _tipoMascota ?? '',
        'raza': _razaController.text,
        'servicio': _servicio ?? '',
        'valorAPagar': _valorAPagarController.text,
        'metodoPago': _metodoPago ?? '',
        'fecha': _formatFecha(fecha),
        'imagen': _imagenSeleccionada?.path, // Agregar la ruta de la imagen
      };

      await SQLHelper.createItem(datosCliente);

      _limpiarCampos();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente registrado exitosamente!'),
        ),
      );

      // Ir a la página principal y reemplazar la actual
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Menu(body: HomePage()),
        ),
      );
    }
  }

  // Método para limpiar los campos del formulario
  void _limpiarCampos() {
    _nombreClienteController.clear();
    _numeroCelularController.clear();
    _nombreMascotaController.clear();
    _razaController.clear();
    _valorAPagarController.clear();
  }

  // Widget para construir un campo de texto con un icono
  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  // Widget para construir un dropdown con un icono
  Widget _buildDropdownWithIcon({
    required String? value,
    required ValueChanged<String?>? onChanged,
    required List<String> items,
    required String labelText,
    required IconData icon,
    FormFieldValidator<String>? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  // Widget para construir un selector de fecha con un icono
  Widget _buildDatePickerWithIcon({
    required String labelText,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        _mostrarDatePicker(context);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatFecha(fecha),
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  // Método para mostrar un selector de fecha
  Future<void> _mostrarDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != fecha) {
      setState(() {
        fecha = picked;
      });
    }
  }

  // Método para formatear la fecha
  String _formatFecha(DateTime fecha) {
    return "${fecha.day}/${fecha.month}/${fecha.year}";
  }
}
