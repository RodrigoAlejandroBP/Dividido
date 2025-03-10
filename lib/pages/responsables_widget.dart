// responsables_widget.dart
import 'package:flutter/material.dart';

class ResponsablesWidget extends StatelessWidget {
  final List<String> responsables;
  final Function(String) onAgregarResponsable;

  const ResponsablesWidget({
    Key? key,
    required this.responsables,
    required this.onAgregarResponsable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.people),
      title: const Text('Responsables'),
      onTap: () {
        _mostrarDialogoNuevoResponsable(context);
      },
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
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onAgregarResponsable(controller.text);
                }
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}
