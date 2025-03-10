import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gastos_provider.dart';

class AgregarSubGastoPage extends StatefulWidget {
  final int gastoIndex; // El índice del gasto principal al que se va a agregar el subgasto

  const AgregarSubGastoPage({super.key, required this.gastoIndex});

  @override
  _AgregarSubGastoPageState createState() => _AgregarSubGastoPageState();
}

class _AgregarSubGastoPageState extends State<AgregarSubGastoPage> {
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  String? _responsableSeleccionado;
  late List<String> responsables;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtenemos la lista de responsables del provider
    responsables = Provider.of<GastosProvider>(context).responsables;
  }

  @override
  Widget build(BuildContext context) {
    final gastosProvider = Provider.of<GastosProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Subgasto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo para el nombre del subgasto
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del Subgasto'),
            ),
            const SizedBox(height: 10),
            
            // Campo para el precio del subgasto
            TextField(
              controller: _precioController,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            
            // Dropdown para seleccionar el responsable
            DropdownButtonFormField<String>(
              value: _responsableSeleccionado,
              decoration: const InputDecoration(labelText: 'Responsable'),
              items: responsables.map((responsable) {
                return DropdownMenuItem<String>(
                  value: responsable,
                  child: Text(responsable),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _responsableSeleccionado = value;
                });
              },
              hint: const Text('Selecciona un responsable'),
            ),
            const SizedBox(height: 20),

            // Botón para guardar el subgasto
            ElevatedButton(
              onPressed: () {
                if (_nombreController.text.isNotEmpty &&
                    _precioController.text.isNotEmpty &&
                    _responsableSeleccionado != null) {
                  // Crear el subgasto
                  final subGasto = {
                    'nombre': _nombreController.text,
                    'precio': double.tryParse(_precioController.text) ?? 0.0,
                    'responsable': _responsableSeleccionado,
                  };

                  // Llamamos al método de agregar subgasto del provider
                  gastosProvider.agregarSubGasto(
                    widget.gastoIndex, // Índice del gasto principal
                    subGasto, // El subgasto creado
                  );

                  // Volver a la pantalla anterior
                  Navigator.pop(context);
                } else {
                  // Mostrar un error si falta algún campo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, completa todos los campos')),
                  );
                }
              },
              child: const Text('Guardar Subgasto'),
            ),
          ],
        ),
      ),
    );
  }
}
