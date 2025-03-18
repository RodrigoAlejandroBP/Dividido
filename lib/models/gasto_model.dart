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
  List<String>? etiquetas; // Opcional, no requerido

  Gasto({
    this.id,
    this.nombre,
    required this.precio,
    required this.fecha,
    this.responsable,
    this.subGastos,
    this.etiquetas, // Aseguramos que sea opcional
  });
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

  SubGasto({
    this.id,
    this.descripcion,
    required this.precio,
    this.esIndividual,
    this.responsable,
  });
}