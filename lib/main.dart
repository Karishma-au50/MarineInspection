import 'package:flutter/material.dart';
import 'package:marine_inspection/shared/services/storage_service.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize any services or dependencies here
  // For example, you might want to initialize a database or a service locator
  StorageService.instance.init(); // Uncomment if you have a StorageService
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
