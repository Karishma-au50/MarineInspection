import 'package:hive_flutter/hive_flutter.dart';
import '../models/inspection_submission_model.dart';
import '../models/inspection_answer_model.dart';
import 'file_adapter.dart';

class HiveService {
  static const String _inspectionSubmissionsBoxName = 'inspection_submissions';
  
  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();
  
  HiveService._();

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register type adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(InspectionSubmissionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(InspectionAnswerAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FileAdapter());
    }
  }

  /// Get the inspection submissions box
  Future<Box<InspectionSubmission>> get _inspectionSubmissionsBox async {
    return await Hive.openBox<InspectionSubmission>(_inspectionSubmissionsBoxName);
  }

  /// Save an inspection submission to local storage
  Future<void> saveInspectionSubmission(InspectionSubmission submission) async {
    final box = await _inspectionSubmissionsBox;
    final key = '${submission.sectionId}_${submission.inspectionDate.millisecondsSinceEpoch}';
    await box.put(key, submission);
  }

  /// Get all stored inspection submissions
  Future<List<InspectionSubmission>> getAllInspectionSubmissions() async {
    final box = await _inspectionSubmissionsBox;
    return box.values.toList();
  }

  /// Get inspection submissions by section ID
  Future<List<InspectionSubmission>> getInspectionSubmissionsBySection(String sectionId) async {
    final box = await _inspectionSubmissionsBox;
    return box.values.where((submission) => submission.sectionId == sectionId).toList();
  }

    Future<InspectionSubmission?> getInspectionSubmissionsBySectionId(String sectionId) async {
    final box = await _inspectionSubmissionsBox;
    try{
      return box.values.firstWhere((submission) => submission.sectionId == sectionId);
    }
    catch (e) {
      return null; // Return null if no submission found for the section
    }
  }

  // get inspection submission by inspection id
  Future<InspectionSubmission?> getInspectionSubmissionById(String sectionId, DateTime inspectionDate) async {
    final box = await _inspectionSubmissionsBox;
    final key = '${sectionId}_${inspectionDate.millisecondsSinceEpoch}';
    return box.get(key);
  }

  /// Delete an inspection submission
  Future<void> deleteInspectionSubmission(String sectionId, DateTime inspectionDate) async {
    final box = await _inspectionSubmissionsBox;
    final key = '${sectionId}_${inspectionDate.millisecondsSinceEpoch}';
    await box.delete(key);
  }

  /// Clear all inspection submissions
  Future<void> clearAllInspectionSubmissions() async {
    final box = await _inspectionSubmissionsBox;
    await box.clear();
  }

  /// Check if there are any pending submissions (offline data)
  Future<bool> hasPendingSubmissions() async {
    final box = await _inspectionSubmissionsBox;
    return box.isNotEmpty;
  }

  /// Get count of stored submissions
  Future<int> getSubmissionsCount() async {
    final box = await _inspectionSubmissionsBox;
    return box.length;
  }

  /// Close all boxes (call this when app is disposed)
  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}
