import 'package:flutter/material.dart';
import 'package:spamascotas/lib/utils/DBHelperboutique.dart';
import 'package:spamascotas/lib/utils/SQLHelper.dart';

class MisCuentasPage extends StatefulWidget {
  @override
  _MisCuentasPageState createState() => _MisCuentasPageState();
}

class _MisCuentasPageState extends State<MisCuentasPage> {
  double totalValorAPagar = 0.0;
  double totalValorProductos = 0.0;
  bool verVentasDiarias = true;

  @override
  void initState() {
    super.initState();
    sumarValores();
  }

  Future<void> sumarValores() async {
    try {
      if (verVentasDiarias) {
        final List<Map<String, dynamic>> registros =
            await SQLHelper.getRegistros();
        double totalRegistros = 0.0;
        for (var registro in registros) {
          totalRegistros += double.parse(registro['valorAPagar']);
        }
        setState(() {
          totalValorAPagar = totalRegistros;
        });
      } else {
        final double ventasMensuales = await DBHelper.getGastosMensuales();
        setState(() {
          totalValorAPagar = ventasMensuales;
        });
      }

      final List<Map<String, dynamic>> productos =
          await DBHelper.queryProductos();
      double totalProductos = 0.0;
      for (var producto in productos) {
        totalProductos += producto['valor'] as double;
      }

      setState(() {
        totalValorProductos = totalProductos;
      });

      // Actualizar el valor de productos del boutique
      await _sumarValoresBoutique();
    } catch (error) {
      print('Error al sumar los valores: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cuentas'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCardView('Total Valor Productos', totalValorAPagar),
                  const SizedBox(height: 20),
                  _buildCardView('Total Valor Boutique', totalValorProductos),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF55C7F7), Color(0xFF4255AF)],
                ),
              ),
              child: TextButton(
                onPressed: () async {
                  setState(() {
                    verVentasDiarias = !verVentasDiarias;
                  });
                  await sumarValores();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    verVentasDiarias
                        ? 'Ver Ventas Mensuales'
                        : 'Ver Ventas Diarias',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sumarValoresBoutique() async {
    try {
      if (verVentasDiarias) {
        return;
      } else {
        final double totalVentasBoutique = await DBHelper.obtenerTotalVentas();
        setState(() {
          totalValorProductos = totalVentasBoutique;
        });
      }
    } catch (error) {
      print('Error al sumar los valores del boutique: $error');
    }
  }

  Widget _buildCardView(String title, double value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment(-0.81, -0.641),
          end: Alignment(0.868, 0.832),
          colors: <Color>[Color(0xff586483), Color(0xff313649)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xff4f5975),
            offset: Offset(0, 4),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}
