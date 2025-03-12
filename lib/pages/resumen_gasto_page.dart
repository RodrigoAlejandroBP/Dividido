import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

    Map<String, double> totalPorResponsable = gastosProvider.calcularTotalPorResponsable(widget.gasto);
    Map<String, List<Map<String, dynamic>>> subgastosPorResponsable = {};
    for (var subGasto in subGastos) {
      String responsableSubGasto = subGasto['responsable'] as String;
      subgastosPorResponsable.putIfAbsent(responsableSubGasto, () => []).add(subGasto);
    }
    subgastosPorResponsable[widget.gasto['responsable'] as String] ??= [];

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
                Text('Gasto Principal: ${widget.gasto['nombre']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Responsable: ${widget.gasto['responsable'] ?? 'Desconocido'}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                Text('Precio Total: \$${totalPrecio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.white)),
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
                    trailing: Text('\$${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    dense: true,
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
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                          onChanged: (bool? value) {
                            setState(() {
                              Map<String, dynamic> subGastoActualizado = {...subgasto, 'esIndividual': value ?? false};
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
    );
  }
}