import 'package:flutter/material.dart';
import 'package:gestor_gastos/widgets/menu_opciones.dart';
import 'package:gestor_gastos/widgets/subgasto_item.dart';
import 'package:gestor_gastos/models/gasto_model.dart';

class GastoItem extends StatelessWidget {
  final Gasto gasto;
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
    // Aseguramos que subGastos sea una lista de SubGasto
    List<SubGasto> subGastos = gasto.subGastos?.cast<SubGasto>() ?? [];

    return Card(
      elevation: 4,
      color: Colors.orange[50],
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            gasto.responsable != null && gasto.responsable!.length >= 2
                ? gasto.responsable!.substring(0, 2)
                : gasto.responsable ?? '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(gasto.nombre ?? 'Sin Nombre',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${gasto.responsable ?? 'Desconocido'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' • '),
              TextSpan(text: 'Monto: \$${gasto.precio}'),
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
            ? subGastos.asMap().entries.map((entry) {
                int subGastoIndex = entry.key;
                SubGasto subgasto = entry.value; // Ahora es seguro que es SubGasto
                return SubGastoItem(
                  subgasto: subgasto,
                  gastoIndex: index,
                  subGastoIndex: subGastoIndex,
                );
              }).toList()
            : [const ListTile(title: Text('No hay subgastos'))],
      ),
    );
  }
}