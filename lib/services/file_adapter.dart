import 'dart:io';
import 'package:hive/hive.dart';

class FileAdapter extends TypeAdapter<File> {
  @override
  final int typeId = 2;

  @override
  File read(BinaryReader reader) {
    final path = reader.readString();
    return File(path);
  }

  @override
  void write(BinaryWriter writer, File obj) {
    writer.writeString(obj.path);
  }
}
