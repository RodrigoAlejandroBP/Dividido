import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';
import 'package:gestor_gastos/widgets/menu_opciones.dart';
import 'package:gestor_gastos/widgets/subgasto_item.dart';

class GastoItem extends StatelessWidget {
  final Map<String, dynamic> gasto;
  final int index;
  final void Function(int) onEditarGasto;
  final void Function(int) onEliminarGasto;
  final void Function(int) onAgregarSubGasto;
  final void Function(int) onVerResumen;

  const GastoItem({
    super.key,
    required this.gasto,
    required this.index,
    required this.onEditarGasto,
    required this.onEliminarGasto,
    required this.onAgregarSubGasto,
    required this.onVerResumen,
  });

  @override
  Widget build(BuildContext context) {
    var subGastos = (gasto['subGastos'] as List).map((e) => Map<String, dynamic>.from(e)).toList();

    return Card(
      elevation: 4,
      color: Colors.orange[50],
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(gasto['responsable'][0]+gasto['responsable'][1],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(gasto['nombre'] ?? 'Sin Nombre',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${gasto['responsable']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold), // Negrita para el responsable
                                      ),
                                      const TextSpan(text: ' • '),
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
          itemBuilder: (BuildContext context) => [
            MenuOpciones.buildMenuItem('editar', Icons.edit, 'Editar'),
            MenuOpciones.buildMenuItem('eliminar', Icons.delete, 'Eliminar', Colors.red),
            MenuOpciones.buildMenuItem('agregar_subgasto', Icons.add, 'Agregar Subgasto'),
            MenuOpciones.buildMenuItem('ver_resumen', Icons.list, 'Ver Resumen'),
          ],
        ),
        children: subGastos.isNotEmpty
            ? subGastos.map((subgasto) => SubGastoItem(subgasto: subgasto, index: index)).toList()
            : [const ListTile(title: Text('No hay subgastos'))],
      ),
    );
  }
}
