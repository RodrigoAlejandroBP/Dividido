import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';
import 'package:gestor_gastos/models/gasto_model.dart';
import 'package:intl/intl.dart';

class ResumenMensualPage extends StatefulWidget {
  const ResumenMensualPage({super.key});

  @override
  State<ResumenMensualPage> createState() => _ResumenMensualPageState();
}

class _ResumenMensualPageState extends State<ResumenMensualPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  Set<String> _selectedResponsables = {};

  String _formatMesAnio(DateTime? date) {
    if (date == null) return 'Selecciona un mes';
    return DateFormat('MMMM yyyy', 'es').format(date);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTime? selectedStartDate = _startDate;
    DateTime? selectedEndDate = _endDate;
    final now = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Selecciona rango de meses'),
              content: SizedBox(
                width: 300,
                height: 250,
                child: Column(
                  children: [
                    const Text('Inicio:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedStartDate?.year ?? now.year,
                            items: List.generate(
                              101,
                              (index) => 2000 + index,
                            ).map((year) => DropdownMenuItem(value: year, child: Text('$year'))).toList(),
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedStartDate = DateTime(value!, selectedStartDate?.month ?? 1);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedStartDate?.month ?? now.month,
                            items: List.generate(12, (index) => index + 1)
                                .map((month) => DropdownMenuItem(value: month, child: Text(DateFormat('MMMM', 'es').format(DateTime(2023, month)))))
                                .toList(),
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedStartDate = DateTime(selectedStartDate?.year ?? now.year, value!);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Fin:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedEndDate?.year ?? now.year,
                            items: List.generate(
                              101,
                              (index) => 2000 + index,
                            ).map((year) => DropdownMenuItem(value: year, child: Text('$year'))).toList(),
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedEndDate = DateTime(value!, selectedEndDate?.month ?? 1);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedEndDate?.month ?? now.month,
                            items: List.generate(12, (index) => index + 1)
                                .map((month) => DropdownMenuItem(value: month, child: Text(DateFormat('MMMM', 'es').format(DateTime(2023, month)))))
                                .toList(),
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedEndDate = DateTime(selectedEndDate?.year ?? now.year, value!);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    if (selectedStartDate != null && selectedEndDate != null) {
                      if (selectedStartDate!.isAfter(selectedEndDate!)) {
                        final temp = selectedStartDate;
                        selectedStartDate = selectedEndDate;
                        selectedEndDate = temp;
                      }
                      setState(() {
                        _startDate = selectedStartDate;
                        _endDate = selectedEndDate;
                        _selectedResponsables.clear();
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gastosProvider = Provider.of<GastosProvider>(context);
    final List<Gasto> gastos = gastosProvider.gastos.cast<Gasto>();
    final bool hayGastos = gastos.isNotEmpty;

    if (!hayGastos) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resumen Mensual')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Rango: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Selecciona un rango', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                          const Icon(Icons.calendar_today, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Center(child: Text('No hay gastos registrados aún.', style: TextStyle(fontSize: 18, color: Colors.grey))),
            ],
          ),
        ),
      );
    }

    // Agrupar gastos por mes
    Map<String, List<Gasto>> gastosPorMes = {};
    for (var gasto in gastos) {
      final fecha = gasto.fecha;
      final mesAnio = DateFormat('M/yyyy').format(fecha);
      gastosPorMes.putIfAbsent(mesAnio, () => []).add(gasto);
    }

    // Inicializar fechas si no están seleccionadas
    if (_startDate == null && gastosPorMes.isNotEmpty) {
      final ultimoMes = gastosPorMes.keys.toList()..sort((a, b) => b.compareTo(a));
      final partes = ultimoMes.first.split('/');
      _startDate = DateTime(int.parse(partes[1]), int.parse(partes[0]));
      _endDate = _startDate;
    }

    // Filtrar gastos por rango de fechas
    final startKey = _startDate != null ? DateFormat('M/yyyy').format(_startDate!) : null;
    final endKey = _endDate != null ? DateFormat('M/yyyy').format(_endDate!) : null;
    List<Gasto> gastosDelRango = [];
    if (startKey != null && endKey != null) {
      final startDate = _startDate!;
      final endDate = _endDate!;
      gastosPorMes.forEach((mesAnio, listaGastos) {
        final partes = mesAnio.split('/');
        final mes = int.parse(partes[0]);
        final anio = int.parse(partes[1]);
        final fechaMes = DateTime(anio, mes);
        if (fechaMes.isAfter(startDate.subtract(const Duration(days: 1))) && fechaMes.isBefore(endDate.add(const Duration(days: 1)))) {
          gastosDelRango.addAll(listaGastos.cast<Gasto>());
        }
      });
    }

    double totalRango = 0.0;
    Map<String, double> totalPorResponsableConsolidado = {};
    Map<String, Map<Gasto, List<Map<String, dynamic>>>> subgastosPorResponsable = {};
    Set<String> todosResponsables = {};
    Map<String, double> montoRealmentePagado = {};

    for (var gasto in gastosDelRango) {
      totalRango += gasto.precio;
      Map<String, double> totalPorResponsable = gastosProvider.calcularTotalPorResponsable(gasto);
      final subgastos = gasto.subGastos ?? [];
      Set<String> responsablesDelGasto = totalPorResponsable.keys.toSet();

      // Calcular cuánto pagó cada responsable realmente (según subgastos)
      for (var subgasto in subgastos) {
        String responsableSubgasto = subgasto.responsable ?? gasto.responsable ?? 'Desconocido';
        montoRealmentePagado[responsableSubgasto] = (montoRealmentePagado[responsableSubgasto] ?? 0) + subgasto.precio;
      }
      // Calcular el resto del gasto principal
      double totalSubgastos = subgastos.fold(0.0, (sum, subgasto) => sum + subgasto.precio);
      double restoGastoPrincipal = gasto.precio - totalSubgastos;
      if (restoGastoPrincipal > 0) {
        String responsablePrincipal = gasto.responsable ?? 'Desconocido';
        montoRealmentePagado[responsablePrincipal] = (montoRealmentePagado[responsablePrincipal] ?? 0) + restoGastoPrincipal;
      }

      // Calcular el monto que cada responsable DEBERÍA pagar (equitativamente)
      double montoEquitativoPorResponsable = gasto.precio / responsablesDelGasto.length;

      totalPorResponsable.forEach((responsable, monto) {
        // Ajustar el total consolidado para que refleje el monto equitativo
        totalPorResponsableConsolidado[responsable] = (totalPorResponsableConsolidado[responsable] ?? 0) + montoEquitativoPorResponsable;
        todosResponsables.add(responsable);
        subgastosPorResponsable.putIfAbsent(responsable, () => {});

        // Agrupar subgastos por gasto primario (limpiar primero para evitar acumulación)
        subgastosPorResponsable[responsable]![gasto] = [];

        // Agregar subgastos explícitos (todos son compartidos, se dividen equitativamente)
        for (var subgasto in subgastos) {
          double montoSubgasto = subgasto.precio / responsablesDelGasto.length;
          if (montoSubgasto > 0) {
            subgastosPorResponsable[responsable]![gasto]!.add({
              'descripcion': subgasto.descripcion ?? 'Sin descripción',
              'monto': montoSubgasto,
              'fecha': gasto.fecha,
              'esIndividual': false,
              'responsableSubgasto': subgasto.responsable ?? 'Desconocido',
              'pagadoPor': subgasto.responsable ?? 'Desconocido',
            });
          }
        }

        // Agregar el monto restante como un "subgasto implícito" si es mayor a 0
        double montoRestantePorResponsable = restoGastoPrincipal / responsablesDelGasto.length;
        if (montoRestantePorResponsable > 0) {
          subgastosPorResponsable[responsable]![gasto]!.add({
            'descripcion': 'Parte del gasto principal',
            'monto': montoRestantePorResponsable,
            'fecha': gasto.fecha,
            'esIndividual': false,
            'responsableSubgasto': 'Compartido',
            'pagadoPor': gasto.responsable ?? 'Desconocido',
          });
        }
      });
    }

    // Calcular ajustes (diferencia entre lo pagado y lo que debería pagar)
    Map<String, double> ajustes = {};
    totalPorResponsableConsolidado.forEach((responsable, montoDeberiaPagar) {
      double montoPagado = montoRealmentePagado[responsable] ?? 0;
      ajustes[responsable] = montoPagado - montoDeberiaPagar;
    });

    // Calcular saldos entre pares de personas
    List<Map<String, dynamic>> saldos = [];
    List<String> responsablesList = todosResponsables.toList();
    for (int i = 0; i < responsablesList.length; i++) {
      for (int j = i + 1; j < responsablesList.length; j++) {
        String persona1 = responsablesList[i];
        String persona2 = responsablesList[j];
        double ajuste1 = ajustes[persona1] ?? 0;
        double ajuste2 = ajustes[persona2] ?? 0;

        if (ajuste1 * ajuste2 >= 0) continue;

        double montoTransferencia = (ajuste1.abs() < ajuste2.abs()) ? ajuste1.abs() : ajuste2.abs();
        if (ajuste1 > 0 && ajuste2 < 0) {
          saldos.add({'deudor': persona2, 'acreedor': persona1, 'monto': montoTransferencia});
          ajustes[persona1] = (ajustes[persona1] ?? 0) - montoTransferencia;
          ajustes[persona2] = (ajustes[persona2] ?? 0) + montoTransferencia;
        } else if (ajuste1 < 0 && ajuste2 > 0) {
          saldos.add({'deudor': persona1, 'acreedor': persona2, 'monto': montoTransferencia});
          ajustes[persona1] = (ajustes[persona1] ?? 0) + montoTransferencia;
          ajustes[persona2] = (ajustes[persona2] ?? 0) - montoTransferencia;
        }
      }
    }

    if (_selectedResponsables.isEmpty && todosResponsables.isNotEmpty) {
      _selectedResponsables = todosResponsables;
    }

    Map<String, double> totalesFiltrados = Map.fromEntries(
      totalPorResponsableConsolidado.entries.where((entry) => _selectedResponsables.contains(entry.key)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen Mensual')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Rango: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: hayGastos ? () => _selectDateRange(context) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.orange[50],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_formatMesAnio(_startDate)} - ${_formatMesAnio(_endDate)}', style: const TextStyle(fontSize: 16)),
                          const Icon(Icons.calendar_today, color: Colors.orange),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (todosResponsables.isNotEmpty) ...[
              const Text('Filtrar por responsables:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: todosResponsables.map((responsable) {
                  return FilterChip(
                    label: Text(responsable),
                    selected: _selectedResponsables.contains(responsable),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedResponsables.add(responsable);
                        } else {
                          _selectedResponsables.remove(responsable);
                        }
                      });
                    },
                    selectedColor: Colors.orange[200],
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (totalesFiltrados.isNotEmpty)
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: totalesFiltrados.entries
                        .map((e) => PieChartSectionData(
                              value: e.value,
                              title: '${e.key[0]}\n\$${e.value.toStringAsFixed(2)}',
                              color: _getColorForResponsable(e.key),
                              radius: 60,
                              titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                            ))
                        .toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: ExpansionTile(
                title: Text(
                  'Rango: ${_formatMesAnio(_startDate)} - ${_formatMesAnio(_endDate)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Total: \$${totalRango.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                backgroundColor: Colors.orange[50],
                collapsedBackgroundColor: Colors.orange[100],
                children: totalesFiltrados.entries.map((entry) {
                  final responsable = entry.key;
                  final total = entry.value;
                  final subgastosPorGasto = subgastosPorResponsable[responsable] ?? {};
                  return ExpansionTile(
                    key: Key('responsable-$responsable'),
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[300],
                      child: Text(responsable.isNotEmpty ? responsable[0] : '?', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(responsable),
                    subtitle: Text('Total: \$${total.toStringAsFixed(2)}'),
                    children: subgastosPorGasto.entries.isNotEmpty
                        ? subgastosPorGasto.entries.map((gastoEntry) {
                            final gastoPrimario = gastoEntry.key;
                            final subgastos = gastoEntry.value;
                            return ExpansionTile(
                              title: Text(gastoPrimario.nombre ?? 'Sin nombre'),
                              subtitle: Text(
                                'Total Gasto: \$${gastoPrimario.precio.toStringAsFixed(2)} | '
                                'Responsable: ${gastoPrimario.responsable ?? 'Desconocido'}',
                              ),
                              children: subgastos.map((subgasto) {
                                return ListTile(
                                  title: Text(subgasto['descripcion'] as String? ?? 'Sin descripción'),
                                  subtitle: Text(
                                    'Fecha: ${DateFormat('dd/MM/yyyy').format(subgasto['fecha'] as DateTime)} '
                                    '(${subgasto['esIndividual'] ? 'Individual' : 'Compartido'}, ${subgasto['responsableSubgasto']})',
                                  ),
                                  trailing: Text('\$${subgasto['monto'].toStringAsFixed(2)}'),
                                );
                              }).toList(),
                            );
                          }).toList()
                        : [const ListTile(title: Text('No hay subgastos disponibles'))],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: ExpansionTile(
                title: const Text(
                  'Ajustes y Saldos Finales',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.green[50],
                collapsedBackgroundColor: Colors.green[100],
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalles de ajustes:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Responsable', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Pagado', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Debería Pagar', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Ajuste', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: todosResponsables.map((responsable) {
                              final montoPagado = montoRealmentePagado[responsable] ?? 0;
                              final montoDeberiaPagar = totalPorResponsableConsolidado[responsable] ?? 0;
                              final ajuste = ajustes[responsable] ?? 0;
                              return DataRow(
                                cells: [
                                  DataCell(Text(responsable)),
                                  DataCell(Text('\$${montoPagado.toStringAsFixed(2)}')),
                                  DataCell(Text('\$${montoDeberiaPagar.toStringAsFixed(2)}')),
                                  DataCell(Text(
                                    ajuste >= 0 ? '\$${ajuste.toStringAsFixed(2)}' : '-\$${ajuste.abs().toStringAsFixed(2)}',
                                    style: TextStyle(color: ajuste >= 0 ? Colors.green : Colors.red),
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Saldos finales:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        if (saldos.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No hay deudas pendientes. Todos están a mano.', style: TextStyle(fontStyle: FontStyle.italic)),
                          )
                        else
                          Column(
                            children: saldos.map((saldo) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4.0),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Text(
                                  '${saldo['deudor']} le debe \$${saldo['monto'].toStringAsFixed(2)} a ${saldo['acreedor']}.',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForResponsable(String responsable) {
    final colors = [Colors.blue, Colors.green, Colors.red, Colors.purple, Colors.teal, Colors.cyan, Colors.pink];
    return colors[responsable.hashCode % colors.length];
  }
}