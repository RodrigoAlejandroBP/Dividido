import 'package:flutter/material.dart';

class AgregarDetallePage extends StatefulWidget {
  final Function(Map<String, dynamic>) onGuardar;
  final Function()? onEliminar;
  final List<String> responsables;
  final double? gastoTotal;
  final List<Map<String, dynamic>> subGastos;
  final Map<String, dynamic>? gastoExistente;

  const AgregarDetallePage({
    super.key,
    required this.onGuardar,
    required this.responsables,
    this.onEliminar,
    this.gastoTotal,
    required this.subGastos,
    this.gastoExistente,
  });

  @override
  _AgregarDetallePageState createState() => _AgregarDetallePageState();
}

class _AgregarDetallePageState extends State<AgregarDetallePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late String? responsable;
  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.gastoExistente?['nombre'] ?? '');
    _precioController = TextEditingController(text: widget.gastoExistente?['precio']?.toString() ?? '');
    responsable = widget.gastoExistente?['responsable'];

    // Si el responsable no está en la lista, lo ponemos en null
    if (responsable != null && !widget.responsables.contains(responsable)) {
      responsable = null;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalGastado = widget.subGastos.fold(0.0, (sum, item) => sum + double.parse(item['precio'].toString()));
    double montoDisponible = widget.gastoTotal != null ? widget.gastoTotal! - totalGastado : double.infinity;

    return Scaffold(
      appBar: AppBar(title: Text(widget.gastoExistente != null ? 'Editar Gasto' : 'Agregar Gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Disponible: \$${montoDisponible.toStringAsFixed(2)}',
                style: TextStyle(color: montoDisponible < 0 ? Colors.red : Colors.black),
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(
                  labelText: 'Precio',
                  errorText: (_precioController.text.isNotEmpty &&
                          double.tryParse(_precioController.text) != null &&
                          double.parse(_precioController.text) > montoDisponible)
                      ? 'Supera el gasto total'
                      : null,
                ),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: responsable,
                items: [
                  ...widget.responsables.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                  const DropdownMenuItem(value: 'nuevo', child: Text('➕ Agregar Nuevo')),
                ],
                onChanged: (value) {
                  if (value == 'nuevo') {
                    _mostrarDialogoNuevoResponsable();
                  } else {
                    setState(() {
                      responsable = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Responsable'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.gastoExistente != null)
                    ElevatedButton(
                      onPressed: () {
                        if (widget.onEliminar != null) {
                          widget.onEliminar!();
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && responsable != null) {
                        widget.onGuardar({
                          'nombre': _nombreController.text,
                          'precio': _precioController.text,
                          'responsable': responsable,
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Guardar Gasto'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoNuevoResponsable() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Nuevo Responsable'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    widget.responsables.add(controller.text);
                    responsable = controller.text;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}
