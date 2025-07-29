import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_inspection/features/Inspections/controller/inspection_controller.dart';
import 'package:marine_inspection/models/inspection_template.dart';
import 'package:marine_inspection/routes/app_pages.dart';
import 'package:marine_inspection/shared/constant/app_colors.dart';
import 'package:marine_inspection/shared/constant/font_helper.dart';
import 'package:marine_inspection/shared/widgets/toast/my_toast.dart';

import '../../shared/constant/default_appbar.dart';
import '../Inspections/view/inspection_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Rx<InspectionTemplate?> inspectionTemplate = Rx<InspectionTemplate?>(null);
  final RxBool isLoad = true.obs;

  // Initialize the InspectionService
  final inspectionController = Get.isRegistered<InspectionController>()
      ? Get.find<InspectionController>()
      : Get.put(InspectionController());

  @override
  void initState() {
    super.initState();
    _loadInspectionTemplate();
  }

  Future<void> _loadInspectionTemplate() async {
    try {
      print('Loading inspection template...');
      await inspectionController.getAllInspections().then((value) {
        if (value != null) {
          inspectionTemplate(value);
        }
        isLoad.value = false;
      });
    } catch (e) {
      MyToasts.toastError("Failed to load inspection template: $e");
      print('Failed to load inspection template: $e');
      isLoad.value = false;
    }
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
    return Obx(() {
      return isLoad.value
          ? const Center(child: CircularProgressIndicator())
          : inspectionTemplate.value == null
          ? Center(
              child: Text(
                'No inspection template available',
                style: FontHelper.ts14w400(color: Colors.red),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
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
                          inspectionTemplate.value!.templateName,
                          style: FontHelper.ts14w600(
                            color: AppColors.kcPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vessel Type: ${inspectionTemplate.value!.vesselType}',
                          style: FontHelper.ts12w400(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please select a section to begin inspection',
                          style: FontHelper.ts14w400(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Dynamic sections from API
                  ...inspectionTemplate.value!.sections.map(
                    (section) => GestureDetector(
                      onTap: () {
                        // Navigate to question answer screen with section data
                        context.push(
                          AppPages.questionAnswer,
                          extra: {
                            'section': section,
                            'templateId': inspectionTemplate.value!.templateId,
                          },
                        );
                      },
                      child: InspectionCard(section: section),
                    ),
                  ),
                ],
              ),
            );
    });
  }
}
