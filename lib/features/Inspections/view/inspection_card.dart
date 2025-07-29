
import 'package:flutter/material.dart';

import '../../../models/inspection_models.dart';
import '../../../shared/constant/font_helper.dart' show FontHelper;

class InspectionCard extends StatelessWidget {
  final InspectionSection section;

  const InspectionCard({super.key, required this.section});
  String _getSectionStatus() {
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
