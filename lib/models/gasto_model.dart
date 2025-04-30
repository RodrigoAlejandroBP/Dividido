import 'package:hive/hive.dart';

part 'gasto_model.g.dart';

@HiveType(typeId: 0)
class Gasto extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? nombre;

  @HiveField(2)
  double precio;

  @HiveField(3)
  DateTime fecha;

  @HiveField(4)
  String? responsable;

  @HiveField(5)
  List<SubGasto>? subGastos;

  @HiveField(6)
  List<String>? etiquetas;

  Gasto({
    this.id,
    this.nombre,
    this.precio = 0.0,
    required this.fecha,
    this.responsable,
    this.subGastos,
    this.etiquetas,
  }) {
    subGastos ??= [];
    etiquetas ??= [];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'precio': precio,
      'fecha': fecha.toIso8601String(),
      'responsable': responsable,
      'etiquetas': etiquetas,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}

@HiveType(typeId: 1)
class SubGasto extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? descripcion;

  @HiveField(2)
  double precio;

  @HiveField(3)
  bool? esIndividual;

  @HiveField(4)
  String? responsable;

  @HiveField(5)
  int? key;

  SubGasto({
    this.id,
    this.descripcion,
    this.precio = 0.0,
    this.esIndividual = false,
    this.responsable,
    this.key,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'descripcion': descripcion,
      'precio': precio,
      // 'esIndividual' removed to match Supabase schema
      'responsable': responsable,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}