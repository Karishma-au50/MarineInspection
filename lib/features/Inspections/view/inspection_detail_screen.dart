import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_inspection/shared/constant/app_colors.dart';
import 'package:marine_inspection/shared/constant/default_appbar.dart';

import '../../../models/inspection_detail_model.dart';
import '../../../shared/constant/font_helper.dart';
import '../../../shared/widgets/toast/my_toast.dart';
import '../controller/inspection_controller.dart';

class InspectionDetailScreen extends StatefulWidget {
  final String sectionId;

  const InspectionDetailScreen({super.key, required this.sectionId});

  @override
  State<InspectionDetailScreen> createState() => _State();
}

class _State extends State<InspectionDetailScreen> {
  final inspectionController = Get.isRegistered<InspectionController>()
      ? Get.find<InspectionController>()
      : Get.put(InspectionController());
  Rx<InspectionDetailData?> inspectionDetail = Rx<InspectionDetailData?>(null);
  final RxBool isLoad = true.obs;
  @override
  void initState() {
    super.initState();
    // Load inspection details based on sectionId
    try {
      _loadInspectionDetail();
    } catch (e) {
      MyToasts.toastError("Failed to load inspection details: $e");
      isLoad.value = false;
    }
  }

  Future<void> _loadInspectionDetail() async {
    try {
      isLoad.value = true;
      final detail = await inspectionController
          .getInspectionSubmissionBySectionId(widget.sectionId);
      if (detail != null) {
        inspectionDetail.value = detail;
      } else {
        MyToasts.toastError("No inspection details found for this section");
      }
    } catch (e) {
      MyToasts.toastError("Failed to load inspection details: $e");
      MyToasts.toastError("Failed to load inspection details");
    }
    isLoad.value = false;
  }

  @override
  Widget build(BuildContext context) {
    //  final status = _getSectionStatus();
    // final statusColors = _getStatusColors(status);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: defaultAppBar(
        context,
        title: 'Inspection Details',
        isLeading: true,
      ),
      body: Obx(() {
        if (isLoad.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (inspectionDetail.value == null) {
          return const Center(child: Text('No inspection details available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inspection Header Info
              // _buildInspectionHeader(),
              // const SizedBox(height: 16),
              
           
              
              ...inspectionDetail.value!.sections.map((section) {
                return _buildExpandableSection(section);
              }).toList(),
            ],
          ),
        );
      }),
    );
  }

  // Widget _buildInspectionHeader() {
  //   final inspection = inspectionDetail.value!.inspection;
  //   return Card(
  //     elevation: 4,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(
  //                 Icons.directions_boat,
  //                 color: AppColors.kcPrimaryColor,
  //                 size: 28,
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Text(
  //                   inspection.templateName,
  //                   style: FontHelper.ts16w700(color: Colors.black),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 12),
  //           _buildInfoRow('Inspection ID', inspection.inspectionId),
  //           _buildInfoRow('Inspector', inspection.inspectorId.name),
  //           _buildInfoRow('Status', _getStatusText(inspection.overallStatus)),
  //           _buildInfoRow('Location', inspection.location.isEmpty ? 'Not specified' : inspection.location),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: FontHelper.ts12w500(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: FontHelper.ts12w400(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(InspectionSection section) {
    return Container(
        margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
     child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          childrenPadding: const EdgeInsets.only(bottom: 16),
          
          leading: Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: _getSectionStatusColor(section.status),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          title: Text(
            section.sectionName,
            style: FontHelper.ts14w600(color: Colors.black),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 2),
              Text(
                '${section.answers.length} questions',
                style: FontHelper.ts12w400(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSectionStatusColor(section.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  section.status.toUpperCase(),
                  style: FontHelper.ts10w600(color: _getSectionStatusColor(section.status)),
                ),
              ),
            ],
          ),
          children: [
            if (section.answers.isNotEmpty)
              ...section.answers.map((answer) => _buildQuestionAnswerCard(answer)).toList()
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No questions answered in this section',
                  style: FontHelper.ts12w400(color: Colors.grey[500]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionAnswerCard(QuestionAnswer answer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${answer.questionId}',
                      style: FontHelper.ts12w600(color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _cleanHtmlText(answer.questionText),
                      style: FontHelper.ts12w400(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAnswerStatusColor(answer.satisfied).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getAnswerStatusColor(answer.satisfied).withOpacity(0.3)),
                ),
                child: Text(
                  answer.satisfied.toUpperCase(),
                  style: FontHelper.ts10w600(color: _getAnswerStatusColor(answer.satisfied)),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Comments section
          if (answer.comments.isNotEmpty) ...[
            Text(
              'Comments:',
              style: FontHelper.ts12w600(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              answer.comments,
              style: FontHelper.ts12w400(color: Colors.black),
            ),
            const SizedBox(height: 12),
          ],
          
          // File uploads section
          if (answer.fileUploads.isNotEmpty) ...[
            Text(
              'Attachments (${answer.fileUploads.length}):',
              style: FontHelper.ts12w600(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: answer.fileUploads.map((file) => _buildFileChip(file)).toList(),
            ),
          ],
          
          // Timestamp
          const SizedBox(height: 8),
          Text(
            'Answered: ${_formatTimestamp(answer.timestamp)}',
            style: FontHelper.ts10w400(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildFileChip(FileUpload file) {
    final fileName = file.filename ?? file.originalName ?? 'Unknown file';
    final isImage = file.mimetype?.startsWith('image/') ?? false;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isImage ? Icons.image : Icons.attach_file,
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              fileName,
              style: FontHelper.ts10w400(color: Colors.blue),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSectionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in-progress':
        return Colors.orange;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getAnswerStatusColor(String satisfied) {
    switch (satisfied.toLowerCase()) {
      case 'yes':
        return Colors.green;
      case 'no':
        return Colors.red;
      case 'notapplicable':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _cleanHtmlText(String htmlText) {
    // Remove HTML tags and decode entities
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&#9679;', '•')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}
