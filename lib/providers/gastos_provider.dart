import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gestor_gastos/models/gasto_model.dart';

class GastosProvider extends ChangeNotifier {
  final Box<Gasto> _gastosBox = Hive.box<Gasto>('gastosBox');
  final Box _syncQueue = Hive.box('syncQueue');
  final List<String> _responsables = [];
  final _supabase = Supabase.instance.client;
  bool _isInitialized = false;
  bool _baseDataAdded = false;
  String? _userId; // Almacena el ID del usuario autenticado

  GastosProvider() {
    if (_isInitialized) {
      print('GastosProvider ya inicializado, evitando reinicialización.');
      return;
    }
    try {
      print('Inicializando GastosProvider...');
      print('Estado inicial de _gastosBox: isOpen=${_gastosBox.isOpen}, length=${_gastosBox.length}');
      print('Estado inicial de _syncQueue: isOpen=${_syncQueue.isOpen}, length=${_syncQueue.length}');
      _initialize();
      _isInitialized = true;
      print('GastosProvider inicializado correctamente.');
    } catch (e, stackTrace) {
      print('Error en GastosProvider: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  List<Gasto> get gastos => _gastosBox.values.toList();
  List<String> get responsables => _responsables;

  Future<void> _initialize() async {
    // Obtiene el usuario autenticado
    _userId = _supabase.auth.currentUser?.id;
    if (_userId == null) {
      print('No hay usuario autenticado. No se inicializarán datos base.');
      return;
    }

    // Verifica si los datos base ya existen para este usuario
    final userData = await _supabase
        .from('user_data')
        .select('has_base_data')
        .eq('user_id', _userId!)
        .maybeSingle();

    if (userData != null && userData['has_base_data'] == true) {
      print('Datos base ya existen para el usuario $_userId, cargando datos...');
      await _loadExistingData();
    } else {
      print('No se encontraron datos base para el usuario $_userId, agregando datos base...');
      await _agregarDatosBase();
      // Marca que los datos base fueron agregados para este usuario
      await _supabase
          .from('user_data')
          .upsert({'user_id': _userId, 'has_base_data': true});
    }

    _cargarResponsablesDesdeGastos();
    await _sincronizarConSupabase();
  }

  Future<void> _loadExistingData() async {
    // Carga los datos existentes desde Supabase
    final response = await _supabase
        .from('gastos')
        .select()
        .eq('user_id', _userId!);

    for (var gastoData in response) {
      final gasto = Gasto(
        id: gastoData['id'].toString(),
        precio: gastoData['precio'].toDouble(),
        fecha: DateTime.parse(gastoData['fecha']),
        responsable: gastoData['responsable'],
        etiquetas: List<String>.from(gastoData['etiquetas'] ?? []),
      );
      await _gastosBox.add(gasto);

      // Carga los subgastos asociados
      final subGastosResponse = await _supabase
          .from('subgastos')
          .select()
          .eq('gasto_id', gastoData['id']);

      for (var subGastoData in subGastosResponse) {
        final subGasto = SubGasto(
          id: subGastoData['id'].toString(),
          descripcion: subGastoData['descripcion'],
          precio: subGastoData['precio'].toDouble(),
          esIndividual: subGastoData['esIndividual'],
          responsable: subGastoData['responsable'],
          key: subGastoData['key'],
        );
        gasto.subGastos?.add(subGasto);
      }
      await gasto.save();
    }
    print('Datos cargados desde Supabase para el usuario $_userId: ${_gastosBox.length} gastos');
  }

  Future<void> _agregarDatosBase() async {
    print('Agregando datos base para el usuario $_userId...');

    // Agrega los gastos y subgastos con user_id
    final gasto0 = Gasto(
      precio: 1000.0,
      fecha: DateTime(2025, 2, 15),
      responsable: 'Ana',
      subGastos: [],
      etiquetas: [],
    );
    await agregarGasto(gasto0, caller: '_agregarDatosBase (Gasto 0)');
    print('Gasto 0 agregado con key: ${gasto0.key}');
    await _waitForGastoId(gasto0);
    print('Gasto 0 tiene ID: ${gasto0.id}');
    await agregarSubGasto(0, SubGasto(precio: 600.0, responsable: 'Ana', descripcion: 'Comida', esIndividual: true));
    await agregarSubGasto(0, SubGasto(precio: 400.0, responsable: 'Ana', descripcion: 'Transporte', esIndividual: true));

    final gasto1 = Gasto(
      precio: 500.0,
      fecha: DateTime(2025, 3, 10),
      responsable: 'Juan',
      subGastos: [],
      etiquetas: [],
    );
    await agregarGasto(gasto1, caller: '_agregarDatosBase (Gasto 1)');
    print('Gasto 1 agregado con key: ${gasto1.key}');
    await _waitForGastoId(gasto1);
    print('Gasto 1 tiene ID: ${gasto1.id}');
    await agregarSubGasto(1, SubGasto(precio: 300.0, responsable: 'Juan', descripcion: 'Materiales', esIndividual: true));
    await agregarSubGasto(1, SubGasto(precio: 200.0, responsable: 'Juan', descripcion: 'Otros', esIndividual: true));

    final gasto2 = Gasto(
      precio: 1200.0,
      fecha: DateTime(2025, 4, 1),
      responsable: 'Ana',
      subGastos: [],
      etiquetas: [],
    );
    await agregarGasto(gasto2, caller: '_agregarDatosBase (Gasto 2)');
    print('Gasto 2 agregado con key: ${gasto2.key}');
    await _waitForGastoId(gasto2);
    print('Gasto 2 tiene ID: ${gasto2.id}');
    await agregarSubGasto(2, SubGasto(precio: 600.0, responsable: 'Ana', descripcion: 'Alquiler', esIndividual: false));
    await agregarSubGasto(2, SubGasto(precio: 300.0, responsable: 'Juan', descripcion: 'Servicios', esIndividual: false));

    _responsables.addAll(['Ana', 'Juan']);
    print('Datos base agregados correctamente. Total gastos: ${_gastosBox.length}');
    _baseDataAdded = true;
  }

  void _cargarResponsablesDesdeGastos() {
    _responsables.clear();
    for (var gasto in _gastosBox.values) {
      if (gasto.responsable != null && !_responsables.contains(gasto.responsable)) {
        _responsables.add(gasto.responsable!);
      }
      for (var subGasto in gasto.subGastos ?? []) {
        if (subGasto.responsable != null && !_responsables.contains(subGasto.responsable)) {
          _responsables.add(subGasto.responsable!);
        }
      }
    }
    print('Responsables cargados desde gastos: $_responsables');
    notifyListeners();
  }

  Future<void> agregarGasto(Gasto gasto, {String caller = 'Unknown'}) async {
    if (_userId == null) {
      print('No hay usuario autenticado. No se puede agregar gasto.');
      return;
    }

    print('agregarGasto llamado por: $caller');
    print('Estado de _gastosBox antes de agregar: isOpen=${_gastosBox.isOpen}, length=${_gastosBox.length}');
    final nuevoGasto = gasto..subGastos = gasto.subGastos ?? [];
    final key = await _gastosBox.add(nuevoGasto);
    print('Gasto agregado con key: $key');
    print('Estado de _gastosBox después de agregar: length=${_gastosBox.length}');
    print('Verificando Gasto en _gastosBox: ${_gastosBox.get(key)}');
    if (gasto.responsable != null && !_responsables.contains(gasto.responsable)) {
      _responsables.add(gasto.responsable!);
    }
    await _queueSyncOperation('INSERT', 'gastos', {...nuevoGasto.toJson(), 'user_id': _userId}, key: key);
    print('Total gastos después de agregar: ${_gastosBox.length}');
    notifyListeners();
  }

  Future<void> editarGasto(int index, Gasto gastoEditado) async {
    final gasto = _gastosBox.getAt(index)!;
    gasto
      ..nombre = gastoEditado.nombre
      ..precio = gastoEditado.precio
      ..fecha = gastoEditado.fecha
      ..responsable = gastoEditado.responsable
      ..etiquetas = gastoEditado.etiquetas;
    await gasto.save();
    if (gastoEditado.responsable != null && !_responsables.contains(gastoEditado.responsable)) {
      _responsables.add(gastoEditado.responsable!);
    }
    await _queueSyncOperation('UPDATE', 'gastos', {...gasto.toJson(), 'user_id': _userId}, key: gasto.key);
    print('Total gastos después de editar: ${_gastosBox.length}');
    notifyListeners();
  }

  Future<void> eliminarGasto(int index) async {
    final gasto = _gastosBox.getAt(index)!;
    await _queueSyncOperation('DELETE', 'gastos', {...gasto.toJson(), 'user_id': _userId}, key: gasto.key);
    await _gastosBox.deleteAt(index);
    _cargarResponsablesDesdeGastos();
    print('Total gastos después de eliminar: ${_gastosBox.length}');
    notifyListeners();
  }

  Future<void> agregarSubGasto(int gastoIndex, SubGasto subGasto) async {
    if (_userId == null) {
      print('No hay usuario autenticado. No se puede agregar subgasto.');
      return;
    }

    print('agregarSubGasto: Intentando acceder a Gasto en índice $gastoIndex');
    print('Estado de _gastosBox: length=${_gastosBox.length}');
    final gasto = _gastosBox.getAt(gastoIndex)!;
    subGasto.key = gasto.subGastos?.length ?? 0;
    print('Asignando key a SubGasto: ${subGasto.key}');
    gasto.subGastos!.add(subGasto);
    if (subGasto.responsable != null && !_responsables.contains(subGasto.responsable)) {
      _responsables.add(subGasto.responsable!);
    }
    await gasto.save();
    print('SubGasto agregado con key: ${subGasto.key}, gasto id: ${gasto.id}');
    if (gasto.id == null) {
      print('Gasto.id es null, esperando ID...');
      await _waitForGastoId(gasto);
      if (gasto.id == null) {
        print('Error: No se pudo obtener el ID del Gasto después de esperar. No se sincronizará el SubGasto.');
        return;
      }
    }
    await _queueSyncOperation('INSERT', 'subgastos', {...subGasto.toJson(), 'user_id': _userId}, parentId: gasto.id, key: subGasto.key);
    print('Total gastos después de agregar SubGasto: ${_gastosBox.length}');
    notifyListeners();
  }

  Future<void> eliminarSubGasto(int gastoIndex, int subGastoIndex) async {
    final gasto = _gastosBox.getAt(gastoIndex)!;
    final subGasto = gasto.subGastos![subGastoIndex];
    await _queueSyncOperation('DELETE', 'subgastos', {...subGasto.toJson(), 'user_id': _userId}, parentId: gasto.id, key: subGasto.key);
    gasto.subGastos!.removeAt(subGastoIndex);
    await gasto.save();
    _cargarResponsablesDesdeGastos();
    print('Total gastos después de eliminar SubGasto: ${_gastosBox.length}');
    notifyListeners();
  }

  Future<void> editarSubGasto(int gastoIndex, int subGastoIndex, SubGasto subGastoEditado) async {
    final gasto = _gastosBox.getAt(gastoIndex)!;
    final subGasto = gasto.subGastos![subGastoIndex];
    print('Antes de editar SubGasto (index: $subGastoIndex): esIndividual=${subGasto.esIndividual}');
    print('SubGastoEditado: esIndividual=${subGastoEditado.esIndividual}');
    subGasto
      ..descripcion = subGastoEditado.descripcion
      ..precio = subGastoEditado.precio
      ..esIndividual = subGastoEditado.esIndividual
      ..responsable = subGastoEditado.responsable;
    print('Después de actualizar SubGasto (index: $subGastoIndex): esIndividual=${subGasto.esIndividual}');
    if (subGastoEditado.responsable != null && !_responsables.contains(subGastoEditado.responsable)) {
      _responsables.add(subGastoEditado.responsable!);
    }
    await gasto.save();
    print('Después de guardar en Hive (index: $subGastoIndex): esIndividual=${subGasto.esIndividual}');
    print('SubGasto editado con key: ${subGasto.key}, id: ${subGasto.id}, gasto id: ${gasto.id}');
    await _queueSyncOperation('UPDATE', 'subgastos', {...subGasto.toJson(), 'user_id': _userId}, parentId: gasto.id, key: subGasto.key);
    print('Total gastos después de editar SubGasto: ${_gastosBox.length}');
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

  Future<void> _queueSyncOperation(String operation, String table, dynamic data, {String? parentId, dynamic key}) async {
    final syncData = <String, dynamic>{
      'operation': operation,
      'table': table,
      'data': data is Gasto || data is SubGasto ? data.toJson() : data,
      'parentId': parentId,
      'key': key,
      'timestamp': DateTime.now().toIso8601String(),
      'attempts': 0,
    };
    final syncKey = await _syncQueue.add(syncData);
    print('Operación en cola: $operation, tabla: $table, key: $key, parentId: $parentId, syncKey: $syncKey');
    await _sincronizarConSupabase();
  }

  Future<void> _waitForGastoId(Gasto gasto) async {
    int attempts = 0;
    const maxAttempts = 20;
    const delay = Duration(milliseconds: 500);

    while (gasto.id == null && attempts < maxAttempts) {
      print('Esperando ID para gasto con key ${gasto.key}, intento ${attempts + 1}...');
      print('Estado de _syncQueue: length=${_syncQueue.length}, keys=${_syncQueue.keys}');
      await Future.delayed(delay);
      await _sincronizarConSupabase();
      attempts++;
    }

    if (gasto.id == null) {
      print('Error: No se pudo obtener el ID para el gasto con key ${gasto.key} después de $maxAttempts intentos');
    } else {
      print('ID obtenido para gasto con key ${gasto.key}: ${gasto.id}');
    }
  }

  Future<void> _sincronizarConSupabase() async {
    try {
      if (_syncQueue.isEmpty) {
        print('Cola de sincronización vacía, no hay operaciones pendientes.');
        return;
      }

      print('Iniciando sincronización con Supabase. Operaciones en cola: ${_syncQueue.length}');
      final operations = _syncQueue.toMap();
      for (var entry in operations.entries) {
        final int syncKey = entry.key;
        final Map<dynamic, dynamic> dynamicMap = entry.value;
        final Map<String, dynamic> syncData = {};
        dynamicMap.forEach((key, value) {
          syncData[key.toString()] = value;
        });

        final table = syncData['table'] as String;
        final operation = syncData['operation'] as String;
        final parentId = syncData['parentId'] as String?;
        final key = syncData['key'];

        final dynamic dataValue = syncData['data'];
        final Map<String, dynamic> data = dataValue is Map ? dataValue.map((k, v) => MapEntry(k.toString(), v)) : <String, dynamic>{};

        try {
          if (table == 'gastos') {
            if (operation == 'INSERT') {
              print('Insertando gasto en Supabase: $data');
              final response = await _supabase.from('gastos').insert(data).select().single();
              print('Respuesta de Supabase (INSERT gasto): $response');
              if (key != null) {
                print('Buscando Gasto con key $key en _gastosBox...');
                print('Estado de _gastosBox: length=${_gastosBox.length}, keys=${_gastosBox.keys}');
                final gasto = _gastosBox.values.firstWhere(
                  (g) => g.key == key,
                  orElse: () => throw Exception('Gasto con key $key no encontrado en _gastosBox'),
                );
                gasto.id = response['id'].toString();
                await gasto.save();
                print('Gasto con key $key actualizado con id: ${gasto.id}');
              } else {
                print('Error: Clave (key) no encontrada en data para INSERT en gastos');
              }
            } else if (operation == 'UPDATE') {
              print('Actualizando gasto en Supabase: $data');
              if (data['id'] != null && data['id'] != 'null') {
                await _supabase.from('gastos').update(data).eq('id', data['id']);
              } else {
                print('Error: ID nulo o inválido para UPDATE en gastos: ${data['id']}');
              }
            } else if (operation == 'DELETE') {
              print('Eliminando gasto en Supabase: $data');
              if (data['id'] != null && data['id'] != 'null') {
                await _supabase.from('gastos').delete().eq('id', data['id']);
              } else {
                print('Error: ID nulo o inválido para DELETE en gastos: ${data['id']}');
              }
            }
          } else if (table == 'subgastos') {
            if (operation == 'INSERT') {
              if (parentId == null) {
                print('Error: parentId es null para INSERT de subgasto, saltando operación');
                continue;
              }
              data['gasto_id'] = parentId;
              print('Insertando subgasto en Supabase: $data');
              final response = await _supabase.from('subgastos').insert(data).select().single();
              print('Respuesta de Supabase (INSERT subgasto): $response');
              if (parentId != null && key != null) {
                final gasto = _gastosBox.values.firstWhere(
                  (g) => g.id == parentId,
                  orElse: () => throw Exception('Gasto con id $parentId no encontrado'),
                );
                final subGastos = gasto.subGastos ?? [];
                final subGastoIndex = subGastos.indexWhere((s) => s.key == key);
                if (subGastoIndex != -1) {
                  final subGasto = subGastos[subGastoIndex];
                  if (response['id'] != null) {
                    subGasto.id = response['id'].toString();
                    await gasto.save();
                    print('SubGasto con key $key actualizado con id: ${subGasto.id}');
                  } else {
                    print('Error: No se recibió ID en la respuesta de Supabase para subgasto con key $key');
                  }
                } else {
                  print('Error: SubGasto con key $key no encontrado en gasto con id $parentId');
                }
              } else {
                print('Error: parentId o key no encontrados para INSERT en subgastos');
              }
            } else if (operation == 'UPDATE') {
              print('Actualizando subgasto en Supabase: $data');
              if (data['id'] != null && data['id'] != 'null') {
                await _supabase.from('subgastos').update(data).eq('id', data['id']);
              } else {
                print('Error: ID nulo o inválido para UPDATE en subgastos: ${data['id']}');
              }
            } else if (operation == 'DELETE') {
              print('Eliminando subgasto en Supabase: $data');
              if (data['id'] != null && data['id'] != 'null') {
                await _supabase.from('subgastos').delete().eq('id', data['id']);
              } else {
                print('Error: ID nulo o inválido para DELETE en subgastos: ${data['id']}');
              }
            }
          }
          await _syncQueue.delete(syncKey);
          print('Operación eliminada de la cola con syncKey: $syncKey');
        } catch (e, stackTrace) {
          print('Error específico en operación ($table, $operation, syncKey: $syncKey): $e');
          print('Stack trace: $stackTrace');
          syncData['attempts'] = (syncData['attempts'] as int? ?? 0) + 1;
          if (syncData['attempts'] >= 5) {
            print('Máximo de intentos alcanzado para operación ($table, $operation, syncKey: $syncKey). Eliminando de la cola.');
            await _syncQueue.delete(syncKey);
          } else {
            await _syncQueue.put(syncKey, syncData);
            print('Operación reintentada (intento ${syncData['attempts']}/5) para ($table, $operation, syncKey: $syncKey).');
          }
        }
      }
    } catch (e, stackTrace) {
      print('Error general sincronizando con Supabase: $e');
      print('Stack trace: $stackTrace');
    }
  }
}