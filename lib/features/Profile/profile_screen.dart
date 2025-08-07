import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';
import '../../shared/constant/app_colors.dart';
import '../../shared/constant/font_helper.dart';
import '../../shared/services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
        title:  Text('Profile',   style: FontHelper.ts20w700(color: Colors.white),),
        elevation: 6,
    backgroundColor: AppColors.kcPrimaryColor,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.grey.withOpacity(0.1),
      ),
     
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.kcPrimaryColor.withOpacity(0.8), Colors.blue[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.kcPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'John Anderson',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // const SizedBox(height: 8),
                    Text(
                      'Senior Marine Inspector',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'License: MI-2024-001',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Section
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Inspections\nCompleted', '247', Colors.green),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('Average\nRating', '4.8★', Colors.orange),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('Years\nExperience', '8', AppColors.kcPrimaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Profile Information
              _buildInfoSection('Personal Information', [
                _buildInfoTile('Email', 'john.anderson@marine.com', Icons.email),
                _buildInfoTile('Phone', '+1 (555) 123-4567', Icons.phone),
                _buildInfoTile('Location', 'Miami, FL', Icons.location_on),
                _buildInfoTile('License Expiry', 'Dec 31, 2025', Icons.badge),
              ]),
              const SizedBox(height: 20),

              // _buildInfoSection('Certifications', [
              //   _buildCertificationTile('Marine Safety Inspector', 'Valid until 2025'),
              //   _buildCertificationTile('Vessel Systems Expert', 'Valid until 2024'),
              //   _buildCertificationTile('Emergency Response', 'Valid until 2026'),
              // ]),
              // const SizedBox(height: 20),

              // Settings Section
              // _buildInfoSection('Settings', [
              //   _buildActionTile('Notifications', Icons.notifications, () => _openNotifications(context)),
              //   _buildActionTile('Privacy & Security', Icons.security, () => _openPrivacy(context)),
              //   _buildActionTile('Help & Support', Icons.help, () => _openSupport(context)),
              //   _buildActionTile('About', Icons.info, () => _openAbout(context)),
              // ]),
              // const SizedBox(height: 20),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationTile(String certification, String validity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.verified, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certification,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  validity,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _editProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile feature coming soon!')),
    );
  }

  void _openNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications settings coming soon!')),
    );
  }

  void _openPrivacy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings coming soon!')),
    );
  }

  void _openSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support coming soon!')),
    );
  }

  void _openAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Marine Inspection',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.directions_boat,
        size: 48,
        color: Colors.blue[900],
      ),
      children: [
        const Text('Professional marine vessel inspection application for certified inspectors.'),
      ],
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                  StorageService.instance.clear();
                                  // context.go(AppPages);
                                  // Get.find<DashboardController>().setUser(null);
                                  // print(AppFunctions.userModel!.toJson());
                Navigator.of(context).pop();
                context.go('/login');
              },
            ),
          ],
        );
      },
    );
  }
}
