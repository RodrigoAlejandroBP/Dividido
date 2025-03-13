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
      nombre: fields[0] as String?,
      precio: fields[1] as double,
      fecha: fields[2] as DateTime,
      responsable: fields[3] as String?,
      subGastos: (fields[4] as List?)?.cast<SubGasto>(),
    );
  }

  @override
  void write(BinaryWriter writer, Gasto obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.precio)
      ..writeByte(2)
      ..write(obj.fecha)
      ..writeByte(3)
      ..write(obj.responsable)
      ..writeByte(4)
      ..write(obj.subGastos);
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
      descripcion: fields[0] as String?,
      precio: fields[1] as double,
      esIndividual: fields[2] as bool?,
      responsable: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SubGasto obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.descripcion)
      ..writeByte(1)
      ..write(obj.precio)
      ..writeByte(2)
      ..write(obj.esIndividual)
      ..writeByte(3)
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
