import 'dart:async';

import 'package:get/get.dart';
import 'package:marine_inspection/models/inspection_submission_model.dart';
import 'package:marine_inspection/models/inspection_template.dart';

import '../../../core/expections/custom_exception.dart';
import '../../../models/inspection_detail_model.dart';
import '../../../models/inspection_model.dart';
import '../../../services/hive_service.dart';
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
      HiveService.instance.saveInspectionSubmission(inspection);
      final res = await _api.submitInspectionAnswers(
        inspectionSubmission: inspection,
      );
      if (res.status ?? false) {
        inspection.inspectionId= res.data["inspection"]['inspectionId'];
        HiveService.instance.saveInspectionSubmission(inspection);
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
  Future<InspectionDetailData?> getInspectionSubmissionBySectionId(String sectionId) async {
    try {
      final res = await _api.getInspectionBySectionId(sectionId);
      if (res.status ?? false) {
        return res.data;
      } else {
        throw FetchDataException(res.message);
      }
    } catch (e) {
      MyToasts.toastError("Failed to fetch inspection submission: $e");
      return null;
    }
  }
}
