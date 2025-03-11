import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';
import 'package:gestor_gastos/pages/agregar_detalle_page.dart';

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
                  child: Text(_getInitials(gasto['responsable']), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(gasto['nombre'] ?? 'Sin Nombre', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
                ),
                subtitle: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${gasto['responsable']} ', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        ? subGastos.asMap().entries.map((entry) {
                          int subGastoIndex = entry.key;
                          Map<String, dynamic> subgasto = entry.value;
                          bool esIndividual = subgasto['esIndividual'] as bool? ?? false;

                          return Slidable(
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AgregarDetallePage(
                                              gastoExistente: {...subgasto, 'esSubGasto': true, 'subGastoIndex': subGastoIndex},
                                              gastoIndex: index,
                                              esSubGasto: true,
                                              responsables: gastosProvider.responsables,
                                              onAgregarResponsable: gastosProvider.agregarResponsable,
                                            ),
                                      ),
                                    );
                                  },
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: '',
                                  spacing: 2,
                                  autoClose: true,
                                ),
                                SlidableAction(
                                  onPressed: (context) => gastosProvider.eliminarSubGasto(index, subGastoIndex),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => AgregarDetallePage(
                                          gastoExistente: {...subgasto, 'esSubGasto': true, 'subGastoIndex': subGastoIndex},
                                          gastoIndex: index,
                                          esSubGasto: true,
                                          responsables: gastosProvider.responsables,
                                          onAgregarResponsable: gastosProvider.agregarResponsable,
                                        ),
                                  ),
                                );
                              },
                              child: ListTile(
                                tileColor: Colors.blue[50],
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    _getInitials(subgasto['responsable']),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(subgasto['nombre'] ?? 'Sin Detalle', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: '${subgasto['responsable']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: ' • '),
                                      TextSpan(text: 'Monto: \$${subgasto['precio'] ?? 0.0}'),
                                    ],
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (esIndividual) const Icon(Icons.person, color: Colors.green, size: 20),
                                    if (!esIndividual) const Icon(Icons.group, color: Colors.grey, size: 20),
                                    Checkbox(
                                      value: esIndividual,
                                      onChanged: (bool? value) {
                                        gastosProvider.editarSubGasto(index, subGastoIndex, {...subgasto, 'esIndividual': value ?? false});
                                      },
                                    ),
                                  ],
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

  String _getInitials(String responsable) {
    if (responsable.isEmpty) return '?';
    if (responsable.length == 1) return responsable[0];
    return responsable[0] + responsable[1];
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text, [Color? color]) {
    return PopupMenuItem<String>(value: value, child: ListTile(leading: Icon(icon, color: color ?? Colors.black, size: 16), title: Text(text)));
  }
}
