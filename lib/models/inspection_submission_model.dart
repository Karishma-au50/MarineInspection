import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import 'inspection_answer_model.dart';

part 'inspection_submission_model.g.dart';

@HiveType(typeId: 0)
class InspectionSubmission {
  @HiveField(0)
  final List<InspectionAnswer> answers;
  @HiveField(1)
  final DateTime inspectionDate;
  @HiveField(2)
  final String sectionId;
  @HiveField(3)
  String? inspectionId;
  @HiveField(4)
  String? shipName;
  

  InspectionSubmission({
    required this.answers, 
    required this.inspectionDate, 
    required this.sectionId, 
    this.inspectionId,
    this.shipName,
  });

  Future<FormData> toFormData() async {
    final formMap = <String, dynamic>{};

    for (int i = 0; i < answers.length; i++) {
      final answerMap = await answers[i].toFormDataMap(i);
      formMap.addAll(answerMap);
    }

    formMap['inspectionDate'] = inspectionDate.toUtc().toIso8601String();
    
    // Add ship name if provided
    if (shipName != null && shipName!.isNotEmpty) {
      formMap['shipName'] = shipName;
    }

    return FormData.fromMap(formMap);
  }
}
