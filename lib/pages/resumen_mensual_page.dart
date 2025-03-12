import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';
import 'package:intl/intl.dart';

class ResumenMensualPage extends StatefulWidget {
  const ResumenMensualPage({super.key});

  @override
  _ResumenMensualPageState createState() => _ResumenMensualPageState();
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
                                .map(
                                  (month) => DropdownMenuItem(value: month, child: Text(DateFormat('MMMM', 'es').format(DateTime(2023, month)))),
                                )
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
                                .map(
                                  (month) => DropdownMenuItem(value: month, child: Text(DateFormat('MMMM', 'es').format(DateTime(2023, month)))),
                                )
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
    final gastos = gastosProvider.gastos;
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
    Map<String, List<Map<String, dynamic>>> gastosPorMes = {};
    for (var gasto in gastos) {
      final fecha = gasto['fecha'] as DateTime;
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
    List<Map<String, dynamic>> gastosDelRango = [];
    if (startKey != null && endKey != null) {
      final startDate = _startDate!;
      final endDate = _endDate!;
      gastosPorMes.forEach((mesAnio, listaGastos) {
        final partes = mesAnio.split('/');
        final mes = int.parse(partes[0]);
        final anio = int.parse(partes[1]);
        final fechaMes = DateTime(anio, mes);
        if (fechaMes.isAfter(startDate.subtract(const Duration(days: 1))) && fechaMes.isBefore(endDate.add(const Duration(days: 1)))) {
          gastosDelRango.addAll(listaGastos);
        }
      });
    }

    double totalRango = 0.0;
    Map<String, double> totalPorResponsableConsolidado = {};
    Map<String, List<Map<String, dynamic>>> subgastosPorResponsable = {};
    Set<String> todosResponsables = {};
    for (var gasto in gastosDelRango) {
      totalRango += double.parse(gasto['precio'].toString());
      Map<String, double> totalPorResponsable = gastosProvider.calcularTotalPorResponsable(gasto);
      totalPorResponsable.forEach((responsable, monto) {
        totalPorResponsableConsolidado[responsable] = (totalPorResponsableConsolidado[responsable] ?? 0) + monto;
        todosResponsables.add(responsable);
        subgastosPorResponsable.putIfAbsent(responsable, () => []);
        final subgastos = (gasto['subGastos'] as List<dynamic>?)?.map((item) => item as Map<String, dynamic>).toList() ?? [];
        for (var subgasto in subgastos) {
          subgastosPorResponsable[responsable]!.add({
            'descripcion': subgasto['descripcion'] ?? 'Sin descripción',
            'monto': subgasto['precio'] ?? 0.0,
            'fecha': gasto['fecha'],
          });
        }
      });
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
                        .map(
                          (e) => PieChartSectionData(
                            value: e.value,
                            title: '${e.key[0]}\n\$${e.value.toStringAsFixed(2)}',
                            color: _getColorForResponsable(e.key),
                            radius: 60,
                            titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        )
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
                  final subgastos = subgastosPorResponsable[responsable] ?? [];
                  return ExpansionTile(
                    key: Key('responsable-$responsable'), // Añadido aquí
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[300],
                      child: Text(responsable.isNotEmpty ? responsable[0] : '?', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(responsable),
                    subtitle: Text('Total: \$${total.toStringAsFixed(2)}'),
                    children: subgastos.isNotEmpty
                        ? subgastos.map((subgasto) {
                            return ListTile(
                              title: Text(subgasto['descripcion'] as String? ?? 'Sin descripción'),
                              subtitle: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(subgasto['fecha'] as DateTime)}'),
                              trailing: Text('\$${subgasto['monto'].toStringAsFixed(2)}'),
                            );
                          }).toList()
                        : [const ListTile(title: Text('No hay subgastos disponibles'))],
                  );
                }).toList(),
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