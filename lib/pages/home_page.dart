// home_page.dart
import 'package:flutter/material.dart';
import 'gastos_widget.dart';
import 'responsables_widget.dart';
import 'agregar_detalle_page.dart';
import 'resumen_gasto_page.dart'; // Importamos la nueva página de resumen
import 'gastos_provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> detalles = [];
  List<String> responsables = [];
void _navegarAAgregarDetalle(int? parentIndex) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AgregarDetallePage(
        responsables: responsables,
        gastoTotal: parentIndex != null ? double.tryParse(detalles[parentIndex]['precio'].toString()) : null,
subGastos: parentIndex != null
    ? (detalles[parentIndex]['subGastos'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList()
    : [],

onGuardar: (detalle) {
  setState(() {
    if (parentIndex != null) {
      detalles[parentIndex]['subGastos'] = [
        ...detalles[parentIndex]['subGastos'],
        detalle
      ];
    } else {
      detalles.add({...detalle, 'subGastos': []});
    }
  });
},

      ),
    ),
  );
}


  void _verResumen(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumenGastoPage(gasto: detalles[index]), // Pasamos el gasto principal
      ),
    );
  }

  void _editarGasto(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarDetallePage(
          responsables: responsables,
          gastoExistente: detalles[index],
          subGastos: List<Map<String, dynamic>>.from(detalles[index]['subGastos']),
          onGuardar: (detalleEditado) {
            setState(() {
              detalles[index]['nombre'] = detalleEditado['nombre'];
              detalles[index]['precio'] = detalleEditado['precio'];
            });
          },
        ),
      ),
    );
  }

  void _eliminarGasto(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gasto'),
        content: const Text('¿Seguro que deseas eliminar este gasto? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() {
                detalles.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _agregarResponsable(String nombre) {
    setState(() {
      responsables.add(nombre);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scaffoldKey.currentState?.openDrawer();
            });
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(leading: const Icon(Icons.money), title: const Text('Gastos'), onTap: () => Navigator.pop(context)),
            ResponsablesWidget(responsables: responsables, onAgregarResponsable: _agregarResponsable),
          ],
        ),
      ),
      body: GastosWidget(
        detalles: detalles,
        onEditarGasto: _editarGasto,
        onEliminarGasto: _eliminarGasto,
        onAgregarSubGasto: _navegarAAgregarDetalle, // Pasamos directamente la función
        onVerResumen: _verResumen, // Pasamos la nueva función
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarAAgregarDetalle(null),
        tooltip: 'Agregar Gasto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
