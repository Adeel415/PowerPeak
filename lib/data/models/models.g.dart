// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeightEntryAdapter extends TypeAdapter<WeightEntry> {
  @override
  final int typeId = 0;

  @override
  WeightEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightEntry(
      weightKg: fields[0] as double,
      date: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WeightEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weightKg)
      ..writeByte(1)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      weightKg: fields[0] as double,
      heightCm: fields[1] as double,
      age: fields[2] as int,
      gender: fields[3] as String,
      activityLevel: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.weightKg)
      ..writeByte(1)
      ..write(obj.heightCm)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.activityLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
