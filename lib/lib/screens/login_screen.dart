import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:spamascotas/lib/screens/Menu.dart';
import 'package:spamascotas/lib/utils/DatabaseHelper.dart';
import 'package:spamascotas/lib/utils/User.dart';
import 'package:spamascotas/lib/utils/animations.dart';
import '../data/bg_data.dart';
import '../utils/text_utils.dart';
import 'SignUpPage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedIndex = 0;
  bool showOption = false;
  bool _showPassword = false;
  TextEditingController _userController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  late DatabaseHelper _databaseHelper; // Instancia de DatabaseHelper

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper(); // Inicializa DatabaseHelper
  }

  void _clearFields() {
    _userController.clear();
    _passwordController.clear();
  }

  void _login() async {
    String username = _userController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese su usuario y contraseña.'),
        ),
      );
      return;
    }

    // Obtener el usuario desde la base de datos
    User? user = await _databaseHelper.getUserByUsername(username);

    if (user != null && user.password == password) {
      // Si las credenciales son correctas, navegar a la página HomePage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Menu(body: menu())),
      );
      _clearFields(); // Limpiar campos después de iniciar sesión
    } else {
      // Si las credenciales son incorrectas, mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario o contraseña incorrectos.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 49,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: showOption
                  ? ShowUpAnimation(
                      delay: 100,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: bgList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: selectedIndex == index
                                  ? Colors.black
                                  : Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage(bgList[index]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox(),
            ),
            const SizedBox(width: 20),
            showOption
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        showOption = false;
                      });
                    },
                    child:
                        const Icon(Icons.close, color: Colors.black, size: 30),
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        showOption = true;
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(bgList[selectedIndex]),
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgList[selectedIndex]),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          height: 400,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Center(
                        child:
                            TextUtil(text: "Inicio", weight: true, size: 30)),
                    const Spacer(),
                    TextUtil(text: "Usuario"),
                    Container(
                      height: 35,
                      decoration: const BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: Colors.black))),
                      child: TextFormField(
                        controller: _userController,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.mail, color: Colors.black),
                          fillColor: Colors.black,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextUtil(text: "Contraseña"),
                    Container(
                      height: 35,
                      decoration: const BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: Colors.black))),
                      child: TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.black),
                        obscureText:
                            !_showPassword, // Aquí se utiliza _showPassword
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            // Botón para mostrar/ocultar la contraseña
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            icon: Icon(
                              // Cambia el ícono según la visibilidad de la contraseña
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                          ),
                          fillColor: Colors.black,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      child: TextButton(
                        onPressed:
                            _login, // Llamar a la función _login cuando se toque el botón
                        child: Text(
                          "Iniciar sesión",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                          );
                        },
                        child: TextUtil(
                          text: "Crear Nuevo Usuario",
                          size: 12,
                          weight: true,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
