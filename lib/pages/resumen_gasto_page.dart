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
  Map<int, bool> subgastosIndividuales = {};
  Map<String, bool> mostrarTodos = {}; // Controla el despliegue de subgastos

  void eliminarSubGasto(String responsable, Map<String, dynamic> subGasto) {
    setState(() {
      widget.gasto['subGastos'].remove(subGasto);
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<String> responsables = {};
    double totalPrecio = double.parse(widget.gasto['precio'].toString());
    double totalGastoComun = totalPrecio;
    Map<String, double> gastosIndividuales = {};
    Map<String, List<Map<String, dynamic>>> subgastosPorResponsable = {};

    for (var i = 0; i < widget.gasto['subGastos'].length; i++) {
      var subGasto = widget.gasto['subGastos'][i];
      String responsable = subGasto['responsable'];
      double precio = double.parse(subGasto['precio'].toString());
      bool esIndividual = subgastosIndividuales[i] ?? false;
      responsables.add(responsable);
      subgastosPorResponsable.putIfAbsent(responsable, () => []);
      subgastosPorResponsable[responsable]!.add(subGasto);

      if (esIndividual) {
        gastosIndividuales[responsable] = (gastosIndividuales[responsable] ?? 0) + precio;
        totalGastoComun -= precio;
      }
    }

    double gastoComunPorPersona = (responsables.isNotEmpty && totalGastoComun > 0) ? totalGastoComun / responsables.length : 0.0;

    Map<String, double> totalPorResponsable = {};
    for (var responsable in responsables) {
      totalPorResponsable[responsable] = (gastosIndividuales[responsable] ?? 0) + gastoComunPorPersona;
    }

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
                children:
                    totalPorResponsable.entries.map<Widget>((entry) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[300],
                            child: Text(entry.key[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Total: \$${entry.value.toStringAsFixed(2)}'),
                          children:
                              subgastosPorResponsable[entry.key]?.map((subgasto) {
                                return ListTile(
                                  title: Text(subgasto['nombre'] ?? 'Sin Detalle', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text.rich(
                                    TextSpan(
                                      children: [
                                        // TextSpan(
                                        //   text: '${subgasto['responsable']}',
                                        //   style: const TextStyle(fontWeight: FontWeight.bold), // Negrita para el responsable
                                        // ),
                                        const TextSpan(text: ' • '),
                                        TextSpan(text: 'Monto: \$${subgasto['precio'] ?? 0.0}'),
                                      ],
                                    ),
                                  ),
                                  trailing: Checkbox(
                                    value: subgastosIndividuales[widget.gasto['subGastos'].indexOf(subgasto)] ?? false,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        subgastosIndividuales[widget.gasto['subGastos'].indexOf(subgasto)] = value ?? false;
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
      ),
    );
  }
}
