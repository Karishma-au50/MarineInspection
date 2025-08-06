// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_submission_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InspectionSubmissionAdapter extends TypeAdapter<InspectionSubmission> {
  @override
  final int typeId = 0;

  @override
  InspectionSubmission read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InspectionSubmission(
      answers: (fields[0] as List).cast<InspectionAnswer>(),
      inspectionDate: fields[1] as DateTime,
      sectionId: fields[2] as String,
      inspectionId: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InspectionSubmission obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.answers)
      ..writeByte(1)
      ..write(obj.inspectionDate)
      ..writeByte(2)
      ..write(obj.sectionId)
      ..writeByte(3)
      ..write(obj.inspectionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionSubmissionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
