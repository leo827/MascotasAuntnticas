import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:spamascotas/lib/screens/login_screen.dart';
import 'package:spamascotas/lib/utils/SQLHelper.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase Core

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    // Inicializar SQLite y Firebase
    await SQLHelper.db(); // Inicializar la base de datos SQLite
    await Firebase.initializeApp(); // Inicializa Firebase

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
