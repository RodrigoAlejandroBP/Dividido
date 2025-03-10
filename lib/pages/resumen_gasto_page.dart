import 'package:flutter/material.dart';

class ResumenGastoPage extends StatefulWidget {
  final Map<String, dynamic> gasto;

  const ResumenGastoPage({super.key, required this.gasto});

  @override
  _ResumenGastoPageState createState() => _ResumenGastoPageState();
}

class _ResumenGastoPageState extends State<ResumenGastoPage> {
  Map<String, bool> subgastosIndividuales = {};
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

    for (var subGasto in widget.gasto['subGastos']) {
      String responsable = subGasto['responsable'];
      double precio = double.parse(subGasto['precio'].toString());
      bool esIndividual = subgastosIndividuales[subGasto['nombre']] ?? false;
      responsables.add(responsable);

      subgastosPorResponsable.putIfAbsent(responsable, () => []);
      subgastosPorResponsable[responsable]!.add(subGasto);

      if (esIndividual) {
        gastosIndividuales[responsable] = (gastosIndividuales[responsable] ?? 0) + precio;
        totalGastoComun -= precio;
      }
    }

    double gastoComunPorPersona = responsables.isNotEmpty ? totalGastoComun / responsables.length : 0.0;
    Map<String, double> totalPorResponsable = {};

    for (var responsable in responsables) {
      totalPorResponsable[responsable] = gastoComunPorPersona + (gastosIndividuales[responsable] ?? 0);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen del Gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Gasto Principal: ${widget.gasto['nombre']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Precio Total: \$${totalPrecio.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: subgastosPorResponsable.entries.map<Widget>((entry) {
                  String responsable = entry.key;
                  List<Map<String, dynamic>> subgastos = entry.value;
                  bool mostrar = mostrarTodos[responsable] ?? false;

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Responsable: $responsable', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Column(
                            children: List.generate(
                              mostrar || subgastos.length <= 1 ? subgastos.length : 1,
                              (index) {
                                var subGasto = subgastos[index];
                                String nombre = subGasto['nombre'];
                                double precio = double.parse(subGasto['precio'].toString());
                                bool esIndividual = subgastosIndividuales[nombre] ?? false;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Subgasto: \$${precio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => eliminarSubGasto(responsable, subGasto),
                                        ),
                                      ],
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Es Gasto Individual'),
                                      value: esIndividual,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          subgastosIndividuales[nombre] = value ?? false;
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          if (subgastos.length > 1)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  mostrarTodos[responsable] = !mostrar;
                                });
                              },
                              child: Text(mostrar ? 'Ver menos' : 'Ver más'),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Column(
              children: totalPorResponsable.entries.map<Widget>((entry) {
                return Card(
                  color: Colors.orange[50],
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Total Asignado a ${entry.key}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                        Text('\$${entry.value.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}