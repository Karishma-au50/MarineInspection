// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_answer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InspectionAnswerAdapter extends TypeAdapter<InspectionAnswer> {
  @override
  final int typeId = 1;

  @override
  InspectionAnswer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InspectionAnswer(
      questionId: fields[0] as String,
      answer: fields[1] as String,
      satisfied: fields[2] as String,
      comments: fields[3] as String?,
      files: (fields[4] as List?)?.cast<File>(),
    );
  }

  @override
  void write(BinaryWriter writer, InspectionAnswer obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.answer)
      ..writeByte(2)
      ..write(obj.satisfied)
      ..writeByte(3)
      ..write(obj.comments)
      ..writeByte(4)
      ..write(obj.files);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionAnswerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
