// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gasto_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GastoAdapter extends TypeAdapter<Gasto> {
  @override
  final int typeId = 0;

  @override
  Gasto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gasto(
      id: fields[0] as String?,
      nombre: fields[1] as String?,
      precio: fields[2] as double,
      fecha: fields[3] as DateTime,
      responsable: fields[4] as String?,
      subGastos: (fields[5] as List?)?.cast<SubGasto>(),
      etiquetas: (fields[6] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Gasto obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.precio)
      ..writeByte(3)
      ..write(obj.fecha)
      ..writeByte(4)
      ..write(obj.responsable)
      ..writeByte(5)
      ..write(obj.subGastos)
      ..writeByte(6)
      ..write(obj.etiquetas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GastoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubGastoAdapter extends TypeAdapter<SubGasto> {
  @override
  final int typeId = 1;

  @override
  SubGasto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubGasto(
      id: fields[0] as String?,
      descripcion: fields[1] as String?,
      precio: fields[2] as double,
      esIndividual: fields[3] as bool?,
      responsable: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SubGasto obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.descripcion)
      ..writeByte(2)
      ..write(obj.precio)
      ..writeByte(3)
      ..write(obj.esIndividual)
      ..writeByte(4)
      ..write(obj.responsable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubGastoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
