import 'package:dio/dio.dart';

import 'inspection_answer_model.dart';

class InspectionSubmission {
  final List<InspectionAnswer> answers;
  final DateTime inspectionDate;
  final String sectionId;

  InspectionSubmission({required this.answers, required this.inspectionDate, required this.sectionId});

  Future<FormData> toFormData() async {
    final formMap = <String, dynamic>{};

    for (int i = 0; i < answers.length; i++) {
      final answerMap = await answers[i].toFormDataMap(i);
      formMap.addAll(answerMap);
    }

    formMap['inspectionDate'] = inspectionDate.toUtc().toIso8601String();

    return FormData.fromMap(formMap);
  }
}
