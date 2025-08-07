import 'dart:developer';
import 'package:background_fetch/background_fetch.dart';
import '../services/sync_service.dart';

class BackgroundSyncService {
  static BackgroundSyncService? _instance;
  static BackgroundSyncService get instance => _instance ??= BackgroundSyncService._();
  BackgroundSyncService._();

  /// Initialize background sync
  Future<void> init() async {
    try {
      // Configure background fetch
      await BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15, // 15 minutes
          stopOnTerminate: false,
          enableHeadless: true,
          startOnBoot: true,
        ),
        _onBackgroundFetch,
        _onBackgroundFetchTimeout,
      );

      log('BackgroundSyncService: Background fetch configured');
    } catch (e) {
      log('BackgroundSyncService: Failed to configure background fetch: $e');
    }
  }

  /// Background fetch event handler
  static Future<void> _onBackgroundFetch(String taskId) async {
    log('BackgroundSyncService: Background fetch triggered: $taskId');
    
    try {
      // Perform sync
      final success = await SyncService.instance.syncAll();
      
      if (success) {
        log('BackgroundSyncService: Background sync completed successfully');
      } else {
        log('BackgroundSyncService: Background sync completed with errors');
      }
    } catch (e) {
      log('BackgroundSyncService: Background sync failed: $e');
    }

    // IMPORTANT: You must signal completion of your background task
    BackgroundFetch.finish(taskId);
  }

  /// Background fetch timeout handler
  static Future<void> _onBackgroundFetchTimeout(String taskId) async {
    log('BackgroundSyncService: Background fetch timeout: $taskId');
    
    // IMPORTANT: You must signal completion even on timeout
    BackgroundFetch.finish(taskId);
  }

  /// Start background sync
  Future<void> start() async {
    try {
      await BackgroundFetch.start();
      log('BackgroundSyncService: Background sync started');
    } catch (e) {
      log('BackgroundSyncService: Failed to start background sync: $e');
    }
  }

  /// Stop background sync
  Future<void> stop() async {
    try {
      await BackgroundFetch.stop();
      log('BackgroundSyncService: Background sync stopped');
    } catch (e) {
      log('BackgroundSyncService: Failed to stop background sync: $e');
    }
  }

  /// Get background fetch status
  Future<int> getStatus() async {
    return await BackgroundFetch.status;
  }
}

/// Background fetch headless task (for when app is terminated)
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  final taskId = task.taskId;
  final isTimeout = task.timeout;
  
  log('BackgroundSyncService: Headless task triggered: $taskId, timeout: $isTimeout');
  
  if (isTimeout) {
    BackgroundFetch.finish(taskId);
    return;
  }

  try {
    // Initialize services for headless execution
    // Note: You might need to initialize Hive and other services here
    
    // Perform sync
    await SyncService.instance.syncAll();
    
    log('BackgroundSyncService: Headless sync completed');
  } catch (e) {
    log('BackgroundSyncService: Headless sync failed: $e');
  }

  BackgroundFetch.finish(taskId);
}
