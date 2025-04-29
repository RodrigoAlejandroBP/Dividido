import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';
import 'package:gestor_gastos/models/gasto_model.dart';

class AgregarDetallePage extends StatefulWidget {
  final dynamic gastoExistente; // Puede ser Gasto o SubGasto
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
  State<AgregarDetallePage> createState() => AgregarDetallePageState();
}

class AgregarDetallePageState extends State<AgregarDetallePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _etiquetasController;
  String? responsable;
  String? _errorMensaje;
  int? _subGastoIndex;
  double? _montoDisponible;
  DateTime? _fechaSeleccionada;
  bool _esIndividual = false;

  @override
  void initState() {
    super.initState();
    if (widget.esSubGasto && widget.gastoExistente is SubGasto) {
      final subGasto = widget.gastoExistente as SubGasto;
      _nombreController = TextEditingController(text: subGasto.descripcion ?? '');
      _precioController = TextEditingController(text: subGasto.precio.toString());
      _esIndividual = subGasto.esIndividual ?? false;
      responsable = subGasto.responsable ?? widget.responsables.firstOrNull;
    } else {
      final gasto = widget.gastoExistente as Gasto?;
      _nombreController = TextEditingController(text: gasto?.nombre ?? '');
      _precioController = TextEditingController(text: gasto?.precio.toString() ?? '');
      _etiquetasController = TextEditingController(text: gasto?.etiquetas?.join(', ') ?? '');
      _fechaSeleccionada = gasto?.fecha ?? DateTime.now();
      responsable = gasto?.responsable ?? widget.responsables.firstOrNull;
    }

    // Validar que responsable esté en widget.responsables
    if (responsable != null && !widget.responsables.contains(responsable)) {
      responsable = widget.responsables.isNotEmpty ? widget.responsables.first : null;
    }

    _subGastoIndex = widget.gastoIndex;
    _calcularMontoDisponible();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _etiquetasController.dispose();
    super.dispose();
  }

  void _calcularMontoDisponible() {
    if (widget.esSubGasto && widget.gastoIndex != null) {
      final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
      final gastoPadre = gastosProvider.gastos[widget.gastoIndex!];
      double totalSubGastos = 0.0;

      for (var subGasto in gastoPadre.subGastos ?? []) {
        if (subGasto.key != _subGastoIndex) {
          totalSubGastos += subGasto.precio;
        }
      }

      setState(() {
        _montoDisponible = gastoPadre.precio - totalSubGastos;
      });
    }
  }

  void _validarYGuardar(BuildContext context) {
    final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
    final double precioIngresado = double.tryParse(_precioController.text) ?? 0.0;

    if (widget.esSubGasto && precioIngresado <= 0) {
      setState(() {
        _errorMensaje = 'El precio del subgasto debe ser mayor a 0';
      });
      return;
    }

    if (widget.esSubGasto && widget.gastoIndex != null) {
      final gastoPadre = gastosProvider.gastos[widget.gastoIndex!];
      double totalSubGastos = 0.0;

      for (var subGasto in gastoPadre.subGastos ?? []) {
        if (subGasto.key != _subGastoIndex) {
          totalSubGastos += subGasto.precio;
        }
      }
      totalSubGastos += precioIngresado;

      if (totalSubGastos > gastoPadre.precio) {
        setState(() {
          _errorMensaje =
              'El total de subgastos no puede superar el gasto principal (\$${gastoPadre.precio.toStringAsFixed(2)})';
        });
        return;
      }
    }

    if (_formKey.currentState!.validate() && responsable != null) {
      if (widget.esSubGasto) {
        final nuevoSubGasto = SubGasto(
          descripcion: _nombreController.text,
          precio: precioIngresado,
          esIndividual: _esIndividual,
          responsable: responsable!,
        );
        if (widget.gastoIndex != null) {
          if (_subGastoIndex != null) {
            gastosProvider.editarSubGasto(widget.gastoIndex!, _subGastoIndex!, nuevoSubGasto);
          } else {
            gastosProvider.agregarSubGasto(widget.gastoIndex!, nuevoSubGasto);
          }
        }
      } else {
        final nuevoGasto = Gasto(
          nombre: _nombreController.text,
          precio: precioIngresado,
          fecha: _fechaSeleccionada!,
          responsable: responsable!,
          subGastos: widget.gastoExistente?.subGastos ?? [],
          etiquetas: _etiquetasController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        );
        if (widget.gastoExistente != null && widget.gastoIndex != null) {
          gastosProvider.editarGasto(widget.gastoIndex!, nuevoGasto);
        } else {
          gastosProvider.agregarGasto(nuevoGasto);
        }
      }
      Navigator.pop(context);
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Asegurarse de que los responsables sean únicos
    final uniqueResponsables = widget.responsables.toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.esSubGasto
              ? (_subGastoIndex != null ? 'Editar Subgasto' : 'Agregar Subgasto')
              : widget.gastoExistente != null
                  ? 'Editar Gasto'
                  : 'Agregar Gasto',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (widget.esSubGasto && _montoDisponible != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Monto disponible: \$${_montoDisponible!.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: _montoDisponible! < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                TextFormField(
                  controller: _nombreController,
                  decoration:
                      InputDecoration(labelText: widget.esSubGasto ? 'Descripción' : 'Nombre'),
                  validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                ),
                TextFormField(
                  controller: _precioController,
                  decoration: InputDecoration(labelText: 'Precio', errorText: _errorMensaje),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      (value!.isEmpty || double.tryParse(value) == null) ? 'Ingrese un número válido' : null,
                  onChanged: (value) => _calcularMontoDisponible(),
                ),
                if (!widget.esSubGasto)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Fecha: ${_fechaSeleccionada != null ? "${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}" : "No seleccionada"}',
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () => _seleccionarFecha(context),
                            child: const Text('Seleccionar Fecha')),
                      ],
                    ),
                  ),
                if (!widget.esSubGasto)
                  TextFormField(
                    controller: _etiquetasController,
                    decoration: const InputDecoration(
                        labelText: 'Etiquetas (separadas por comas)',
                        hintText: 'Ej: Comida, Transporte'),
                  ),
                DropdownButtonFormField<String>(
                  value: responsable,
                  items: [
                    ...uniqueResponsables
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))),
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
                  validator: (value) => value == null ? 'Seleccione un responsable' : null,
                ),
                if (widget.esSubGasto)
                  SwitchListTile(
                    title: const Text('Gasto Individual'),
                    value: _esIndividual,
                    onChanged: (value) {
                      setState(() {
                        _esIndividual = value;
                      });
                    },
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _validarYGuardar(context),
                  child: Text(widget.esSubGasto ? 'Guardar Subgasto' : 'Guardar Gasto'),
                ),
              ],
            ),
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
                          labelText: 'Buscar o Crear Responsable', prefixIcon: Icon(Icons.search)),
                      onChanged: (query) {
                        setStateDialog(() {
                          responsablesFiltrados = widget.responsables
                              .where((responsable) =>
                                  responsable.toLowerCase().contains(query.toLowerCase()))
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
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty && controller.text.length >= 2) {
                      widget.onAgregarResponsable(controller.text);
                      setState(() {
                        responsable = controller.text;
                      });
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('El nombre del responsable debe tener al menos 2 caracteres')),
                      );
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

extension FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}