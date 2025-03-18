import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';
import 'package:gestor_gastos/pages/agregar_detalle_page.dart';
import 'package:gestor_gastos/models/gasto_model.dart';

class SubGastoItem extends StatelessWidget {
  final SubGasto subgasto;
  final int gastoIndex;
  final int subGastoIndex;

  const SubGastoItem({super.key, required this.subgasto, required this.gastoIndex, required this.subGastoIndex});

  void _editarSubGasto(BuildContext context) {
    print('Editando subgasto en gastoIndex: $gastoIndex, subGastoIndex: $subGastoIndex');

    final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarDetallePage(
          gastoExistente: subgasto,
          gastoIndex: gastoIndex,
          esSubGasto: true,
          responsables: gastosProvider.responsables,
          onAgregarResponsable: gastosProvider.agregarResponsable,
        ),
      ),
    ).then((_) {
      gastosProvider.notifyListeners();
    });
  }

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
              onPressed: (context) => _editarSubGasto(context),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Editar',
            ),
            SlidableAction(
              onPressed: (context) {
                gastosProvider.eliminarSubGasto(gastoIndex, subGastoIndex);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Eliminar',
            ),
          ],
        ),
        child: ListTile(
          onTap: () => _editarSubGasto(context),
          tileColor: Colors.blue[50],
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              subgasto.responsable != null && subgasto.responsable!.length > 1
                  ? subgasto.responsable!.substring(0, 2)
                  : subgasto.responsable ?? '',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(subgasto.descripcion ?? 'Sin Detalle',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Monto: \$${subgasto.precio}'),
        ),
      ),
    );
  }
}