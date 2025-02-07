// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subdivision.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubdivisionAdapter extends TypeAdapter<Subdivision> {
  @override
  final int typeId = 2;

  @override
  Subdivision read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subdivision(
      imagePath: fields[1] as String,
      subdivisionList: (fields[2] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Subdivision obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.subdivisionId)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.subdivisionList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubdivisionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
