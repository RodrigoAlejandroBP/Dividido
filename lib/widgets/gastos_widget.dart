import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        print('GastosWidget: ${gastosProvider.gastos.length} gastos cargados');
        if (gastosProvider.gastos.isEmpty) {
          return const Center(child: Text('No hay gastos registrados aún.'));
        }

        return ListView.builder(
          itemCount: gastosProvider.gastos.length,
          itemBuilder: (context, index) {
            var gasto = gastosProvider.gastos[index];
            var subGastos = (gasto['subGastos'] as List).map((e) => Map<String, dynamic>.from(e)).toList();

            return Card(
              elevation: 6,
              color: subGastos.isEmpty ? Colors.green[100] : Colors.blue[50],
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    _getInitials(gasto['responsable']),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text('Gasto de ${gasto['responsable']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Usar responsable en lugar de nombre
                subtitle: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${gasto['responsable']} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: '• '),
                      TextSpan(text: 'Monto: \$${gasto['precio'].toStringAsFixed(2)}'),
                      const TextSpan(text: ' • '),
                      TextSpan(text: 'Fecha: ${gasto['fecha'].day}/${gasto['fecha'].month}/${gasto['fecha'].year}'),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (gasto['etiquetas'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(gasto['etiquetas'][0]),
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    PopupMenuButton<String>(
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
                      itemBuilder: (BuildContext context) => [
                        _buildMenuItem('editar', Icons.edit, 'Editar'),
                        _buildMenuItem('eliminar', Icons.delete, 'Eliminar', Colors.red),
                        _buildMenuItem('agregar_subgasto', Icons.add, 'Agregar Subgasto'),
                        _buildMenuItem('ver_resumen', Icons.list, 'Ver Resumen'),
                      ],
                    ),
                  ],
                ),
                children: [
                  if (subGastos.isNotEmpty) const Divider(),
                  ...subGastos.asMap().entries.map((entry) {
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
                                  builder: (context) => AgregarDetallePage(
                                    gastoExistente: {...subgasto, 'esSubGasto': true, 'subGastoIndex': subGastoIndex},
                                    gastoIndex: index,
                                    esSubGasto: true,
                                    responsables: gastosProvider.responsables,
                                    onAgregarResponsable: gastosProvider.agregarResponsable,
                                  ),
                                ),
                              );
                            },
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Editar',
                            spacing: 2,
                            autoClose: true,
                          ),
                          SlidableAction(
                            onPressed: (context) => gastosProvider.eliminarSubGasto(index, subGastoIndex),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Eliminar',
                            spacing: 2,
                            autoClose: true,
                          ),
                        ],
                      ),
                      child: ListTile(
                        tileColor: Colors.blue[50],
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            _getInitials(subgasto['responsable']),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(subgasto['descripcion'] ?? 'Sin Detalle', style: const TextStyle(fontWeight: FontWeight.bold)), // Usar descripción en subgastos
                        subtitle: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: '${subgasto['responsable']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' • '),
                              TextSpan(text: 'Monto: \$${subgasto['precio'].toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                        trailing: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Tooltip(
                            message: esIndividual ? 'Gasto Individual' : 'Gasto Compartido',
                            child: FaIcon(
                              esIndividual ? FontAwesomeIcons.user : FontAwesomeIcons.users,
                              key: ValueKey(esIndividual),
                              color: esIndividual ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  if (subGastos.isEmpty) const ListTile(title: Text('No hay subgastos')),
                ],
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
    return PopupMenuItem<String>(
      value: value,
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.black, size: 16),
        title: Text(text),
      ),
    );
  }
}