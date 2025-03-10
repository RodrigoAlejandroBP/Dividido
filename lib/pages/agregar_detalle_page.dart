import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';

class AgregarDetallePage extends StatefulWidget {
  final Map<String, dynamic>? gastoExistente;
  final int? gastoIndex;
  final bool esSubGasto;
  final List<String> responsables;
  final Function(String) onAgregarResponsable;

  const AgregarDetallePage({
    super.key,
    this.gastoExistente,
    this.gastoIndex,
    this.esSubGasto = false,
    required this.responsables,
    required this.onAgregarResponsable,
  });

  @override
  _AgregarDetallePageState createState() => _AgregarDetallePageState();
}

class _AgregarDetallePageState extends State<AgregarDetallePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  String? responsable;
  String? _errorMensaje;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.gastoExistente?['nombre'] ?? '');
    _precioController = TextEditingController(text: widget.gastoExistente?['precio']?.toString() ?? '');
    responsable = widget.gastoExistente?['responsable'];
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  void _validarYGuardar(BuildContext context) {
    final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
    final double precioIngresado = double.tryParse(_precioController.text) ?? 0.0;

    if (widget.esSubGasto && widget.gastoIndex != null) {
      final gastoPadre = gastosProvider.gastos[widget.gastoIndex!];
      final double totalSubGastos =
          gastoPadre['subGastos'].fold<double>(0.0, (double sum, dynamic item) => sum + ((item['precio'] ?? 0.0).toDouble())) + precioIngresado;

      final double totalGastoPrincipal = gastoPadre['precio'] ?? 0.0;

      if (totalSubGastos > totalGastoPrincipal) {
        setState(() {
          _errorMensaje = 'El total de subgastos no puede superar el gasto principal (\$${totalGastoPrincipal.toStringAsFixed(2)})';
        });
        return;
      }
    }

    if (_formKey.currentState!.validate() && responsable != null) {
      Map<String, dynamic> nuevoGasto = {
        'nombre': _nombreController.text,
        'precio': precioIngresado,
        'responsable': responsable ?? gastosProvider.gastos[widget.gastoIndex!]['responsable'],
      };

      if (widget.esSubGasto && widget.gastoIndex != null) {
        gastosProvider.agregarSubGasto(widget.gastoIndex!, nuevoGasto);
      } else if (widget.gastoExistente != null && widget.gastoIndex != null) {
        gastosProvider.editarGasto(widget.gastoIndex!, nuevoGasto);
      } else {
        gastosProvider.agregarGasto(nuevoGasto);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.esSubGasto
              ? 'Agregar Subgasto'
              : widget.gastoExistente != null
              ? 'Editar Gasto'
              : 'Agregar Gasto',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(labelText: 'Precio', errorText: _errorMensaje),
                keyboardType: TextInputType.number,
                validator: (value) => (value!.isEmpty || double.tryParse(value) == null) ? 'Ingrese un número válido' : null,
              ),
              DropdownButtonFormField<String>(
                value: responsable,
                items: [
                  ...widget.responsables.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                  const DropdownMenuItem(value: 'nuevo', child: Text('➕ Agregar Nuevo Responsable')),
                ],
                onChanged: (value) {
                  if (value == 'nuevo') {
                    _mostrarDialogoNuevoResponsable(context);
                  } else {
                    setState(() {
                      responsable = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Responsable'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => _validarYGuardar(context), child: Text(widget.esSubGasto ? 'Guardar Subgasto' : 'Guardar Gasto')),
            ],
          ),
        ),
      ),
    );
  }
void _mostrarDialogoNuevoResponsable(BuildContext context) {
  TextEditingController controller = TextEditingController();
  List<String> responsablesFiltrados = List.from(widget.responsables);

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Seleccionar o Agregar Responsable'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Buscar o Crear Responsable',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (query) {
                      setStateDialog(() {
                        responsablesFiltrados = widget.responsables
                            .where((responsable) => responsable
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: responsablesFiltrados.isNotEmpty
                        ? ListView.builder(
                            itemCount: responsablesFiltrados.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(responsablesFiltrados[index]),
                                onTap: () {
                                  setState(() {
                                    responsable = responsablesFiltrados[index];
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          )
                        : const Center(child: Text('No hay resultados')),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    // 🔥 Add the new responsible person
                    widget.onAgregarResponsable(controller.text);

                    // 🔥 Ensure "nuevo" is NEVER the selected value
                    setState(() {
                      responsable = controller.text;
                    });

                    // 🔥 Force UI update in parent widget
                    Navigator.pop(context);
                    Future.delayed(Duration(milliseconds: 100), () {
                      setState(() {}); // Refresh UI to reflect new responsible person
                    });
                  }
                },
                child: const Text('Agregar y Asignar'),
              ),
            ],
          );
        },
      );
    },
  );
}

}
