import 'dart:async';

import 'package:get/get.dart';
import 'package:marine_inspection/models/inspection_submission_model.dart';
import 'package:marine_inspection/models/inspection_template.dart';

import '../../../core/expections/custom_exception.dart';
import '../../../models/inspection_model.dart';
import '../services/inspection_service.dart';
import '../../../shared/widgets/toast/my_toast.dart';

class InspectionController extends GetxController {
  final _api = InspectionService();

  Future<InspectionTemplate?> getAllInspections() async {
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

  Future<bool> submitInspection(InspectionSubmission inspection) async {
    try {
      final res = await _api.submitInspectionAnswers(
        inspectionSubmission: inspection,
      );
      if (res.status ?? false) {
        MyToasts.toastSuccess(
          res.message ?? "Inspection submitted successfully",
        );
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

  Future<InspectionListResponse?> getInspectionsByUserId(String? userId) async {
    try {
      final res = await _api.getInspectionsByUserId(userId);
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

 
}
