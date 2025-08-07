import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/sync_service.dart';
import '../utils/network_utils.dart';
import '../shared/constant/app_colors.dart';

class SyncStatusWidget extends StatefulWidget {
  final bool showDetails;
  
  const SyncStatusWidget({
    Key? key,
    this.showDetails = false,
  }) : super(key: key);

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  SyncStatus _currentStatus = SyncStatus.idle;
  bool _isOnline = false;
  int _pendingCount = 0;
  Map<String, dynamic> _cacheStats = {};

  @override
  void initState() {
    super.initState();
    _initializeStatus();
    _listenToSyncStatus();
    _listenToNetworkChanges();
  }

  void _initializeStatus() async {
    final stats = await SyncService.instance.getSyncStats();
    
    setState(() {
      _currentStatus = stats.lastSyncStatus;
      _isOnline = stats.hasNetworkConnection;
      _pendingCount = stats.pendingSubmissions;
      _cacheStats = stats.cacheStats;
    });
  }

  void _listenToSyncStatus() {
    SyncService.instance.syncStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
        });
      }
    });
  }

  void _listenToNetworkChanges() {
    NetworkUtils.connectivityStream.listen((connectivityResults) async {
      final isConnected = await NetworkUtils.isConnected();
      if (mounted) {
        setState(() {
          _isOnline = isConnected;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showDetails) {
      return _buildCompactView();
    }
    return _buildDetailedView();
  }

  Widget _buildCompactView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 16,
            color: _getStatusColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 12,
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_pendingCount > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_pendingCount',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedView() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  'Sync Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusRow('Connection', _isOnline ? 'Online' : 'Offline', 
                _isOnline ? Icons.wifi : Icons.wifi_off),
            _buildStatusRow('Status', _getStatusText(), _getStatusIcon()),
            if (_pendingCount > 0)
              _buildStatusRow('Pending', '$_pendingCount items', Icons.pending),
            if (_cacheStats.isNotEmpty) ...[
              _buildStatusRow('Template Cached', 
                  _cacheStats['template_cached'] == true ? 'Yes' : 'No', 
                  _cacheStats['template_cached'] == true ? Icons.check : Icons.close),
              _buildStatusRow('Cached Lists', 
                  '${_cacheStats['inspection_lists_count'] ?? 0}', 
                  Icons.list),
              _buildStatusRow('Cached Details', 
                  '${_cacheStats['inspection_details_count'] ?? 0}', 
                  Icons.description),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentStatus == SyncStatus.syncing ? null : _forceSync,
                    icon: _currentStatus == SyncStatus.syncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(_currentStatus == SyncStatus.syncing ? 'Syncing...' : 'Sync Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kcPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _forceSync() async {
    final controller = Get.find<dynamic>();
    if (controller != null && controller.runtimeType.toString().contains('InspectionController')) {
      await controller.forceSyncAll();
      _initializeStatus(); // Refresh status
    }
  }

  Color _getStatusColor() {
    if (!_isOnline) return Colors.grey;
    
    switch (_currentStatus) {
      case SyncStatus.idle:
        return Colors.blue;
      case SyncStatus.syncing:
        return Colors.orange;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.partialSuccess:
        return Colors.amber;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.noNetwork:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    if (!_isOnline) return Icons.wifi_off;
    
    switch (_currentStatus) {
      case SyncStatus.idle:
        return Icons.sync;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.success:
        return Icons.check_circle;
      case SyncStatus.partialSuccess:
        return Icons.warning;
      case SyncStatus.error:
        return Icons.error;
      case SyncStatus.noNetwork:
        return Icons.wifi_off;
    }
  }

  String _getStatusText() {
    if (!_isOnline) return 'Offline';
    
    switch (_currentStatus) {
      case SyncStatus.idle:
        return 'Ready';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.success:
        return 'Synced';
      case SyncStatus.partialSuccess:
        return 'Partial';
      case SyncStatus.error:
        return 'Error';
      case SyncStatus.noNetwork:
        return 'No Network';
    }
  }
}
