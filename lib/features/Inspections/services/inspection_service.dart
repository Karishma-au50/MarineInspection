import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:marine_inspection/core/network/base_api_service.dart';
import '../../../../../core/model/response_model.dart';
import '../../../../../models/inspection_template.dart';
import '../../../models/inspection_detail_model.dart';
import '../../../models/inspection_model.dart';
import '../../../models/inspection_submission_model.dart';
import '../../../shared/services/storage_service.dart';

class InspectionEndpoint {
  static const String getTemplate = 'api/inspections/templates/complete-marine';
  static const String submitAnswers = 'api/inspection-submission';
  static const String getInspectionsByUserId = 'api/inspections/inspector';
}

class InspectionService extends BaseApiService {
  /// Fetch inspection template from API
  Future<ResponseModel<InspectionTemplate?>> getInspectionTemplate() async {
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

  /// Submit inspection answers to API
  Future<ResponseModel> submitInspectionAnswers({
    required InspectionSubmission inspectionSubmission,
  }) async {
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
