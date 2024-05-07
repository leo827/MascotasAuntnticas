import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spamascotas/lib/screens/ExcelExporterAppointments.dart';
import 'package:spamascotas/lib/screens/ExcelExporterClientes.dart';
import 'package:spamascotas/lib/screens/login_screen.dart';
import '../utils/SQLHelper.dart';
import '../utils/ExcelExporter.dart';
import 'HistorialUsuarioPage.dart';
import 'HomePage.dart';
import 'MiAgenda.dart';
import 'MisCuentasPage.dart';
import 'RegistroBoutique.dart';
import 'CotizacionPage.dart';
import 'ExcelExporterCotizaciones.dart';

class Menu extends StatefulWidget {
  final Widget body;

  const Menu({required this.body, Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;
  late Timer _timer;

  final List<Widget> _screens = [
    const HomePage(),
    const RegistroBoutique(),
    MiAgenda(),
    MisCuentasPage(),
    CotizacionPage(),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(days: 15), (_) {
      _exportAndShowSnackBar(context);
      _exportClientesAndShowSnackBar(
          context); // Llamar a la exportación específica de clientes
      _exportAppointmentsAndShowSnackBar(context);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _exportClientesAndShowSnackBar(BuildContext context) async {
    try {
      await Future.delayed(Duration(seconds: 3)); // Espera de 3 segundos
      List<Map<String, dynamic>> data = await SQLHelper.getRegistros();
      await ExcelExporterClientes.exportToExcelAndSendEmail2(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos de clientes exportados a Excel'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error al exportar a Excel y enviar correo: $error');
    }
  }

  void _exportAppointmentsAndShowSnackBar(BuildContext context) async {
    try {
      await Future.delayed(Duration(seconds: 4)); // Espera de 4 segundos
      await ExcelExporterAppointments.exportAppointmentsToExcel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Citas exportadas a Excel'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error al exportar citas: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al exportar citas'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _exportAndShowSnackBar(BuildContext context) async {
    try {
      await Future.delayed(Duration(seconds: 5)); // Espera de 5 segundos
      await ExcelExporter.exportToExcelAndSendEmail();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos exportados a Excel'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error al exportar a Excel y enviar correo: $error');
    }
  }

  void _exportCotizaciones(BuildContext context) async {
    try {
      await ExcelExporterCotizaciones
          .exportCotizacionesToExcelAndSendEmail(); // Exportar cotizaciones
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cotizaciones exportadas correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error al exportar cotizaciones: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al exportar cotizaciones'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Salir de la aplicación'),
            content: const Text(
                '¿Estás seguro de que quieres salir de la aplicación?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // No sale de la aplicación
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Sale de la aplicación
                },
                child: const Text('Sí'),
              ),
            ],
          ),
        );
        return exit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menú'),
          actions: [],
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.grey[200],
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 40.0,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/images/avatar.png'),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Mascotas Auténticas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Un buen servicio para su mascota.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10.0,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.file_upload, color: Colors.blue),
                  title: const Text('Exportar Excel Clientes',
                      style: TextStyle(color: Colors.black87)),
                  onTap: () async {
                    Navigator.pop(context);
                    _exportClientesAndShowSnackBar(
                        context); // Llamar a la exportación específica de clientes
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart, color: Colors.blue),
                  title: const Text('Exportar Excel Boutique',
                      style: TextStyle(color: Colors.black87)),
                  onTap: () async {
                    Navigator.pop(context);
                    _exportAndShowSnackBar(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.request_quote, color: Colors.blue),
                  title: const Text('Exportar Cotizaciones',
                      style: TextStyle(color: Colors.black87)),
                  onTap: () async {
                    Navigator.pop(context);
                    _exportCotizaciones(context);
                  },
                ),
                Divider(
                  color: Colors.grey[400],
                  thickness: 0.8,
                  height: 0.0,
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_download, color: Colors.blue),
                  title: const Text('Importar Base de Datos',
                      style: TextStyle(color: Colors.black87)),
                  onTap: () async {
                    Navigator.pop(context);
                    final updatedData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistorialUsuarioPage()),
                    );
                    if (updatedData != null) {
                      // Actualiza los datos con los datos actualizados
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.blue),
                  title: const Text('Cerrar Sesión',
                      style: TextStyle(color: Colors.black87)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: _screens[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey[200],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey[600],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Clientes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Boutique',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Agenda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Finanzas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.request_quote),
              label: 'Cotización',
            ),
          ],
          selectedFontSize: 14.0,
          unselectedFontSize: 12.0,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

class menu extends StatelessWidget {
  const menu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Menu(
      body: Column(
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Image.asset('assets/images/avatar.png'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [
                  _buildCard(
                    icon: Icons.person,
                    title: 'Registro Cliente',
                    onTap: () {},
                  ),
                  _buildCard(
                    icon: Icons.store,
                    title: 'Boutique',
                    onTap: () {},
                  ),
                  _buildCard(
                    icon: Icons.calendar_today,
                    title: 'Agenda',
                    onTap: () {},
                  ),
                  _buildCard(
                    icon: Icons.attach_money,
                    title: 'Gastos',
                    onTap: () {},
                  ),
                  _buildCard(
                    icon: Icons.request_quote,
                    title: 'Exportar Cotizaciones',
                    onTap: () {
                      _MenuState()._exportCotizaciones(
                          context); // Llamamos al método _exportCotizaciones desde _MenuState
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.0,
              color: Colors.blue,
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
