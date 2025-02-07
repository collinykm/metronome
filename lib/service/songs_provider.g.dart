// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songs_provider.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 0;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      songName: fields[1] as String,
      sectionsList: (fields[2] as List?)?.cast<Section>(),
    )..songId = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.songId)
      ..writeByte(1)
      ..write(obj.songName)
      ..writeByte(2)
      ..write(obj.sectionsList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SectionAdapter extends TypeAdapter<Section> {
  @override
  final int typeId = 1;

  @override
  Section read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Section(
      sectionName: fields[1] as String,
      bars: fields[2] as int,
      tempo: fields[3] as int,
      accentsList: (fields[4] as List).cast<int>(),
      meter: (fields[5] as List).cast<int>(),
      subdivision: fields[6] as Subdivision,
    )..sectionId = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, Section obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.sectionId)
      ..writeByte(1)
      ..write(obj.sectionName)
      ..writeByte(2)
      ..write(obj.bars)
      ..writeByte(3)
      ..write(obj.tempo)
      ..writeByte(4)
      ..write(obj.accentsList)
      ..writeByte(5)
      ..write(obj.meter)
      ..writeByte(6)
      ..write(obj.subdivision);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
