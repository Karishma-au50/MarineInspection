import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_inspection/routes/app_pages.dart';
import 'package:marine_inspection/shared/constant/app_colors.dart';
import 'package:marine_inspection/shared/constant/font_helper.dart';
import 'package:marine_inspection/models/inspection_template.dart';
import 'package:marine_inspection/services/inspection_service.dart';

import '../../shared/constant/default_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  InspectionTemplate? inspectionTemplate;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInspectionTemplate();
  }

  Future<void> _loadInspectionTemplate() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Use getMockInspectionTemplate() for testing, 
      // Replace with getInspectionTemplate() when API is ready
      final template = await InspectionService.getMockInspectionTemplate();
      
      setState(() {
        inspectionTemplate = template;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load inspection template: $e';
        isLoading = false;
      });
    }
  }

  // Calculate overall progress based on section completion (you can implement based on your logic)
  double get overallProgress {
    if (inspectionTemplate == null || inspectionTemplate!.sections.isEmpty) {
      return 0.0;
    }
    
    // For now, returning a mock progress. You can implement actual progress tracking
    // by storing completion status in shared preferences or a local database
    return 0.3; // 30% as example
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: defaultAppBar(context),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading inspection template...')
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: FontHelper.ts18w600(color: Colors.black),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: FontHelper.ts14w400(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInspectionTemplate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kcPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (inspectionTemplate == null) {
      return const Center(
        child: Text('No inspection template available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Container(
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: FontHelper.ts16w700(color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  inspectionTemplate!.templateName,
                  style: FontHelper.ts14w600(color: AppColors.kcPrimaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vessel Type: ${inspectionTemplate!.vesselType}',
                  style: FontHelper.ts12w400(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please select a section to begin inspection',
                  style: FontHelper.ts14w400(color: Colors.black),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            padding: const EdgeInsets.all(16.0),
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
                Row(
                  children: [
                    Text(
                      'Overall Progress',
                      style: FontHelper.ts14w500(color: Colors.black),
                    ),
                    const Spacer(),
                    Text(
                      '${(overallProgress * 100).round()}%',
                      style: FontHelper.ts14w500(
                        color: AppColors.kcPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: overallProgress,
                  color: AppColors.kcPrimaryColor,
                  backgroundColor: Colors.grey.shade200,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Dynamic sections from API
          ...inspectionTemplate!.sections.map((section) => GestureDetector(
            onTap: () {
              // Navigate to question answer screen with section data
              context.push(
                AppPages.questionAnswer,
                extra: {
                  'section': section,
                  'templateId': inspectionTemplate!.templateId,
                }
              );
            },
            child: InspectionCard(section: section),
          )),
        ],
      ),
    );
  }
}

class InspectionCard extends StatelessWidget {
  final InspectionSection section;

  const InspectionCard({super.key, required this.section});

  // Helper method to get status (you can implement based on completion tracking)
  String _getSectionStatus() {
    // For now returning 'Not Started' as default
    // You can implement logic to check if section is completed, in progress, etc.
    // by storing progress in SharedPreferences or local database
    return 'Not Started';
  }

  // Helper method to get colors based on status
  Map<String, Color> _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
      case 'pending':
        return {
          'background': Colors.orange.shade100,
          'border': Colors.orange.shade400,
        };
      case 'not started':
        return {
          'background': Colors.grey.shade100,
          'border': Colors.grey.shade500,
        };
      case 'completed':
        return {
          'background': Colors.green.shade100,
          'border': Colors.green.shade600,
        };
      default:
        return {
          'background': Colors.grey.shade100,
          'border': Colors.grey.shade400,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _getSectionStatus();
    final statusColors = _getStatusColors(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left rounded border strip
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColors['border']!,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),

            // Main card content
            Expanded(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                title: Text(
                  section.sectionName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${section.questions.length} inspection items',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColors['background']!,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: FontHelper.ts12w500(
                          color: statusColors['border']!,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
