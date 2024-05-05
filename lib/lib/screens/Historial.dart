import 'package:flutter/material.dart';

class Historial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Usuario'),
      ),
      body: const Center(
        child: Text(
          'Contenido del historial de usuario aquí',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
