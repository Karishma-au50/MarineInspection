import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:marine_inspection/models/inspection_submission_model.dart';
import 'package:marine_inspection/models/inspection_template.dart';
import 'package:marine_inspection/shared/services/storage_service.dart';
import 'package:marine_inspection/utils/network_utils.dart';

import '../../../core/expections/custom_exception.dart';
import '../../../models/inspection_detail_model.dart';
import '../../../models/inspection_model.dart';
import '../../../services/hive_service.dart';
import '../../../services/sync_service.dart';
import '../services/inspection_service.dart';
import '../../../shared/widgets/toast/my_toast.dart';

class InspectionController extends GetxController {
  final _api = InspectionService();

  // Cached data
  InspectionTemplate? _cachedTemplate;
  DateTime? _lastTemplateFetch;
  static const Duration _cacheExpiry = Duration(hours: 24);

  @override
  void onInit() {
    super.onInit();
    // Initialize sync service
    SyncService.instance.init();
  }

  /// Get inspections with offline-first approach
  Future<InspectionTemplate?> getAllInspections() async {
    try {
      // Check network connectivity first
      final isConnected = await NetworkUtils.isConnected();

      if (isConnected) {
        // When online, always fetch from API first
        try {
          log('InspectionController: Online - fetching fresh data from API');
          final res = await _api.getInspectionTemplate();
          if (res.status ?? false) {
            _cachedTemplate = res.data;
            _lastTemplateFetch = DateTime.now();

            // Cache the fresh template to disk
            if (_cachedTemplate != null) {
              final templateJson = json.encode(_cachedTemplate!.toJson());
              await HiveService.instance.cacheInspectionTemplate(templateJson);
              log('InspectionController: Fresh template cached successfully');
            }

            return res.data;
          } else {
            throw FetchDataException(res.message);
          }
        } catch (e) {
          log('InspectionController: API fetch failed: $e');
          // Fall back to cached data only when API fails
          final cachedJson = await HiveService.instance
              .getCachedInspectionTemplate();
          if (cachedJson != null) {
            final cachedData = json.decode(cachedJson);
            _cachedTemplate = InspectionTemplate.fromJson(cachedData);
            MyToasts.toastError(
              "API failed. Using cached data. Will retry next time.",
            );
            return _cachedTemplate;
          }
          throw e;
        }
      } else {
        // Offline mode - use cached data
        log('InspectionController: Offline - using cached data');

        // Try in-memory cache first
        if (_cachedTemplate != null && _isCacheValid()) {
          log('InspectionController: Using in-memory cached template');
          return _cachedTemplate;
        }

        // Then try disk cache
        final cachedJson = await HiveService.instance
            .getCachedInspectionTemplate();
        if (cachedJson != null) {
          final cachedData = json.decode(cachedJson);
          _cachedTemplate = InspectionTemplate.fromJson(cachedData);
          _lastTemplateFetch = DateTime.now();
          MyToasts.toastError("Offline mode: Using cached inspection template");
          return _cachedTemplate;
        } else {
          MyToasts.toastError(
            "No internet connection and no cached data available",
          );
          return null;
        }
      }
    } catch (e) {
      MyToasts.toastError(
        "Failed to load inspection template: ${e.toString()}",
      );
      return _cachedTemplate; // Return any available cached data as last resort
    }
  }

  /// Submit inspection with offline-first approach
  Future<bool> submitInspection(InspectionSubmission inspection) async {
    try {
      // Always save to local storage first (offline-first)
      await HiveService.instance.saveInspectionSubmission(inspection);
      log('InspectionController: Inspection saved locally');

      // Check network connectivity
      final isConnected = await NetworkUtils.isConnected();

      if (isConnected) {
        // Try to submit to server immediately
        try {
          final res = await _api.submitInspectionAnswers(
            inspectionSubmission: inspection,
          );

          if (res.status ?? false) {
            // Update local data with server response
            inspection.inspectionId = res.data?["inspection"]['inspectionId'];
            await HiveService.instance.saveInspectionSubmission(inspection);

            MyToasts.toastSuccess(
              res.message ?? "Inspection submitted successfully",
            );
            log('InspectionController: Inspection submitted to server');
            return true;
          } else {
            MyToasts.toastError(
              "Saved locally. Will sync when connection is restored.",
            );
            return true; // Still consider it successful since it's saved locally
          }
        } catch (e) {
          log('InspectionController: Server submission failed: $e');
          MyToasts.toastError(
            "Saved locally. Will sync when connection is restored.",
          );
          return true; // Still consider it successful since it's saved locally
        }
      } else {
        // Offline mode
        MyToasts.toastSuccess(
          "Inspection saved locally. Will sync when connection is restored.",
        );
        return true;
      }
    } catch (e) {
      MyToasts.toastError("Failed to save inspection: ${e.toString()}");
      return false;
    }
  }

  /// Get inspections by user ID with offline support
  Future<InspectionListResponse?> getInspectionsByUserId(String? userId) async {
    try {
      // if (userId == null || userId.isEmpty) {
      //   log('InspectionController: No user ID provided');
      //   return null;
      // }

      String usrId = userId ?? StorageService.instance.getUserId()?.id ?? '';

      // Check network connectivity first
      final isConnected = await NetworkUtils.isConnected();

      if (isConnected) {
        // When online, always fetch fresh data from API
        try {
          log(
            'InspectionController: Online - fetching fresh inspection list from API',
          );
          final res = await _api.getInspectionsByUserId(userId);
          if (res.status ?? false) {
            // Cache the fresh result
            if (res.data != null) {
              final listJson = json.encode(res.data!.toJson());
              await HiveService.instance.cacheInspectionList(usrId, listJson);
              log(
                'InspectionController: Fresh inspection list cached successfully',
              );
            }
            return res.data;
          } else {
            throw FetchDataException(res.message);
          }
        } catch (e) {
          log('InspectionController: API fetch failed: $e');
          // Fall back to cached data only when API fails
          final cachedJson = await HiveService.instance.getCachedInspectionList(
            usrId,
          );
          if (cachedJson != null) {
            final cachedData = json.decode(cachedJson);
            MyToasts.toastError(
              "API failed. Using cached data. Will retry next time.",
            );
            return InspectionListResponse.fromJson(cachedData);
          }
          throw e;
        }
      } else {
        // Offline mode - use cached data
        log('InspectionController: Offline - using cached inspection list');
        final cachedJson = await HiveService.instance.getCachedInspectionList(
          usrId,
        );
        if (cachedJson != null) {
          final cachedData = json.decode(cachedJson);
          MyToasts.toastError("Offline mode: Using cached inspection list");
          return InspectionListResponse.fromJson(cachedData);
        } else {
          MyToasts.toastError(
            "Offline mode: No cached inspection list available",
          );
          return null;
        }
      }
    } catch (e) {
      MyToasts.toastError("Failed to load inspections: ${e.toString()}");
      return null;
    }
  }

  /// Get inspection by section ID with offline support
  Future<InspectionDetailData?> getInspectionSubmissionBySectionId(
    String sectionId,
  ) async {
    try {
      // First check local storage for immediate response
      final localSubmission = await HiveService.instance
          .getInspectionSubmissionsBySectionId(sectionId);
      // Check network connectivity
      final isConnected = await NetworkUtils.isConnected();

      if (isConnected) {
        // Try to get latest from server
        try {
          final res = await _api.getInspectionBySectionId(sectionId);
          if (res.status ?? false) {
            // Cache the result
            if (res.data != null) {
              final detailsJson = json.encode(res.data!.toJson());
              await HiveService.instance.cacheInspectionDetails(
                sectionId,
                detailsJson,
              );
            }
            return res.data;
          } else {
            // Check for cached inspection details
            if (await HiveService.instance.isCacheValid(
              'inspection_details_$sectionId',
            )) {
              final cachedJson = await HiveService.instance
                  .getCachedInspectionDetails(sectionId);
              if (cachedJson != null) {
                final cachedData = json.decode(cachedJson);
                log('InspectionController: Using cached inspection details');
                return InspectionDetailData.fromJson(cachedData);
              }
            }
            // Fall back to cached data or local submission
            if (localSubmission != null) {
              MyToasts.toastError("Using local data. Server response failed.");
              // Convert local submission to InspectionDetailData if needed
              // You may need to implement this conversion based on your data structure
            }
            throw FetchDataException(res.message);
          }
        } catch (e) {
          // Fall back to cached data or local submission
          final cachedJson = await HiveService.instance
              .getCachedInspectionDetails(sectionId);
          if (cachedJson != null) {
            final cachedData = json.decode(cachedJson);
            MyToasts.toastError("Using cached data. Server connection failed.");
            return InspectionDetailData.fromJson(cachedData);
          } else if (localSubmission != null) {
            MyToasts.toastError(
              "Using local submission data. Server connection failed.",
            );
            // Convert local submission to InspectionDetailData if needed
          }
          throw e;
        }
      } else {
        // Offline mode
        final cachedJson = await HiveService.instance
            .getCachedInspectionDetails(sectionId);
        if (cachedJson != null) {
          final cachedData = json.decode(cachedJson);
          MyToasts.toastError("Offline mode: Using cached inspection data");
          return InspectionDetailData.fromJson(cachedData);
        } else if (localSubmission != null) {
          MyToasts.toastError("Offline mode: Using local inspection data");
          // Convert local submission to InspectionDetailData if needed
          // You may need to implement this conversion based on your data structure
        } else {
          MyToasts.toastError(
            "No cached or local data available for this inspection",
          );
        }
        return null;
      }
    } catch (e) {
      MyToasts.toastError("Failed to fetch inspection: ${e.toString()}");
      return null;
    }
  }

  /// Submit multiple inspections with offline-first approach
  Future<bool> submitMultipleInspections(
    List<InspectionSubmission> inspections,
  ) async {
    try {
      // Always save all to local storage first (offline-first)
      for (final inspection in inspections) {
        await HiveService.instance.saveInspectionSubmission(inspection);
      }
      log(
        'InspectionController: ${inspections.length} inspections saved locally',
      );

      // Check network connectivity
      final isConnected = await NetworkUtils.isConnected();

      if (isConnected) {
        // Try to submit to server immediately
        try {
          final res = await _api.submitMultipleInspectionAnswers(
            inspectionSubmissions: inspections,
          );

          if (res.status ?? false) {
            // Check if this was saved locally or actually submitted
            final savedLocally = res.data?["saved_locally"] == true;

            if (savedLocally) {
              MyToasts.toastSuccess(
                "${inspections.length} inspections saved locally. Will sync when connection is restored.",
              );
            } else {
              // Successfully submitted to server - remove from local storage
              for (final inspection in inspections) {
                await HiveService.instance.removeInspectionSubmission(
                  inspection,
                );
              }
              MyToasts.toastSuccess(
                "${inspections.length} inspections submitted successfully",
              );
            }

            log(
              'InspectionController: Multiple inspections processed successfully',
            );
            return true;
          } else {
            MyToasts.toastError(
              "${inspections.length} inspections saved locally. Will sync when connection is restored.",
            );
            return true; // Still consider it successful since it's saved locally
          }
        } catch (e) {
          log('InspectionController: Server submission failed: $e');
          MyToasts.toastError(
            "${inspections.length} inspections saved locally. Will sync when connection is restored.",
          );
          return true; // Still consider it successful since it's saved locally
        }
      } else {
        // Offline mode
        MyToasts.toastSuccess(
          "${inspections.length} inspections saved locally. Will sync when connection is restored.",
        );
        return true;
      }
    } catch (e) {
      MyToasts.toastError("Failed to save inspections: ${e.toString()}");
      return false;
    }
  }

  /// Force sync all pending data
  Future<void> forceSyncAll() async {
    final success = await SyncService.instance.forceSyncNow();
    if (success) {
      MyToasts.toastSuccess("All data synced successfully");
    } else {
      MyToasts.toastError("Sync completed with some errors");
    }
  }

  /// Get sync status and statistics
  Future<SyncStats> getSyncStats() async {
    return await SyncService.instance.getSyncStats();
  }

  /// Check if cached template is still valid
  bool _isCacheValid() {
    if (_lastTemplateFetch == null) return false;
    return DateTime.now().difference(_lastTemplateFetch!) < _cacheExpiry;
  }

  @override
  void onClose() {
    SyncService.instance.dispose();
    super.onClose();
  }
}
