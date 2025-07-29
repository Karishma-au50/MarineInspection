import 'package:get/get.dart';

import '../../../core/expections/custom_exception.dart';
import '../../../models/inspection_models.dart';
import '../../../services/inspection_service.dart';
import '../../../shared/widgets/toast/my_toast.dart';

class InspectionController extends GetxController {
  final _api = InspectionService();

  Future<InspectionTemplate?> getAllInspections(
    ) async {
    try {
      final res = await _api.getInspectionTemplate();
      if (res.status ?? false) {
        return res.data;
      } else {
        throw FetchDataException(res.message);
      }
    } catch (e) {
      MyToasts.toastError(e.toString());
      return null;
    }
  }

  // Future<InspectionTemplate?> getInspectionById(String id) async {
  //   try {
  //     final res = await _api.getInspectionById(id);
  //     if (res.status ?? false) {
  //       return res.data;
  //     } else {
  //       throw FetchDataException(res.message);
  //     }
  //   } catch (e) {
  //     MyToasts.toastError(e.toString());
  //     return null;
  //   }
  // }
  Future<bool> submitInspection(InspectionTemplate inspection) async {
    try {
      final res = await _api.submitInspectionAnswers(
        templateId: inspection.templateId,
        answers: {
          'sections': inspection.sections.map((section) => {
            'sectionId': section.sectionId,
            'questions': section.questions.map((q) => {
              'questionId': q.questionId,
              'answer': q.questionId,
            }).toList(),
          }).toList(),
        },
      );
      if (res.status ?? false) {
        MyToasts.toastSuccess(res.message ?? "Inspection submitted successfully");
        return true;
      } else {
        MyToasts.toastError(res.message ?? "Failed to submit inspection");
        return false;
      }
    } catch (e) {
      MyToasts.toastError(e.toString());
      return false;
    }
  }
  // Future<bool> updateInspection(InspectionTemplate inspection) async {
  //   try {
  //     final res = await _api.updateInspection(inspection);
  //     if (res.status ?? false) {
  //       MyToasts.toastSuccess(res.message ?? "Inspection updated successfully");
  //       return true;
  //     } else {
  //       MyToasts.toastError(res.message ?? "Failed to update inspection");
  //       return false;
  //     }
  //   } catch (e) {
  //     MyToasts.toastError(e.toString());
  //     return false;
  //   }
  // }
}
