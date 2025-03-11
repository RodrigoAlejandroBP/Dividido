import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';
import 'package:gestor_gastos/widgets/gastos_widget.dart';
import 'package:gestor_gastos/widgets/responsables_widget.dart';
import 'package:gestor_gastos/pages/agregar_detalle_page.dart';
import 'package:gestor_gastos/pages/resumen_gasto_page.dart';
import 'package:gestor_gastos/pages/resumen_mensual_page.dart'; // Nuevo import

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});
  final String title;

  void _navegarAAgregarDetalle(BuildContext context, {int? gastoIndex, bool esSubGasto = false}) {
    final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
    final gastoExistente = gastoIndex != null ? gastosProvider.gastos[gastoIndex] : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarDetallePage(
          gastoExistente: gastoExistente,
          gastoIndex: gastoIndex,
          esSubGasto: esSubGasto,
          responsables: gastosProvider.responsables,
          onAgregarResponsable: gastosProvider.agregarResponsable,
        ),
      ),
    );
  }

  void _verResumen(BuildContext context, int index) {
    final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumenGastoPage(gasto: gastosProvider.gastos[index]),
      ),
    );
  }

  void _verResumenMensual(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResumenMensualPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Gastos'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Resumen Mensual'),
              onTap: () {
                Navigator.pop(context);
                _verResumenMensual(context);
              },
            ),
            Consumer<GastosProvider>(
              builder: (context, gastosProvider, child) {
                return ResponsablesWidget(
                  responsables: gastosProvider.responsables,
                  onAgregarResponsable: gastosProvider.agregarResponsable,
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<GastosProvider>(
        builder: (context, gastosProvider, child) {
          return GastosWidget(
            onEditarGasto: (index) => _navegarAAgregarDetalle(context, gastoIndex: index),
            onEliminarGasto: gastosProvider.eliminarGasto,
            onAgregarSubGasto: (index) => _navegarAAgregarDetalle(context, gastoIndex: index, esSubGasto: true),
            onVerResumen: (index) => _verResumen(context, index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarAAgregarDetalle(context),
        tooltip: 'Agregar Gasto',
        child: const Icon(Icons.add),
      ),
    );
  }
}