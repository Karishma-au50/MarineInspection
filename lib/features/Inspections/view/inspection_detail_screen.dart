import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_inspection/shared/constant/app_colors.dart';
import 'package:marine_inspection/shared/constant/default_appbar.dart';

import '../../../models/inspection_detail_model.dart';
import '../../../routes/app_pages.dart';
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
          child: Column(
            children: [
              ...inspectionDetail.value!.sections.map((section) {
                return GestureDetector(
                  onTap: () {
                    context
                        .push(
                          AppPages.questionAnswer,
                          extra: {
                            'section': section,
                            'templateId':
                                inspectionDetail.value!.inspection.templateId,
                            'inspectionId':
                                inspectionDetail.value!.inspection.inspectionId,
                          },
                        )
                        .then((_) {
                          // Refresh statuses when returning from question screen
                          // _loadSectionStatuses();
                        });
                  },
                  child: Container(
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
                              color: section.getStatusBorderColor(),
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
                                  '${section.answers.length} inspection items',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
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
                                      color: section.getStatusBackgroundColor(),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      section.status,
                                      style: FontHelper.ts12w500(
                                        color: section.getStatusBorderColor(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }),
    );
  }
}
