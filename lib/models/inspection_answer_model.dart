import 'dart:io';
import 'package:dio/dio.dart';

class InspectionAnswer {
  String questionId;
  String answer;
  bool satisfied;
  String comments;
  File file;

  InspectionAnswer({
    required this.questionId,
    required this.answer,
    required this.satisfied,
    required this.comments,
    required this.file,
  });

  /// Returns a map with indexed keys to be added to FormData
  Future<Map<String, dynamic>> toFormDataMap(int index) async {
    return {
      'answers[$index][questionId]': questionId,
      'answers[$index][answer]': answer,
      'answers[$index][satisfied]': satisfied.toString(),
      'answers[$index][comments]': comments,
      'files[$index]': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    };
  }

  @override
  String toString() {
    return 'InspectionAnswer(questionId: $questionId, answer: $answer, satisfied: $satisfied, comments: $comments, file: ${file.path})';
  }

  factory InspectionAnswer.fromJson(Map<String, dynamic> json) {
    return InspectionAnswer(
      questionId: json['questionId'] ?? '',
      answer: json['answer'] ?? '',
      satisfied: json['satisfied'] ?? false,
      comments: json['comments'] ?? '',
      file: File(json['file'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
      'satisfied': satisfied,
      'comments': comments,
      'file': file.path,
    };
  }
}
