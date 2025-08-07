import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:marine_inspection/core/network/base_api_service.dart';
import 'package:marine_inspection/utils/network_utils.dart';
import 'package:marine_inspection/utils/utils.dart';
import '../../../../../core/model/response_model.dart';
import '../../../../../models/inspection_template.dart';
import '../../../models/inspection_detail_model.dart';
import '../../../models/inspection_model.dart';
import '../../../models/inspection_submission_model.dart';
import '../../../shared/services/storage_service.dart';
import '../../../services/hive_service.dart';

class InspectionEndpoint {
  static const String getTemplate = 'api/inspections/templates/complete-marine';
  static const String submitAnswers = 'api/inspection-submission';
  static const String getInspectionsByUserId = 'api/inspections/inspector';
}

class InspectionService extends BaseApiService {
  /// Fetch inspection template from API with network check
  Future<ResponseModel<InspectionTemplate?>> getInspectionTemplate() async {
    // Check network connectivity first
    final isConnected = await NetworkUtils.isConnected();
    if (!isConnected) {
      return ResponseModel<InspectionTemplate?>(
        message: "No internet connection available",
        status: false,
        data: null,
      );
    }

    final res = await get(
      InspectionEndpoint.getTemplate,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.instance.getToken()}',
        },
      ),
    );
    ResponseModel<InspectionTemplate?> resModel =
        ResponseModel<InspectionTemplate?>(
          message: res.data["message"],
          status: res.data["statusCode"] >= 200 && res.data["statusCode"] < 300,
          data: InspectionTemplate.fromJson(res.data["data"]),
        );
    return resModel;
  }

  /// Submit inspection answers to API with network check
  Future<ResponseModel> submitInspectionAnswers({
    required InspectionSubmission inspectionSubmission,
  }) async {
    // Check network connectivity first
    final isConnected = await NetworkUtils.isConnected();
    if (!isConnected) {
      return ResponseModel(
        message: "No internet connection. Data saved locally for later sync.",
        status: false,
        data: null,
      );
    }

    var data = await inspectionSubmission.toFormData();
    String url = "";
    if(inspectionSubmission.inspectionId != null &&
        inspectionSubmission.inspectionId!.isNotEmpty) {
      url = 'api/inspections/${inspectionSubmission.inspectionId}/sections/${inspectionSubmission.sectionId}/answers';
    } else {
      url = 'api/inspections/sections/${inspectionSubmission.sectionId}/answers';
    }
    final res = await post(
      url,
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.instance.getToken()}',
        },
      ),
    );
    ResponseModel resModel = ResponseModel(
      message: res.data["message"],
      status: res.data["statusCode"] >= 200 && res.data["statusCode"] < 300,
      data: res.data["data"],
    );
    return resModel;
  }
// submit without network
  /// Submit multiple inspection answers to API with offline support
  Future<ResponseModel> submitMultipleInspectionAnswers({
    required List<InspectionSubmission> inspectionSubmissions,
  }) async {
    // Check network connectivity first
    final isConnected = await NetworkUtils.isConnected();
    if (!isConnected) {
      // Save all submissions to local storage for later sync
      try {
        for (final submission in inspectionSubmissions) {
          await HiveService.instance.saveInspectionSubmission(submission);
        }
        return ResponseModel(
          message: "No internet connection. ${inspectionSubmissions.length} submissions saved locally for later sync.",
          status: true, // Return true because we successfully saved locally
          data: {"saved_locally": true, "count": inspectionSubmissions.length},
        );
      } catch (e) {
        return ResponseModel(
          message: "Failed to save submissions locally: $e",
          status: false,
          data: null,
        );
      }
    }

    var data = await inspectionSubmissions.toFormData();
    String url = "";
    bool hasInspectionId = inspectionSubmissions.any((submission) => 
        submission.inspectionId != null && submission.inspectionId!.isNotEmpty);
    
    if (hasInspectionId) {
      var inspectionId = inspectionSubmissions
          .firstWhere((submission) => 
              submission.inspectionId != null && submission.inspectionId!.isNotEmpty)
          .inspectionId;
      url = 'api/inspections/$inspectionId/sections/multiple';
    } else {
      url = 'api/inspections/sections/multiple';
    }
    
    final res = await post(
      url,
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer ${StorageService.instance.getToken()}',
        },
      ),
    );
    ResponseModel resModel = ResponseModel(
      message: res.data["message"],
      status: res.data["statusCode"] >= 200 && res.data["statusCode"] < 300,
      data: res.data["data"],
    );
    return resModel;
  }

  //Fetch inspections by userid
  Future<ResponseModel<InspectionListResponse?>> getInspectionsByUserId(
    String? userId,
  ) async {
    
    final res = await get(
      '${InspectionEndpoint.getInspectionsByUserId}/$userId',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.instance.getToken()}',
        },
      ),
    );
    ResponseModel<InspectionListResponse?> resModel =
        ResponseModel<InspectionListResponse?>(
          message: res.data["message"],
          status: res.data["statusCode"] >= 200 && res.data["statusCode"] < 300,
          data: InspectionListResponse.fromJson(res.data["data"]),
        );
    return resModel;
  }

  // Fetch inspection by section ID
  Future<ResponseModel<InspectionDetailData?>> getInspectionBySectionId(
    String sectionId,
  ) async {
    final res = await get(
      'api/inspections/$sectionId/report',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.instance.getToken()}',
        },
      ),
    );
    ResponseModel<InspectionDetailData?> resModel =
        ResponseModel<InspectionDetailData?>(
          message: res.data["message"],
          status: res.data["statusCode"] >= 200 && res.data["statusCode"] < 300,
          data: InspectionDetailData.fromJson(res.data["data"]),
        );
    return resModel;
  }
}
