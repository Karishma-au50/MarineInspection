import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../Admin/view/admin_home_screen.dart';
import 'home_screen.dart';

class RoleBasedHomeScreen extends StatelessWidget {
  const RoleBasedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is admin
    if (Utils.isAdmin()) {
      return const AdminHomeScreen();
    } else {
      // Default to employee home screen (inspection)
      return const HomeScreen();
    }
  }
}
