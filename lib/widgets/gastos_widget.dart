import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';

class GastosWidget extends StatelessWidget {
  const GastosWidget({
    super.key,
    required this.onEditarGasto,
    required this.onEliminarGasto,
    required this.onAgregarSubGasto,
    required this.onVerResumen,
  });

  final void Function(int) onEditarGasto;
  final void Function(int) onEliminarGasto;
  final void Function(int) onAgregarSubGasto;
  final void Function(int) onVerResumen;

  @override
  Widget build(BuildContext context) {
    return Consumer<GastosProvider>(
      builder: (context, gastosProvider, child) {
        return ListView.builder(
          itemCount: gastosProvider.gastos.length,
          itemBuilder: (context, index) {
            var gasto = gastosProvider.gastos[index];
            var subGastos = (gasto['subGastos'] as List).map((e) => Map<String, dynamic>.from(e)).toList();

            return Card(
              elevation: 4,
              color: Colors.orange[50],
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(gasto['responsable'][0]+gasto['responsable'][1], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(gasto['nombre'] ?? 'Sin Nombre', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
                ),
                subtitle: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${gasto['responsable']} ',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(text: '• '),
                                  TextSpan(text: 'Monto: \$${gasto['precio'] ?? 0.0}'),
                                ],
                              ),
                            ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'editar':
                        onEditarGasto(index);
                        break;
                      case 'eliminar':
                        onEliminarGasto(index);
                        break;
                      case 'agregar_subgasto':
                        onAgregarSubGasto(index);
                        break;
                      case 'ver_resumen':
                        onVerResumen(index);
                        break;
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => [
                        _buildMenuItem('editar', Icons.edit, 'Editar'),
                        _buildMenuItem('eliminar', Icons.delete, 'Eliminar', Colors.red),
                        _buildMenuItem('agregar_subgasto', Icons.add, 'Agregar Subgasto'),
                        _buildMenuItem('ver_resumen', Icons.list, 'Ver Resumen'),
                      ],
                ),
                children:
                    subGastos.isNotEmpty
                        ? subGastos.map((subgasto) {
                          return Slidable(
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) => onEditarGasto(index),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: '',
                                  spacing: 2,
                                  autoClose: true,
                                ),
                                SlidableAction(
                                  onPressed: (context) => gastosProvider.eliminarSubGasto(index, subGastos.indexOf(subgasto)),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: '',
                                  spacing: 2,
                                  autoClose: true,
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onLongPress: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.edit),
                                          title: const Text('Editar'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            onEditarGasto(index);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete, color: Colors.red),
                                          title: const Text('Eliminar'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            gastosProvider.eliminarSubGasto(index, subGastos.indexOf(subgasto));
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: ListTile(
                                tileColor: Colors.blue[50],
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(subgasto['responsable'][0]+subgasto['responsable'][1], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(subgasto['nombre'] ?? 'Sin Detalle', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${subgasto['responsable']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold), // Negrita para el responsable
                                      ),
                                      const TextSpan(text: ' • '),
                                      TextSpan(text: 'Monto: \$${subgasto['precio'] ?? 0.0}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList()
                        : [const ListTile(title: Text('No hay subgastos'))],
              ),
            );
          },
        );
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text, [Color? color]) {
    return PopupMenuItem<String>(value: value, child: ListTile(leading: Icon(icon, color: color ?? Colors.black, size: 16), title: Text(text)));
  }
}
