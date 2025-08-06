import 'package:flutter/material.dart';
import 'package:marine_inspection/services/hive_service.dart';
import 'package:marine_inspection/shared/services/storage_service.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await HiveService.init();
  
  // Initialize SharedPreferences storage service
  await StorageService.instance.init();
  
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
    );
  }
}
