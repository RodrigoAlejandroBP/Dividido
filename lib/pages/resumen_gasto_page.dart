import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';

class ResumenGastoPage extends StatefulWidget {
  final Map<String, dynamic> gasto;

  const ResumenGastoPage({super.key, required this.gasto});

  @override
  _ResumenGastoPageState createState() => _ResumenGastoPageState();
}

class _ResumenGastoPageState extends State<ResumenGastoPage> {
  @override
  Widget build(BuildContext context) {
    final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
    double totalPrecio = double.parse(widget.gasto['precio'].toString());
    final subGastos = (widget.gasto['subGastos'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    int gastoIndex = gastosProvider.gastos.indexOf(widget.gasto);

    // Calcular totales usando la función del provider
    Map<String, double> totalPorResponsable = gastosProvider.calcularTotalPorResponsable(widget.gasto);

    // Preparar subgastos por responsable para la UI
    Map<String, List<Map<String, dynamic>>> subgastosPorResponsable = {};
    for (var subGasto in subGastos) {
      String responsableSubGasto = subGasto['responsable'] as String;
      subgastosPorResponsable.putIfAbsent(responsableSubGasto, () => []).add(subGasto);
    }
    subgastosPorResponsable[widget.gasto['responsable'] as String] ??= [];

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen del Gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Gasto Principal: ${widget.gasto['nombre']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Responsable: ${widget.gasto['responsable'] ?? 'Desconocido'}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Precio Total: \$${totalPrecio.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: totalPorResponsable.entries.map<Widget>((entry) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange[300],
                        child: Text(
                          entry.key.isNotEmpty ? entry.key[0] : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Total: \$${entry.value.toStringAsFixed(2)}'),
                      children: subgastosPorResponsable[entry.key]?.map((subgasto) {
                        int subGastoIndex = subGastos.indexOf(subgasto);
                        return ListTile(
                          title: Text(subgasto['nombre'] ?? 'Sin Detalle', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: ' • '),
                                TextSpan(text: 'Monto: \$${subgasto['precio'] ?? 0.0}'),
                              ],
                            ),
                          ),
                          trailing: Checkbox(
                            value: subgasto['esIndividual'] as bool? ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                // Actualizar el estado en el subgasto
                                Map<String, dynamic> subGastoActualizado = {
                                  ...subgasto,
                                  'esIndividual': value ?? false,
                                };
                                gastosProvider.editarSubGasto(gastoIndex, subGastoIndex, subGastoActualizado);
                              });
                            },
                          ),
                        );
                      }).toList() ?? [],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}