import 'package:flutter/material.dart';
import 'package:marine_inspection/services/hive_service.dart';
import 'package:marine_inspection/services/sync_service.dart';
import 'package:marine_inspection/services/background_sync_service.dart';
import 'package:marine_inspection/shared/services/storage_service.dart';
import 'package:marine_inspection/widgets/offline_banner.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await HiveService.init();
  
  // Initialize SharedPreferences storage service
  await StorageService.instance.init();
  
  // Initialize sync service
  await SyncService.instance.init();
  
  // Initialize background sync service
  await BackgroundSyncService.instance.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Marine Inspection',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
      builder: (context, child) {
        // Wrap the entire app with the offline banner
        return OfflineBanner(child: child ?? const SizedBox());
      },
    );
  }
}
