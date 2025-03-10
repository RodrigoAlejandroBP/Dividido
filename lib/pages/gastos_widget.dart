import 'package:flutter/material.dart';

class GastosWidget extends StatefulWidget {
  final List<Map<String, dynamic>> detalles;
  final Function(int) onEditarGasto;
  final Function(int) onEliminarGasto;
  final Function(int?) onAgregarSubGasto;
  final Function(int) onVerResumen;

  const GastosWidget({
    Key? key,
    required this.detalles,
    required this.onEditarGasto,
    required this.onEliminarGasto,
    required this.onAgregarSubGasto,
    required this.onVerResumen,
  }) : super(key: key);

  @override
  _GastosWidgetState createState() => _GastosWidgetState();
}

class _GastosWidgetState extends State<GastosWidget> {
  void editarSubgasto(int gastoIndex, int subgastoIndex) {
    setState(() {
      var subgasto = widget.detalles[gastoIndex]['subGastos'][subgastoIndex];
      TextEditingController detalleController = TextEditingController(text: subgasto['detalle'] ?? '');
      TextEditingController montoController = TextEditingController(text: (subgasto['monto'] ?? 0.0).toString());

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Editar Subgasto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: detalleController,
                  decoration: InputDecoration(labelText: 'Detalle'),
                ),
                TextField(
                  controller: montoController,
                  decoration: InputDecoration(labelText: 'Monto'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    widget.detalles[gastoIndex]['subGastos'][subgastoIndex] = {
                      'detalle': detalleController.text,
                      'monto': double.tryParse(montoController.text) ?? 0.0,
                    };
                  });
                  Navigator.pop(context);
                },
                child: Text('Guardar'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.detalles.length,
      itemBuilder: (context, index) {
        var gasto = widget.detalles[index];
        return Card(
          child: ExpansionTile(
            title: Text(gasto['nombre'] ?? 'Sin Nombre'),
            subtitle: Text('Total: \$${gasto['precio'] ?? 0.0}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'editar') {
                  widget.onEditarGasto(index);
                } else if (value == 'eliminar') {
                  widget.onEliminarGasto(index);
                } else if (value == 'agregar_subgasto') {
                  widget.onAgregarSubGasto(index);
                } else if (value == 'ver_resumen') {
                  widget.onVerResumen(index);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'editar',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Editar'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'eliminar',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Eliminar'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'agregar_subgasto',
                  child: ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Agregar Subgasto'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'ver_resumen',
                  child: ListTile(
                    leading: Icon(Icons.list),
                    title: Text('Ver Resumen'),
                  ),
                ),
              ],
            ),
            children: gasto['subGastos'].map<Widget>((subgasto) {
              int subIndex = gasto['subGastos'].indexOf(subgasto);
              return ListTile(
                title: Text(subgasto['detalle'] ?? 'Sin Detalle'),
                subtitle: Text('\$${subgasto['monto'] ?? 0.0}'),
                onLongPress: () => editarSubgasto(index, subIndex),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
