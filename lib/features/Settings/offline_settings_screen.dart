import 'package:flutter/material.dart';
import '../../services/sync_service.dart';
import '../../services/background_sync_service.dart';
import '../../services/hive_service.dart';
import '../../shared/constant/app_colors.dart';
import '../../widgets/sync_status_widget.dart';

class OfflineSettingsScreen extends StatefulWidget {
  const OfflineSettingsScreen({Key? key}) : super(key: key);

  @override
  State<OfflineSettingsScreen> createState() => _OfflineSettingsScreenState();
}

class _OfflineSettingsScreenState extends State<OfflineSettingsScreen> {
  bool _backgroundSyncEnabled = true;
  bool _autoSyncOnConnection = true;
  bool _syncOnlyOnWifi = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    // Load settings from SharedPreferences or other storage
    // For now, using default values
    setState(() {
      _backgroundSyncEnabled = true;
      _autoSyncOnConnection = true;
      _syncOnlyOnWifi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offline & Sync Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.kcPrimaryColor,
        elevation: 6,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.grey.withOpacity(0.1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sync Status Card
          const SyncStatusWidget(showDetails: true),
          
          const SizedBox(height: 24),
          
          // Sync Settings Section
          _buildSectionHeader('Sync Settings'),
          const SizedBox(height: 8),
          
          _buildSettingsCard([
            _buildSwitchTile(
              'Background Sync',
              'Automatically sync data in the background',
              Icons.sync,
              _backgroundSyncEnabled,
              (value) async {
                setState(() {
                  _backgroundSyncEnabled = value;
                });
                
                if (value) {
                  await BackgroundSyncService.instance.start();
                } else {
                  await BackgroundSyncService.instance.stop();
                }
              },
            ),
            
            _buildSwitchTile(
              'Auto-sync on Connection',
              'Automatically sync when internet connection is restored',
              Icons.wifi,
              _autoSyncOnConnection,
              (value) {
                setState(() {
                  _autoSyncOnConnection = value;
                });
                // Save to preferences
              },
            ),
            
            _buildSwitchTile(
              'WiFi Only Sync',
              'Only sync when connected to WiFi',
              Icons.wifi_lock,
              _syncOnlyOnWifi,
              (value) {
                setState(() {
                  _syncOnlyOnWifi = value;
                });
                // Save to preferences
              },
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Actions Section
          _buildSectionHeader('Actions'),
          const SizedBox(height: 8),
          
          _buildSettingsCard([
            _buildActionTile(
              'Force Sync Now',
              'Manually trigger data synchronization',
              Icons.sync_rounded,
              _forceSyncNow,
            ),
            
            _buildActionTile(
              'Clear Local Data',
              'Clear all locally stored inspection data',
              Icons.delete_outline,
              _clearLocalData,
              isDestructive: true,
            ),

            _buildActionTile(
              'Clear Cache',
              'Clear cached templates and inspection data',
              Icons.cached,
              _clearCache,
              isDestructive: true,
            ),
            
            _buildActionTile(
              'Export Local Data',
              'Export local data for backup',
              Icons.download,
              _exportLocalData,
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Info Section
          _buildSectionHeader('Offline Mode Info'),
          const SizedBox(height: 8),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.kcPrimaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'How Offline Mode Works',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kcPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• All inspection data is stored locally first\n'
                    '• Data automatically syncs when connection is available\n'
                    '• You can continue working without internet\n'
                    '• Pending submissions will be uploaded in background\n'
                    '• Templates are cached for offline use',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      secondary: Icon(icon, color: AppColors.kcPrimaryColor),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.kcPrimaryColor,
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.kcPrimaryColor,
      ),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
    );
  }

  void _forceSyncNow() async {
    try {
      final success = await SyncService.instance.forceSyncNow();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Sync completed successfully' : 'Sync completed with some errors',
          ),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearLocalData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Local Data'),
        content: const Text(
          'This will permanently delete all locally stored inspection data. '
          'Make sure your data is synced before proceeding. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Clear local submissions
        await HiveService.instance.clearAllInspectionSubmissions();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local data cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached templates and inspection data. '
          'The app will re-download this data when online. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Clear all cached data
        await HiveService.instance.clearAllCache();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _exportLocalData() async {
    try {
      // Implement data export functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export feature coming soon'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
