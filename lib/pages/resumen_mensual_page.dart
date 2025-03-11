import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';

class ResumenMensualPage extends StatelessWidget {
  const ResumenMensualPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gastosProvider = Provider.of<GastosProvider>(context);
    final gastos = gastosProvider.gastos;

    // Agrupar gastos por mes
    Map<String, List<Map<String, dynamic>>> gastosPorMes = {};
    for (var gasto in gastos) {
      final fecha = gasto['fecha'] as DateTime;
      final mesAnio = '${fecha.month}/${fecha.year}';
      gastosPorMes.putIfAbsent(mesAnio, () => []).add(gasto);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen Mensual')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: gastosPorMes.entries.map((entry) {
            final mesAnio = entry.key;
            final gastosDelMes = entry.value;

            // Calcular totales del mes sumando los totales individuales
            double totalMes = 0.0;
            Map<String, double> totalPorResponsableConsolidado = {};

            for (var gasto in gastosDelMes) {
              totalMes += double.parse(gasto['precio'].toString());
              Map<String, double> totalPorResponsable = gastosProvider.calcularTotalPorResponsable(gasto);
              totalPorResponsable.forEach((responsable, monto) {
                totalPorResponsableConsolidado[responsable] = (totalPorResponsableConsolidado[responsable] ?? 0) + monto;
              });
            }

            return Card(
              elevation: 4,
              child: ExpansionTile(
                title: Text('Mes: $mesAnio', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Total: \$${totalMes.toStringAsFixed(2)}'),
                children: totalPorResponsableConsolidado.entries.map((entry) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[300],
                      child: Text(
                        entry.key.isNotEmpty ? entry.key[0] : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(entry.key),
                    subtitle: Text('Total: \$${entry.value.toStringAsFixed(2)}'),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}