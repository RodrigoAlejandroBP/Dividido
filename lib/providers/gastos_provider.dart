import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gestor_gastos/models/gasto_model.dart';

class GastosProvider extends ChangeNotifier {
  final Box<Gasto> _gastosBox = Hive.box<Gasto>('gastosBox');
  final Box _syncQueue = Hive.box('syncQueue');
  final List<String> _responsables = [];
  final _supabase = Supabase.instance.client;

  GastosProvider() {
    _agregarDatosBase();
    _sincronizarConSupabase();
  }

  List<Gasto> get gastos => _gastosBox.values.toList();
  List<String> get responsables => _responsables;

  void _agregarDatosBase() {
    if (_gastosBox.isEmpty) {
      agregarGasto(Gasto(
        precio: 1000.0,
        fecha: DateTime(2025, 2, 15),
        responsable: 'Ana',
        subGastos: [],
        etiquetas: [],
      ));
      agregarSubGasto(0, SubGasto(precio: 600.0, responsable: 'Ana', descripcion: 'Comida', esIndividual: true));
      agregarSubGasto(0, SubGasto(precio: 400.0, responsable: 'Ana', descripcion: 'Transporte', esIndividual: true));

      agregarGasto(Gasto(
        precio: 500.0,
        fecha: DateTime(2025, 3, 10),
        responsable: 'Juan',
        subGastos: [],
        etiquetas: [],
      ));
      agregarSubGasto(1, SubGasto(precio: 300.0, responsable: 'Juan', descripcion: 'Materiales', esIndividual: true));
      agregarSubGasto(1, SubGasto(precio: 200.0, responsable: 'Juan', descripcion: 'Otros', esIndividual: true));

      agregarGasto(Gasto(
        precio: 1200.0,
        fecha: DateTime(2025, 4, 1),
        responsable: 'Ana',
        subGastos: [],
        etiquetas: [],
      ));
      agregarSubGasto(2, SubGasto(precio: 600.0, responsable: 'Ana', descripcion: 'Alquiler', esIndividual: false));
      agregarSubGasto(2, SubGasto(precio: 300.0, responsable: 'Juan', descripcion: 'Servicios', esIndividual: false));

      _responsables.addAll(['Ana', 'Juan']);
    }
  }
  extension on Gasto {
    Map<String, dynamic> toJson() => {
          'id': id,
          'nombre': nombre,
          'precio': precio,
          'fecha': fecha.toIso8601String(),
          'responsable': responsable,
          'subGastos': subGastos?.map((s) => s.toJson()).toList(),
          'etiquetas': etiquetas,
          'key': key,
        };
  }

  extension on SubGasto {
    Map<String, dynamic> toJson() => {
          'id': id,
          'descripcion': descripcion,
          'precio': precio,
          'esIndividual': esIndividual,
          'responsable': responsable,
          'key': key,
        };
  }

  void agregarGasto(Gasto gasto) async {
    final nuevoGasto = gasto..subGastos = gasto.subGastos ?? [];
    await _gastosBox.add(nuevoGasto);
    await _queueSyncOperation('INSERT', 'gastos', nuevoGasto);
    notifyListeners();
  }

  void editarGasto(int index, Gasto gastoEditado) async {
    final gasto = _gastosBox.getAt(index)!;
    gasto
      ..nombre = gastoEditado.nombre
      ..precio = gastoEditado.precio
      ..fecha = gastoEditado.fecha
      ..responsable = gastoEditado.responsable
      ..etiquetas = gastoEditado.etiquetas;
    await gasto.save();
    await _queueSyncOperation('UPDATE', 'gastos', gasto);
    notifyListeners();
  }

  void eliminarGasto(int index) async {
    final gasto = _gastosBox.getAt(index)!;
    await _queueSyncOperation('DELETE', 'gastos', gasto);
    await _gastosBox.deleteAt(index);
    notifyListeners();
  }

  void agregarSubGasto(int gastoIndex, SubGasto subGasto) async {
    final gasto = _gastosBox.getAt(gastoIndex)!;
    gasto.subGastos!.add(subGasto);
    await gasto.save();
    await _queueSyncOperation('INSERT', 'subgastos', subGasto, parentId: gasto.id);
    notifyListeners();
  }

  void eliminarSubGasto(int gastoIndex, int subGastoIndex) async {
    final gasto = _gastosBox.getAt(gastoIndex)!;
    final subGasto = gasto.subGastos![subGastoIndex];
    await _queueSyncOperation('DELETE', 'subgastos', subGasto, parentId: gasto.id);
    gasto.subGastos!.removeAt(subGastoIndex);
    await gasto.save();
    notifyListeners();
  }

  void editarSubGasto(int gastoIndex, int subGastoIndex, SubGasto subGastoEditado) async {
    final gasto = _gastosBox.getAt(gastoIndex)!;
    final subGasto = gasto.subGastos![subGastoIndex];
    subGasto
      ..descripcion = subGastoEditado.descripcion
      ..precio = subGastoEditado.precio
      ..esIndividual = subGastoEditado.esIndividual
      ..responsable = subGastoEditado.responsable;
    await gasto.save();
    await _queueSyncOperation('UPDATE', 'subgastos', subGasto, parentId: gasto.id);
    notifyListeners();
  }

  void agregarResponsable(String responsable) {
    if (!_responsables.contains(responsable)) {
      _responsables.add(responsable);
      notifyListeners();
    }
  }

  Map<String, double> calcularTotalPorResponsable(Gasto gasto) {
    Set<String> responsables = {gasto.responsable ?? 'Desconocido'};
    double totalPrecio = gasto.precio;
    double totalGastoComun = totalPrecio;
    Map<String, double> gastosIndividuales = {};

    gastosIndividuales[gasto.responsable ?? 'Desconocido'] = 0.0;

    final subGastos = gasto.subGastos ?? [];
    for (var subGasto in subGastos) {
      String responsableSubGasto = subGasto.responsable ?? 'Desconocido';
      double precio = subGasto.precio;
      bool esIndividual = subGasto.esIndividual ?? false;

      responsables.add(responsableSubGasto);

      if (esIndividual) {
        gastosIndividuales[responsableSubGasto] = (gastosIndividuales[responsableSubGasto] ?? 0) + precio;
        totalGastoComun -= precio;
      } else {
        double precioPorResponsable = precio / responsables.length;
        for (var responsable in responsables) {
          gastosIndividuales[responsable] = (gastosIndividuales[responsable] ?? 0) + precioPorResponsable;
        }
        totalGastoComun -= precio;
      }
    }

    double gastoComunPorPersona = (responsables.isNotEmpty && totalGastoComun > 0) ? totalGastoComun / responsables.length : 0.0;
    Map<String, double> totalPorResponsable = {};
    for (var responsable in responsables) {
      totalPorResponsable[responsable] = (gastosIndividuales[responsable] ?? 0) + gastoComunPorPersona;
    }

    return totalPorResponsable;
  }

  Future<void> _queueSyncOperation(String operation, String table, dynamic data, {String? parentId}) async {
    final syncData = {
      'operation': operation,
      'table': table,
      'data': data.toJson(),
      'parentId': parentId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _syncQueue.add(syncData);
    _sincronizarConSupabase();
  }

  Future<void> _sincronizarConSupabase() async {
    try {
      if (_syncQueue.isEmpty) return;

      final operations = _syncQueue.values.toList();
      for (var op in operations) {
        final table = op['table'] as String;
        final data = op['data'] as Map<String, dynamic>;
        final operation = op['operation'] as String;

        if (table == 'gastos') {
          if (operation == 'INSERT') {
            final response = await _supabase.from('gastos').insert(data).select().single();
            final gasto = _gastosBox.values.firstWhere((g) => g.key == data['key']);
            gasto.id = response['id'].toString();
            await gasto.save();
          } else if (operation == 'UPDATE') {
            await _supabase.from('gastos').update(data).eq('id', data['id']);
          } else if (operation == 'DELETE') {
            await _supabase.from('gastos').delete().eq('id', data['id']);
          }
        } else if (table == 'subgastos') {
          if (operation == 'INSERT') {
            data['gasto_id'] = op['parentId'];
            final response = await _supabase.from('subgastos').insert(data).select().single();
            final gasto = _gastosBox.values.firstWhere((g) => g.id == op['parentId']);
            final subGasto = gasto.subGastos!.firstWhere((s) => s.key == data['key']);
            subGasto.id = response['id'].toString();
            await gasto.save();
          } else if (operation == 'UPDATE') {
            await _supabase.from('subgastos').update(data).eq('id', data['id']);
          } else if (operation == 'DELETE') {
            await _supabase.from('subgastos').delete().eq('id', data['id']);
          }
        }
        await _syncQueue.delete(op.key);
      }
    } catch (e) {
      print('Error sincronizando con Supabase: $e');
    }
  }
}

extension on Gasto {
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'precio': precio,
        'fecha': fecha.toIso8601String(),
        'responsable': responsable,
        'key': key,
        'etiquetas': etiquetas,
      };
}

extension on SubGasto {
  Map<String, dynamic> toJson() => {
        'id': id,
        'descripcion': descripcion,
        'precio': precio,
        'esIndividual': esIndividual,
        'responsable': responsable,
        'key': key,
      };
}

extension on Gasto {
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'precio': precio,
        'fecha': fecha.toIso8601String(),
        'responsable': responsable,
        'subGastos': subGastos?.map((s) => s.toJson()).toList(),
        'etiquetas': etiquetas,
        'key': key,
      };
}

extension on SubGasto {
  Map<String, dynamic> toJson() => {
        'id': id,
        'descripcion': descripcion,
        'precio': precio,
        'esIndividual': esIndividual,
        'responsable': responsable,
        'key': key,
      };
}
