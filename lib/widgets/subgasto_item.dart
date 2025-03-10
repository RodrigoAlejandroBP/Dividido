import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';

class SubGastoItem extends StatelessWidget {
  final Map<String, dynamic> subgasto;
  final int index;

  const SubGastoItem({super.key, required this.subgasto, required this.index});

  @override
  Widget build(BuildContext context) {
    final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
    
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                // Implementar edición
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: '',
              spacing: 2,
              autoClose: true,
            ),
            SlidableAction(
              onPressed: (context) {
                gastosProvider.eliminarSubGasto(index, gastosProvider.gastos[index]['subGastos'].indexOf(subgasto));
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '',
              spacing: 2,
              autoClose: true,
            ),
          ],
        ),
        child: ListTile(
          tileColor: Colors.blue[50],
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(subgasto['responsable'][0]+subgasto['responsable'][1],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          title: Text(subgasto['nombre'] ?? 'Sin Detalle',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Monto: \$${subgasto['precio'] ?? 0.0}'),
        ),
      ),
    );
  }
}
