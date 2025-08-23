import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:marine_inspection/shared/services/storage_service.dart';
import 'package:marine_inspection/utils/network_utils.dart';
import '../core/model/response_model.dart';
import '../features/Inspections/services/inspection_service.dart';
import '../models/inspection_submission_model.dart';
import '../models/inspection_template.dart';
import '../utils/utils.dart';
import 'hive_service.dart';
import '../shared/widgets/toast/my_toast.dart';

class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._();
  SyncService._();

  final InspectionService _inspectionService = InspectionService();
  Timer? _syncTimer;
  bool _isSyncing = false;

  static const Duration _syncInterval = Duration(minutes: 5);

  // Stream controllers for real-time sync status
  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  /// Initialize the sync service
  Future<void> init() async {
    log('SyncService: Initializing...');

    // Start periodic background sync
    startPeriodicSync();

    // Listen to network changes for auto-sync
    NetworkUtils.connectivityStream.listen((connectivityResults) {
      if (connectivityResults.isNotEmpty) {
        _onNetworkConnected();
      }
    });

    log('SyncService: Initialized successfully');
  }

  /// Start periodic background sync
  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      if (!_isSyncing) {
        syncAll();
      }
    });
    log('SyncService: Periodic sync started');
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    log('SyncService: Periodic sync stopped');
  }

  /// Handle network reconnection
  void _onNetworkConnected() async {
    log('SyncService: Network connected, starting sync...');
    if (!_isSyncing) {
      await syncAll();
    }
  }

  /// Sync all pending data
  Future<bool> syncAll() async {
    if (_isSyncing) {
      log('SyncService: Sync already in progress');
      return false;
    }

    _updateSyncStatus(SyncStatus.syncing);
    _isSyncing = true;

    try {
      // Check network connectivity
      if (!await NetworkUtils.isConnected()) {
        log('SyncService: No network connection available');
        _updateSyncStatus(SyncStatus.noNetwork);
        return false;
      }

      bool allSuccess = true;

      // 1. Clear expired cache first
      await HiveService.instance.clearExpiredCache();

      // 2. Sync pending submissions
      final pendingSubmissions = await HiveService.instance
          .getAllInspectionSubmissions();
      if (pendingSubmissions.isNotEmpty) {
        log(
          'SyncService: Found ${pendingSubmissions.length} pending submissions',
        );
        allSuccess &= await _syncSubmissions(pendingSubmissions);
      }

      // 3. Sync and cache inspection template
      allSuccess &= await _syncAndCacheInspectionTemplate();

      // 4. Sync and cache inspection lists (if user is logged in)
      allSuccess &= await _syncAndCacheInspectionLists();

      // 5. Sync and cache inspection details for recent inspections
      allSuccess &= await _syncAndCacheInspectionDetails();

      if (allSuccess) {
        _updateSyncStatus(SyncStatus.success);
        log('SyncService: All data synced and cached successfully');
      } else {
        _updateSyncStatus(SyncStatus.partialSuccess);
        log('SyncService: Partial sync completed');
      }

      return allSuccess;
    } catch (e) {
      log('SyncService: Sync failed with error: $e');
      _updateSyncStatus(SyncStatus.error);
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync pending submissions to server
  Future<bool> _syncSubmissions(List<InspectionSubmission> submissions) async {
    if (submissions.isEmpty) {
      return true;
    }

    var pendingSubmissions = submissions
        .where((s) => s.inspectionId == null || s.inspectionId!.isEmpty)
        .toList();

    try {
      // Use the new multiple submissions API
      final response = await _inspectionService.submitMultipleInspectionAnswers(
        inspectionSubmissions: pendingSubmissions,
      );

      if (response.status == true) {
        // Update all submissions with server response
        final responseData = response.data;
        if (responseData != null && responseData is Map) {
          // Handle successful bulk submission
          for (int i = 0; i < pendingSubmissions.length; i++) {
            final submission = pendingSubmissions[i];

            // Update submission with server response if available
            if (responseData["inspections"] != null &&
                responseData["inspections"] is List &&
                i < responseData["inspections"].length) {
              final inspectionData = responseData["inspections"][i];
              if (inspectionData != null &&
                  inspectionData["inspectionId"] != null) {
                submission.inspectionId = inspectionData["inspectionId"];
              }
            }

            // // Remove successfully synced submission from local storage
            // await HiveService.instance.removeInspectionSubmission(submission);

            if (await _isAllSubmissionsSynced(pendingSubmissions.length)) {
              await HiveService.instance.removeInspectionSubmission(submission);
            }
          }
        }
        // else {
        //   // If no specific response data, still remove submissions as they were accepted
        //   for (final submission in submissions) {
        //     await HiveService.instance.removeInspectionSubmission(submission);
        //   }
        // }

        log(
          'SyncService: ${pendingSubmissions.length} submissions synced and removed from local storage',
        );
        MyToasts.toastSuccess(
          '${pendingSubmissions.length} submissions synced successfully',
        );
        return true;
      } else {
        log(
          'SyncService: Failed to sync multiple submissions: ${response.message}',
        );
        MyToasts.toastError('Failed to sync submissions: ${response.message}');
        return false;
      }
    } catch (e) {
      log('SyncService: Error syncing multiple submissions: $e');

      // Fallback to individual submission if bulk fails
      log('SyncService: Falling back to individual submission sync');
      return await _syncSubmissionsIndividually(submissions);
    }
  }

  /// Fallback method to sync submissions individually
  Future<bool> _syncSubmissionsIndividually(
    List<InspectionSubmission> submissions,
  ) async {
    int successCount = 0;

    var pendingSubmissions = submissions
        .where((s) => s.inspectionId == null || s.inspectionId!.isEmpty)
        .toList();

    for (final submission in pendingSubmissions) {
      try {
        final response = await _inspectionService.submitInspectionAnswers(
          inspectionSubmission: submission,
        );

        if (response.status == true) {
          // Update submission with server response
          submission.inspectionId =
              response.data?["inspection"]?['inspectionId'];

          // Remove successfully synced submission from local storage
          // await HiveService.instance.removeInspectionSubmission(submission);
          if (await _isAllSubmissionsSynced(pendingSubmissions.length)) {
            await HiveService.instance.removeInspectionSubmission(submission);
          }

          successCount++;
          log(
            'SyncService: Submission synced and removed for section ${submission.sectionId}',
          );
        } else {
          log(
            'SyncService: Failed to sync submission for section ${submission.sectionId}: ${response.message}',
          );
        }
      } catch (e) {
        log(
          'SyncService: Error syncing submission for section ${submission.sectionId}: $e',
        );
      }
    }

    final isSuccess = successCount == pendingSubmissions.length;
    if (isSuccess) {
      MyToasts.toastSuccess('$successCount submissions synced successfully');
    } else {
      MyToasts.toastError(
        '$successCount of ${pendingSubmissions.length} submissions synced',
      );
    }

    return isSuccess;
  }

  Future<bool> _isAllSubmissionsSynced(int submissionCount) async {
    String? cachedTemplate = await HiveService.instance
        .getCachedInspectionTemplate();
    ResponseModel<InspectionTemplate?> template = jsonDecode(cachedTemplate!);
    return template.data?.sections.length == submissionCount;
  }

  /// Sync inspection templates from server
  Future<bool> _syncAndCacheInspectionTemplate() async {
    try {
      // Check if we have valid cached template
      if (await HiveService.instance.isCacheValid('inspection_template')) {
        log('SyncService: Using valid cached inspection template');
        return true;
      }

      final response = await _inspectionService.getInspectionTemplate();

      if (response.status == true && response.data != null) {
        // Cache the template as JSON
        final templateJson = jsonEncode(response.data!.toJson());
        await HiveService.instance.cacheInspectionTemplate(templateJson);
        log('SyncService: Inspection template synced and cached successfully');
        return true;
      } else {
        log(
          'SyncService: Failed to sync inspection template: ${response.message}',
        );
        return false;
      }
    } catch (e) {
      log('SyncService: Error syncing inspection template: $e');
      return false;
    }
  }

  /// Sync and cache inspection lists
  Future<bool> _syncAndCacheInspectionLists() async {
    try {
      // Get current user ID (you may need to implement this based on your auth system)
      final userId = await _getCurrentUserId();
      if (userId == null) {
        log('SyncService: No user logged in, skipping inspection list sync');
        return true;
      }

      // Check if we have valid cached list
      if (await HiveService.instance.isCacheValid('inspection_list_$userId')) {
        log('SyncService: Using valid cached inspection list');
        return true;
      }

      final response = await _inspectionService.getInspectionsByUserId(userId);

      // Cache the inspection list as JSON
      final listJson = jsonEncode(response.toJson());
      await HiveService.instance.cacheInspectionList(userId, listJson);
      log('SyncService: Inspection list synced and cached successfully');
      return true;
    } catch (e) {
      log('SyncService: Error syncing inspection list: $e');
      return false;
    }
  }

  /// Sync and cache inspection details for recent sections
  Future<bool> _syncAndCacheInspectionDetails() async {
    try {
      // Get recently accessed sections from local submissions
      final submissions = await HiveService.instance
          .getAllInspectionSubmissions();
      final recentSectionIds = submissions
          .where(
            (s) => s.inspectionDate.isAfter(
              DateTime.now().subtract(const Duration(days: 7)),
            ),
          )
          .map((s) => s.sectionId)
          .toSet();

      bool allSuccess = true;

      for (final sectionId in recentSectionIds) {
        try {
          // Check if we have valid cached details
          if (await HiveService.instance.isCacheValid(
            'inspection_details_$sectionId',
          )) {
            log(
              'SyncService: Using valid cached details for section $sectionId',
            );
            continue;
          }

          final response = await _inspectionService.getInspectionBySectionId(
            sectionId,
          );

          // Cache the inspection details as JSON
          final detailsJson = jsonEncode(response.toJson());
          await HiveService.instance.cacheInspectionDetails(
            sectionId,
            detailsJson,
          );
          log(
            'SyncService: Details for section $sectionId synced and cached successfully',
          );
        } catch (e) {
          log('SyncService: Error syncing details for section $sectionId: $e');
          allSuccess = false;
        }
      }

      return allSuccess;
    } catch (e) {
      log('SyncService: Error syncing inspection details: $e');
      return false;
    }
  }

  /// Get current user ID (implement based on your auth system)
  Future<String?> _getCurrentUserId() async {
    // You'll need to implement this based on your authentication system
    // For example, from StorageService or SharedPreferences
    try {
      // This is a placeholder - replace with your actual user ID retrieval
      return Utils.isEmployee()
          ? StorageService.instance.getUserId()?.id
          : null;
      // Replace with actual implementation
    } catch (e) {
      log('SyncService: Error getting current user ID: $e');
      return null;
    }
  }

  /// Force sync now (manual trigger)
  Future<bool> forceSyncNow() async {
    log('SyncService: Manual sync triggered');
    return await syncAll();
  }

  /// Get sync statistics
  Future<SyncStats> getSyncStats() async {
    final pendingCount = await HiveService.instance.getSubmissionsCount();
    final hasNetwork = await NetworkUtils.isConnected();
    final cacheStats = await HiveService.instance.getCacheStats();

    return SyncStats(
      pendingSubmissions: pendingCount,
      hasNetworkConnection: hasNetwork,
      lastSyncStatus: _currentStatus,
      lastSyncTime: DateTime.now(), // You might want to store this in Hive
      cacheStats: cacheStats,
    );
  }

  /// Update sync status and notify listeners
  void _updateSyncStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}

/// Sync status enum
enum SyncStatus { idle, syncing, success, partialSuccess, error, noNetwork }

/// Sync statistics model
class SyncStats {
  final int pendingSubmissions;
  final bool hasNetworkConnection;
  final SyncStatus lastSyncStatus;
  final DateTime lastSyncTime;
  final Map<String, dynamic> cacheStats;

  SyncStats({
    required this.pendingSubmissions,
    required this.hasNetworkConnection,
    required this.lastSyncStatus,
    required this.lastSyncTime,
    required this.cacheStats,
  });
}
