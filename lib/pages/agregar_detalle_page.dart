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
  int? _subGastoIndex;
  double? _montoDisponible;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.gastoExistente?['nombre'] ?? '');
    _precioController = TextEditingController(text: widget.gastoExistente?['precio']?.toString() ?? '');
    responsable = widget.gastoExistente?['responsable'];
    _subGastoIndex = widget.gastoExistente?['subGastoIndex'];
    _calcularMontoDisponible();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  void _calcularMontoDisponible() {
    if (widget.esSubGasto && widget.gastoIndex != null) {
      final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
      final gastoPadre = gastosProvider.gastos[widget.gastoIndex!];
      double totalSubGastos = 0.0;

      for (int i = 0; i < gastoPadre['subGastos'].length; i++) {
        if (i != _subGastoIndex) {
          totalSubGastos += (gastoPadre['subGastos'][i]['precio'] ?? 0.0).toDouble();
        }
      }

      final double totalGastoPrincipal = gastoPadre['precio'] ?? 0.0;
      setState(() {
        _montoDisponible = totalGastoPrincipal - totalSubGastos;
      });
    }
  }

  void _validarYGuardar(BuildContext context) {
    final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
    final double precioIngresado = double.tryParse(_precioController.text) ?? 0.0;

    // Validación para subgastos: no permitir precio 0
    if (precioIngresado <= 0) {
      setState(() {
        _errorMensaje = 'El precio debe ser mayor a 0';
      });
      return;
    }

    if (widget.esSubGasto && widget.gastoIndex != null) {
      final gastoPadre = gastosProvider.gastos[widget.gastoIndex!];
      double totalSubGastos = 0.0;

      for (int i = 0; i < gastoPadre['subGastos'].length; i++) {
        if (i != _subGastoIndex) {
          totalSubGastos += (gastoPadre['subGastos'][i]['precio'] ?? 0.0).toDouble();
        }
      }
      totalSubGastos += precioIngresado;

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
        if (_subGastoIndex != null) {
          gastosProvider.editarSubGasto(widget.gastoIndex!, _subGastoIndex!, nuevoGasto);
        } else {
          gastosProvider.agregarSubGasto(widget.gastoIndex!, nuevoGasto);
        }
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
              if (widget.esSubGasto && _montoDisponible != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Monto disponible: \$${_montoDisponible!.toStringAsFixed(2)}',
                    style: TextStyle(color: _montoDisponible! < 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(labelText: 'Precio', errorText: _errorMensaje),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty || double.tryParse(value) == null) return 'Ingrese un número válido';
                  if (widget.esSubGasto && (double.tryParse(value) ?? 0) <= 0) return 'El precio debe ser mayor a 0';

                  return null;
                },
                onChanged: (value) => _calcularMontoDisponible(), // Opcional: actualizar dinámicamente
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
                      decoration: const InputDecoration(labelText: 'Buscar o Crear Responsable', prefixIcon: Icon(Icons.search)),
                      onChanged: (query) {
                        setStateDialog(() {
                          responsablesFiltrados =
                              widget.responsables.where((responsable) => responsable.toLowerCase().contains(query.toLowerCase())).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child:
                          responsablesFiltrados.isNotEmpty
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
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      widget.onAgregarResponsable(controller.text);
                      setState(() {
                        responsable = controller.text;
                      });
                      Navigator.pop(context);
                      Future.delayed(Duration(milliseconds: 100), () {
                        setState(() {});
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
