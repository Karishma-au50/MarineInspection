import 'package:hive_flutter/hive_flutter.dart';
import '../models/inspection_submission_model.dart';
import '../models/inspection_answer_model.dart';
import '../models/inspection_template.dart';
import '../models/inspection_model.dart';
import '../models/inspection_detail_model.dart';
import 'file_adapter.dart';

class HiveService {
  static const String _inspectionSubmissionsBoxName = 'inspection_submissions';
  static const String _inspectionTemplateBoxName = 'inspection_template';
  static const String _inspectionListBoxName = 'inspection_list';
  static const String _inspectionDetailsBoxName = 'inspection_details';
  static const String _cacheMetadataBoxName = 'cache_metadata';
  
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

  /// Get the inspection template box
  Future<Box<String>> get _inspectionTemplateBox async {
    return await Hive.openBox<String>(_inspectionTemplateBoxName);
  }

  /// Get the inspection list box
  Future<Box<String>> get _inspectionListBox async {
    return await Hive.openBox<String>(_inspectionListBoxName);
  }

  /// Get the inspection details box
  Future<Box<String>> get _inspectionDetailsBox async {
    return await Hive.openBox<String>(_inspectionDetailsBoxName);
  }

  /// Get the cache metadata box
  Future<Box<Map<dynamic, dynamic>>> get _cacheMetadataBox async {
    return await Hive.openBox<Map<dynamic, dynamic>>(_cacheMetadataBoxName);
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

  /// Remove an inspection submission using the submission object
  Future<void> removeInspectionSubmission(InspectionSubmission submission) async {
    final box = await _inspectionSubmissionsBox;
    final key = '${submission.sectionId}_${submission.inspectionDate.millisecondsSinceEpoch}';
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

  // ==================== CACHING METHODS ====================

  /// Cache inspection template
  Future<void> cacheInspectionTemplate(String templateJson) async {
    final box = await _inspectionTemplateBox;
    await box.put('current_template', templateJson);
    await _updateCacheMetadata('inspection_template', DateTime.now());
  }

  /// Get cached inspection template
  Future<String?> getCachedInspectionTemplate() async {
    final box = await _inspectionTemplateBox;
    return box.get('current_template');
  }

  /// Cache inspection list by user ID
  Future<void> cacheInspectionList(String userId, String listJson) async {
    final box = await _inspectionListBox;
    await box.put('user_$userId', listJson);
    await _updateCacheMetadata('inspection_list_$userId', DateTime.now());
  }

  /// Get cached inspection list by user ID
  Future<String?> getCachedInspectionList(String userId) async {
    final box = await _inspectionListBox;
    return box.get('user_$userId');
  }

  /// Cache inspection details by section ID
  Future<void> cacheInspectionDetails(String sectionId, String detailsJson) async {
    final box = await _inspectionDetailsBox;
    await box.put('section_$sectionId', detailsJson);
    await _updateCacheMetadata('inspection_details_$sectionId', DateTime.now());
  }

  /// Get cached inspection details by section ID
  Future<String?> getCachedInspectionDetails(String sectionId) async {
    final box = await _inspectionDetailsBox;
    return box.get('section_$sectionId');
  }

  /// Update cache metadata
  Future<void> _updateCacheMetadata(String key, DateTime timestamp) async {
    final box = await _cacheMetadataBox;
    await box.put(key, {
      'cached_at': timestamp.millisecondsSinceEpoch,
      'expires_at': timestamp.add(const Duration(hours: 24)).millisecondsSinceEpoch,
    });
  }

  /// Check if cache is valid (not expired)
  Future<bool> isCacheValid(String key, {Duration maxAge = const Duration(hours: 24)}) async {
    final box = await _cacheMetadataBox;
    final metadata = box.get(key);
    
    if (metadata == null) return false;
    
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(metadata['cached_at']);
    final now = DateTime.now();
    
    return now.difference(cachedAt) < maxAge;
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    final templateBox = await _inspectionTemplateBox;
    final listBox = await _inspectionListBox;
    final detailsBox = await _inspectionDetailsBox;
    final metadataBox = await _cacheMetadataBox;
    
    await Future.wait([
      templateBox.clear(),
      listBox.clear(),
      detailsBox.clear(),
      metadataBox.clear(),
    ]);
  }

  // clear all give data
  Future<void> clearAllData() async {
    await clearAllInspectionSubmissions();
    await clearAllCache();
    
    // Close all boxes
    await closeBoxes();
    
    // Reinitialize Hive
    await init();
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final metadataBox = await _cacheMetadataBox;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredKeys = <String>[];
    
    for (final entry in metadataBox.toMap().entries) {
      final metadata = entry.value;
      final expiresAt = metadata['expires_at'] as int;
      
      if (now > expiresAt) {
        expiredKeys.add(entry.key as String);
      }
    }
    
    // Remove expired entries from all boxes
    for (final key in expiredKeys) {
      await metadataBox.delete(key);
      
      if (key.startsWith('inspection_template')) {
        final templateBox = await _inspectionTemplateBox;
        await templateBox.clear();
      } else if (key.startsWith('inspection_list_')) {
        final listBox = await _inspectionListBox;
        final userId = key.replaceFirst('inspection_list_', '');
        await listBox.delete('user_$userId');
      } else if (key.startsWith('inspection_details_')) {
        final detailsBox = await _inspectionDetailsBox;
        final sectionId = key.replaceFirst('inspection_details_', '');
        await detailsBox.delete('section_$sectionId');
      }
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final templateBox = await _inspectionTemplateBox;
    final listBox = await _inspectionListBox;
    final detailsBox = await _inspectionDetailsBox;
    final metadataBox = await _cacheMetadataBox;
    
    return {
      'template_cached': templateBox.containsKey('current_template'),
      'inspection_lists_count': listBox.length,
      'inspection_details_count': detailsBox.length,
      'total_cache_entries': metadataBox.length,
      'submission_count': await getSubmissionsCount(),
    };
  }
}
