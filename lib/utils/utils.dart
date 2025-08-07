import 'package:dio/dio.dart';
import '../models/inspection_submission_model.dart';
import '../shared/services/storage_service.dart';

/// Extension to convert List<InspectionSubmission> to FormData for multiple sections API
extension InspectionSubmissionListExtension on List<InspectionSubmission> {
  /// Converts List<InspectionSubmission> to FormData matching the API format:
  /// - inspectionDate (common for all sections)
  /// - sections[0][sectionId]
  /// - sections[0][answers][0][questionId]
  /// - sections[0][answers][0][answer]
  /// - sections[0][answers][0][satisfied]
  /// - sections[0][answers][0][comments]
  /// - sections[0][answers][0][file][0], sections[0][answers][0][file][1], etc.
  Future<FormData> toFormData() async {
    final formMap = <String, dynamic>{};

    // Use the inspection date from the first submission (assuming all have the same date)
    if (isNotEmpty) {
      formMap['inspectionDate'] = first.inspectionDate
          .toUtc()
          .toIso8601String();
    }

    // Process each section
    for (int sectionIndex = 0; sectionIndex < length; sectionIndex++) {
      final submission = this[sectionIndex];

      // Add section ID
      formMap['sections[$sectionIndex][sectionId]'] = submission.sectionId;

      // Process each answer in the section
      for (
        int answerIndex = 0;
        answerIndex < submission.answers.length;
        answerIndex++
      ) {
        final answer = submission.answers[answerIndex];

        // Add answer fields
        formMap['sections[$sectionIndex][answers][$answerIndex][questionId]'] =
            answer.questionId;
        formMap['sections[$sectionIndex][answers][$answerIndex][answer]'] =
            answer.answer;
        formMap['sections[$sectionIndex][answers][$answerIndex][satisfied]'] =
            answer.satisfied;

        // Add comments if present
        if (answer.comments != null && answer.comments!.isNotEmpty) {
          formMap['sections[$sectionIndex][answers][$answerIndex][comments]'] =
              answer.comments;
        }

        // Add files if present
        if (answer.files.isNotEmpty) {
          for (
            int fileIndex = 0;
            fileIndex < answer.files.length;
            fileIndex++
          ) {
            final file = answer.files[fileIndex];
            formMap['sections[$sectionIndex][answers][$answerIndex][file][$fileIndex]'] =
                await MultipartFile.fromFile(
                  file.path,
                  filename: file.path.split('/').last,
                );
          }
        }
      }
    }

    return FormData.fromMap(formMap);
  }
}

/// Utility class for common form data operations
class FormDataUtils {
  /// Helper method to create FormData for single inspection submission
  static Future<FormData> createSingleInspectionFormData(
    InspectionSubmission submission,
  ) async {
    return await submission.toFormData();
  }

  /// Helper method to create FormData for multiple inspection submissions
  static Future<FormData> createMultipleInspectionFormData(
    List<InspectionSubmission> submissions,
  ) async {
    return await submissions.toFormData();
  }

  /// Validate that all submissions have the same inspection date
  static bool validateSameInspectionDate(
    List<InspectionSubmission> submissions,
  ) {
    if (submissions.isEmpty) return true;

    final firstDate = submissions.first.inspectionDate;
    return submissions.every(
      (submission) => submission.inspectionDate.isAtSameMomentAs(firstDate),
    );
  }

  /// Get the total number of files across all submissions
  static int getTotalFileCount(List<InspectionSubmission> submissions) {
    int totalFiles = 0;
    for (final submission in submissions) {
      for (final answer in submission.answers) {
        totalFiles += answer.files.length;
      }
    }
    return totalFiles;
  }
}

class Utils {
  /// Check if current user is admin
  static bool isAdmin() {
    final user = StorageService.instance.getUserId();
    return user?.role == 'admin';
  }

  /// Check if current user is employee/engineer
  static bool isEmployee() {
    final user = StorageService.instance.getUserId();
    return user?.role == 'employee' || user?.role == 'engineer';
  }

  /// Get current user role
  static String? getCurrentUserRole() {
    final user = StorageService.instance.getUserId();
    return user?.role;
  }
}
