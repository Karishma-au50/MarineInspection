import 'dart:io';
import 'package:dio/dio.dart';

class InspectionAnswer {
  String questionId;
  String answer;
  String satisfied;
  String? comments;
  File? file; // Keep for backward compatibility
  List<File> files; // Single list for both images and videos

  InspectionAnswer({
    required this.questionId,
    required this.answer,
    required this.satisfied,
    this.comments,
    this.file,
    List<File>? files,
  }) : files = files ?? [];

  /// Returns a map with indexed keys to be added to FormData
  Future<Map<String, dynamic>> toFormDataMap(int index) async {
    Map<String, dynamic> formData = {
      'answers[$index][questionId]': questionId,
      'answers[$index][answer]': answer,
      'answers[$index][satisfied]': satisfied,
      'answers[$index][comments]': comments,
    };

    // Add all files (both images and videos) to the same files array
    if (files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        formData['files[$index][$i]'] = await MultipartFile.fromFile(
          files[i].path,
          filename: files[i].path.split('/').last,
        );
      }
    }

    // Keep backward compatibility with single file
    if (file != null && (file?.path.isNotEmpty ?? false)) {
      formData['files[$index]'] = await MultipartFile.fromFile(
        file!.path,
        filename: file!.path.split('/').last,
      );
    }

    return formData;
  }

  @override
  String toString() {
    return 'InspectionAnswer(questionId: $questionId, answer: $answer, satisfied: $satisfied, comments: $comments, file: ${file?.path}, files: ${files.map((f) => f.path).toList()})';
  }

  factory InspectionAnswer.fromJson(Map<String, dynamic> json) {
    List<File> allFiles = [];
    
    // Add files from 'files' key
    if (json['files'] != null) {
      allFiles.addAll((json['files'] as List).map((filePath) => File(filePath)).toList());
    }
    
    // Add files from 'videos' key for backward compatibility
    if (json['videos'] != null) {
      allFiles.addAll((json['videos'] as List).map((videoPath) => File(videoPath)).toList());
    }
    
    return InspectionAnswer(
      questionId: json['questionId'] ?? '',
      answer: json['answer'] ?? '',
      satisfied: json['satisfied'] ?? '',
      comments: json['comments'] ?? '',
      file: json['file'] != null && json['file'].isNotEmpty ? File(json['file']) : null,
      files: allFiles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
      'satisfied': satisfied,
      'comments': comments,
      'file': file?.path,
      'files': files.map((f) => f.path).toList(),
    };
  }
}
