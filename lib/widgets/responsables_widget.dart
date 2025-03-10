import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';

class ResponsablesWidget extends StatefulWidget {
  final List<String> responsables;
  final Function(String) onAgregarResponsable;

  const ResponsablesWidget({super.key, required this.responsables, required this.onAgregarResponsable});

  @override
  _ResponsablesWidgetState createState() => _ResponsablesWidgetState();
}

class _ResponsablesWidgetState extends State<ResponsablesWidget> {
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredResponsables = [];

  @override
  void initState() {
    super.initState();
    _filteredResponsables = widget.responsables;
    _searchController.addListener(_filterResponsables);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterResponsables() {
    setState(() {
      _filteredResponsables = widget.responsables
          .where((responsable) => responsable.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Responsables'),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarDialogoNuevoResponsable(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar Responsable',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        if (_filteredResponsables.isNotEmpty)
          SizedBox(
            height: 200, // Altura fija para evitar que la lista crezca demasiado
            child: Scrollbar(
              child: ListView(
                shrinkWrap: true,
                children: _filteredResponsables.take(4).map((responsable) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(responsable[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(responsable),
                )).toList(),
              ),
            ),
          ),
      ],
    );
  }

  void _mostrarDialogoNuevoResponsable(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Nuevo Responsable'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nombre del Responsable'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  widget.onAgregarResponsable(controller.text);
                  setState(() {
                    _filteredResponsables = widget.responsables;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}
