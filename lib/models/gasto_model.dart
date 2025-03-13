import 'package:hive/hive.dart';

part 'gasto_model.g.dart';

@HiveType(typeId: 0)
class Gasto extends HiveObject {
  @HiveField(0)
  String? nombre;

  @HiveField(1)
  double precio;

  @HiveField(2)
  DateTime fecha;

  @HiveField(3)
  String? responsable;

  @HiveField(4)
  List<SubGasto>? subGastos;

  Gasto({
    this.nombre,
    required this.precio,
    required this.fecha,
    this.responsable,
    this.subGastos,
  });
}

@HiveType(typeId: 1)
class SubGasto extends HiveObject {
  @HiveField(0)
  String? descripcion;

  @HiveField(1)
  double precio;

  @HiveField(2)
  bool? esIndividual;

  @HiveField(3)
  String? responsable;

  SubGasto({
    this.descripcion,
    required this.precio,
    this.esIndividual,
    this.responsable,
  });
}