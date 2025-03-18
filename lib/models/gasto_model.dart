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
  });

  // Método toJson directamente en la clase
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
    this.precio = 0.0,
    this.esIndividual,
    this.responsable,
  });

  // Método toJson directamente en la clase
  Map<String, dynamic> toJson() => {
        'id': id,
        'descripcion': descripcion,
        'precio': precio,
        'esIndividual': esIndividual,
        'responsable': responsable,
        'key': key,
      };
}