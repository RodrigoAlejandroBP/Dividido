import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';
import 'package:gestor_gastos/widgets/gastos_widget.dart';
import 'package:gestor_gastos/pages/agregar_detalle_page.dart';
import 'package:gestor_gastos/pages/resumen_gasto_page.dart';
import 'package:gestor_gastos/pages/resumen_mensual_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    print('HomePage: Inicializando...');
  }

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      // Opcional: Limpia cualquier estado local si es necesario
      final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
      // Aquí podrías añadir lógica para limpiar el estado del provider si es necesario
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      GastosWidget(
        onEditarGasto: (index) => _navegarAAgregarDetalle(context, gastoIndex: index),
        onEliminarGasto: Provider.of<GastosProvider>(context, listen: false).eliminarGasto,
        onAgregarSubGasto: (index) => _navegarAAgregarDetalle(context, gastoIndex: index, esSubGasto: true),
        onVerResumen: (index) => _verResumen(context, index),
      ),
      const ResumenMensualPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _navegarAAgregarDetalle(context),
              tooltip: 'Agregar Gasto',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Gastos'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Mensual'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
    );
  }
}