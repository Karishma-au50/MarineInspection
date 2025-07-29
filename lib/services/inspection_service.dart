import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:marine_inspection/core/network/base_api_service.dart';
import '../../../core/model/response_model.dart';
import '../../../models/inspection_template.dart';
import '../shared/services/storage_service.dart';

class InspectionEndpoint {
  static const String getTemplate = 'api/inspections/templates/complete-marine';
  static const String submitAnswers = 'api/inspection-submission';
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
    String? templateId,
    Map<String, dynamic>? answers,
  }) async {
    final res = await post(
      InspectionEndpoint.submitAnswers,
      data: {
        'templateId': templateId,
        'answers': answers,
        'submittedAt': DateTime.now().toIso8601String(),
      },
    );
    ResponseModel resModel = ResponseModel(
      message: res.data["message"],
      status: res.data["status"],
      data: res.data["data"],
    );
    return resModel;
  }

  /// Mock data for development/testing (remove when API is ready)
  /// This method simulates a network call and returns a mock inspection template.
  // Future<InspectionTemplate?> getMockInspectionTemplate() async {
  //   // Simulate network delay
  //   await Future.delayed(const Duration(seconds: 1));

  //   final mockResponse = {
  //     "statusCode": 200,
  //     "data": {
  //       "_id": "688867a99bf6cf672362513d",
  //       "templateId": "complete-marine-inspection-2025",
  //       "templateName": "Complete Marine Vessel Inspection Checklist",
  //       "vesselType": "All Vessels",
  //       "sections": [
  //         {
  //           "sectionId": "A-emergency-engine",
  //           "sectionName": "A) EMERGENCIES + ENGINE ROOM",
  //           "questions": [
  //             {
  //               "questionId": "A1-emergency-generator",
  //               "questionText": "A1 Emergency Generator – Means of Starting + 3 starts on each, Last tried out on auto / load test, D.O Tank - Min level – 18 hours operation + QCV mechanism, Any alarms",
  //               "questionType": "checkbox",
  //               "required": true,
  //               "options": [],
  //               "_id": "688867a99bf6cf672362513f"
  //             },
  //             {
  //               "questionId": "A2-emergency-fire-pump",
  //               "questionText": "A2 Emergency Fire Pump – Priming Pump fitted and operational + Gland condition + Foundation, Pressure Build Up time & Pressure, Minimum draft marked + Present draft of the vessel, Enough pressure on both the fire hoses",
  //               "questionType": "checkbox",
  //               "required": true,
  //               "options": [],
  //               "_id": "688867a99bf6cf6723625140"
  //             }
  //           ],
  //           "order": 1,
  //           "_id": "688867a99bf6cf672362513e"
  //         },
  //         {
  //           "sectionId": "B-deck-lifeboats",
  //           "sectionName": "B) DECK + LIFEBOATS",
  //           "questions": [
  //             {
  //               "questionId": "B1-free-fall-lifeboat",
  //               "questionText": "B1 Free Fall Lifeboat – Last Lowered / Maneuvered Date + Last Simulated Date, Status of Ram + visible leaks & High-Pressure Hose, Battery last renewed date, Engines tried out three times on either battery",
  //               "questionType": "checkbox",
  //               "required": true,
  //               "options": [],
  //               "_id": "688867a99bf6cf672362514f"
  //             }
  //           ],
  //           "order": 2,
  //           "_id": "688867a99bf6cf672362514e"
  //         }
  //       ],
  //       "version": "2025.1",
  //       "isActive": true,
  //       "createdBy": "688855cc8bf156b427edf833",
  //       "createdAt": "2025-07-29T06:18:17.365Z",
  //       "updatedAt": "2025-07-29T06:18:17.365Z",
  //       "__v": 0
  //     },
  //     "message": "Template fetched successfully",
  //     "error": false
  //   };

  //   try {
  //     final apiResponse = ApiResponse.fromJson(
  //       mockResponse,
  //       (data) => InspectionTemplate.fromJson(data),
  //     );

  //     if (!apiResponse.error) {
  //       return apiResponse.data;
  //     }
  //     return null;
  //   } catch (e) {
  //     print('Mock Data Error: $e');
  //     return null;
  //   }
  // }

  //  Future<InspectionTemplate?> getInspectionTemplate() async {
  //   try {
  //     final res = await get(
  //       InspectionEndpoint.getTemplate, // Replace with your actual endpoint
  //      );
  //      await http.get(
  //       Uri.parse('$baseUrl/inspection-template'), // Replace with your actual endpoint
  //       headers: {
  //         'Content-Type': 'application/json',
  //         // Add any authentication headers if needed
  //         // 'Authorization': 'Bearer $token',
  //       },
  //     );\

  //     if (response.statusCode == 200) {
  //       final jsonData = json.decode(response.body);
  //       final apiResponse = ApiResponse.fromJson(
  //         jsonData,
  //         (data) => InspectionTemplate.fromJson(data),
  //       );

  //       if (!apiResponse.error) {
  //         return apiResponse.data;
  //       } else {
  //         print('API Error: ${apiResponse.message}');
  //         return null;
  //       }
  //     } else {
  //       print('HTTP Error: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Network Error: $e');
  //     return null;
  //   }
  // }
}


// class InspectionService {
//   static const String baseUrl = ; // Replace with your actual API URL
  
//   /// Fetch inspection template from API
//   static Future<InspectionTemplate?> getInspectionTemplate() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/inspection-template'), // Replace with your actual endpoint
//         headers: {
//           'Content-Type': 'application/json',
//           // Add any authentication headers if needed
//           // 'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         final apiResponse = ApiResponse.fromJson(
//           jsonData,
//           (data) => InspectionTemplate.fromJson(data),
//         );
        
//         if (!apiResponse.error) {
//           return apiResponse.data;
//         } else {
//           print('API Error: ${apiResponse.message}');
//           return null;
//         }
//       } else {
//         print('HTTP Error: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       print('Network Error: $e');
//       return null;
//     }
//   }

//   /// Submit inspection answers to API
//   static Future<bool> submitInspectionAnswers({
//     required String templateId,
//     required Map<String, dynamic> answers,
//   }) async {
//     try {
//       final requestBody = {
//         'templateId': templateId,
//         'answers': answers,
//         'submittedAt': DateTime.now().toIso8601String(),
//       };

//       final response = await http.post(
//         Uri.parse('$baseUrl/inspection-submission'), // Replace with your actual endpoint
//         headers: {
//           'Content-Type': 'application/json',
//           // Add any authentication headers if needed
//           // 'Authorization': 'Bearer $token',
//         },
//         body: json.encode(requestBody),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final jsonData = json.decode(response.body);
//         return !jsonData['error'];
//       } else {
//         print('HTTP Error: ${response.statusCode}');
//         return false;
//       }
//     } catch (e) {
//       print('Network Error: $e');
//       return false;
//     }
//   }

//   /// Mock data for development/testing (remove when API is ready)
//   static Future<InspectionTemplate?> getMockInspectionTemplate() async {
//     // Simulate network delay
//     await Future.delayed(const Duration(seconds: 1));
    
//     final mockResponse = {
//       "statusCode": 200,
//       "data": {
//         "_id": "688867a99bf6cf672362513d",
//         "templateId": "complete-marine-inspection-2025",
//         "templateName": "Complete Marine Vessel Inspection Checklist",
//         "vesselType": "All Vessels",
//         "sections": [
//           {
//             "sectionId": "A-emergency-engine",
//             "sectionName": "A) EMERGENCIES + ENGINE ROOM",
//             "questions": [
//               {
//                 "questionId": "A1-emergency-generator",
//                 "questionText": "A1 Emergency Generator – Means of Starting + 3 starts on each, Last tried out on auto / load test, D.O Tank - Min level – 18 hours operation + QCV mechanism, Any alarms",
//                 "questionType": "checkbox",
//                 "required": true,
//                 "options": [],
//                 "_id": "688867a99bf6cf672362513f"
//               },
//               {
//                 "questionId": "A2-emergency-fire-pump",
//                 "questionText": "A2 Emergency Fire Pump – Priming Pump fitted and operational + Gland condition + Foundation, Pressure Build Up time & Pressure, Minimum draft marked + Present draft of the vessel, Enough pressure on both the fire hoses",
//                 "questionType": "checkbox",
//                 "required": true,
//                 "options": [],
//                 "_id": "688867a99bf6cf6723625140"
//               }
//             ],
//             "order": 1,
//             "_id": "688867a99bf6cf672362513e"
//           },
//           {
//             "sectionId": "B-deck-lifeboats",
//             "sectionName": "B) DECK + LIFEBOATS",
//             "questions": [
//               {
//                 "questionId": "B1-free-fall-lifeboat",
//                 "questionText": "B1 Free Fall Lifeboat – Last Lowered / Maneuvered Date + Last Simulated Date, Status of Ram + visible leaks & High-Pressure Hose, Battery last renewed date, Engines tried out three times on either battery",
//                 "questionType": "checkbox",
//                 "required": true,
//                 "options": [],
//                 "_id": "688867a99bf6cf672362514f"
//               }
//             ],
//             "order": 2,
//             "_id": "688867a99bf6cf672362514e"
//           }
//         ],
//         "version": "2025.1",
//         "isActive": true,
//         "createdBy": "688855cc8bf156b427edf833",
//         "createdAt": "2025-07-29T06:18:17.365Z",
//         "updatedAt": "2025-07-29T06:18:17.365Z",
//         "__v": 0
//       },
//       "message": "Template fetched successfully",
//       "error": false
//     };

//     try {
//       final apiResponse = ApiResponse.fromJson(
//         mockResponse,
//         (data) => InspectionTemplate.fromJson(data),
//       );
      
//       if (!apiResponse.error) {
//         return apiResponse.data;
//       }
//       return null;
//     } catch (e) {
//       print('Mock Data Error: $e');
//       return null;
//     }
//   }

// }
