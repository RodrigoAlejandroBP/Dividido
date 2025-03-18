import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';
import 'package:gestor_gastos/models/gasto_model.dart';

class ResumenGastoPage extends StatefulWidget {
  final Gasto gasto;

  const ResumenGastoPage({super.key, required this.gasto});

  @override
  State<ResumenGastoPage> createState() => _ResumenGastoPageState();
}

class _ResumenGastoPageState extends State<ResumenGastoPage> {
  @override
  Widget build(BuildContext context) {
    final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
    double totalPrecio = widget.gasto.precio;
    final subGastos = widget.gasto.subGastos ?? [];
    int gastoIndex = gastosProvider.gastos.indexOf(widget.gasto);

    Map<String, double> totalPorResponsable = gastosProvider.calcularTotalPorResponsable(widget.gasto);
    Map<String, List<SubGasto>> subgastosPorResponsable = {};
    for (var subGasto in subGastos) {
      String responsableSubGasto = subGasto.responsable ?? 'Desconocido';
      subgastosPorResponsable.putIfAbsent(responsableSubGasto, () => []).add(subGasto);
    }
    subgastosPorResponsable[widget.gasto.responsable ?? 'Desconocido'] ??= [];

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen del Gasto')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[300]!, Colors.orange[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gasto Principal: ${widget.gasto.nombre ?? 'Sin Nombre'}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Responsable: ${widget.gasto.responsable ?? 'Desconocido'}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70)),
                Text('Precio Total: \$${totalPrecio.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: totalPorResponsable.entries.map<Widget>((entry) {
                return Card(
                  elevation: 1,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[300],
                      child: Text(
                        entry.key.isNotEmpty ? entry.key[0] : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(entry.key),
                    trailing: Text('\$${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    dense: true,
                    children: subgastosPorResponsable[entry.key]?.map((subgasto) {
                          int subGastoIndex = subGastos.indexOf(subgasto);
                          return ListTile(
                            title: Text(subgasto.descripcion ?? 'Sin Detalle',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: ' • '),
                                  TextSpan(text: 'Monto: \$${subgasto.precio}'),
                                ],
                              ),
                            ),
                            trailing: Checkbox(
                              value: subgasto.esIndividual ?? false,
                              activeColor: Colors.green,
                              checkColor: Colors.white,
                              onChanged: (bool? value) {
                                setState(() {
                                  final subGastoActualizado = SubGasto(
                                    id: subgasto.id,
                                    descripcion: subgasto.descripcion,
                                    precio: subgasto.precio,
                                    esIndividual: value ?? false,
                                    responsable: subgasto.responsable,
                                  );
                                  gastosProvider.editarSubGasto(gastoIndex, subGastoIndex, subGastoActualizado);
                                });
                              },
                            ),
                          );
                        }).toList() ??
                        [],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}