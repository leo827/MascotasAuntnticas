import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:spamascotas/lib/screens/Menu.dart';
import 'HomePage.dart';
import '../utils/SQLHelper.dart';
import 'dart:io'; // Importamos dart:io para trabajar con archivos
import 'package:image_picker/image_picker.dart'; // Importamos el paquete image_picker
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
  TextEditingController _atendidoPorController = TextEditingController();

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
                    'Deslanado',
                    'corte',
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
                _buildTextFieldWithIcon(
                  controller: _atendidoPorController,
                  labelText: 'Atendido por',
                  icon: Icons.person,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el nombre de la persona que atendió';
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
    if (pickedFile != null) {
      final File imagenOriginal = File(pickedFile.path);
      final File? imagenComprimida = await _comprimirImagen(imagenOriginal);
      if (imagenComprimida != null) {
        setState(() {
          _imagenSeleccionada = imagenComprimida;
        });
      }
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  Future<File?> _comprimirImagen(File imagenOriginal) async {
    // Obtener la ruta de salida para la imagen comprimida
    final String carpeta = imagenOriginal
        .parent.path; // Obtener la carpeta donde está la imagen original
    final String nombreArchivo =
        '${DateTime.now().millisecondsSinceEpoch}.jpg'; // Generar un nombre de archivo único
    final String rutaSalida =
        '$carpeta/comprimida_$nombreArchivo'; // Ruta de salida para la imagen comprimida

    final result = await FlutterImageCompress.compressAndGetFile(
      imagenOriginal.path,
      rutaSalida, // Utilizar la nueva ruta de salida para la imagen comprimida
      quality: 70, // Calidad de compresión (0 a 100)
    );

    if (result != null && result is XFile) {
      return File(result.path);
    } else {
      // En caso de que el resultado no sea válido, retorna null
      return null;
    }
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
      // Mostrar Snackbar de procesamiento
      final snackBar = SnackBar(
        content: Text('Procesando registro...'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

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
        'atendidoPor': _atendidoPorController.text,
      };

      // Subir la imagen a Firebase Storage y obtener la URL
      String imageUrl = '';
      if (_imagenSeleccionada != null) {
        imageUrl =
            await FirebaseHelper.uploadImageToStorage(_imagenSeleccionada!);
      }

      // Agregar la URL de la imagen a los datos del cliente
      datosCliente['imagenUrl'] = imageUrl;

      // Guardar los datos en Firestore
      await FirebaseHelper.uploadDataToFirestore(datosCliente);

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

// Método para subir la imagen a Firebase Storage
  Future<void> _subirImagen(File imagen) async {
    try {
      // Referencia al bucket de Firebase Storage y ruta donde se guardará la imagen
      final firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('Mascotas/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Subir la imagen
      await ref.putFile(imagen);

      // Obtener la URL de descarga de la imagen
      final String downloadURL = await ref.getDownloadURL();

      print('Imagen subida con éxito: $downloadURL');
    } catch (e) {
      print('Error al subir la imagen: $e');
    }
  }

  // Método para limpiar los campos del formulario
  void _limpiarCampos() {
    _nombreClienteController.clear();
    _numeroCelularController.clear();
    _nombreMascotaController.clear();
    _razaController.clear();
    _valorAPagarController.clear();
    _atendidoPorController.clear();
  }

  // Widget para construir un campo de texto con un icono
  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownWithIcon({
    required String? value,
    required ValueChanged<String?>? onChanged,
    required List<String> items,
    required String labelText,
    required IconData icon,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: validator,
      ),
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
