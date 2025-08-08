import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_inspection/features/Inspections/controller/inspection_controller.dart';
import 'package:marine_inspection/models/inspection_template.dart';
import 'package:marine_inspection/routes/app_pages.dart';
import 'package:marine_inspection/shared/constant/app_colors.dart';
import 'package:marine_inspection/shared/constant/font_helper.dart';
import 'package:marine_inspection/shared/widgets/buttons/my_button.dart';
import 'package:marine_inspection/shared/widgets/toast/my_toast.dart';
import 'package:marine_inspection/services/hive_service.dart';
import 'package:marine_inspection/utils/network_utils.dart';
import 'package:marine_inspection/widgets/sync_status_widget.dart';

import '../../shared/constant/default_appbar.dart';
import '../Inspections/view/inspection_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? inspectionId;
  Rx<InspectionTemplate?> inspectionTemplate = Rx<InspectionTemplate?>(null);
  final RxBool isLoad = true.obs;
  final RxMap<String, String> sectionStatuses = <String, String>{}.obs;
  
  // Ship name controller and reactive variable
  final TextEditingController shipNameController = TextEditingController();
  final RxString shipName = ''.obs;
  final RxBool isShipNameValid = false.obs;

  // Initialize the InspectionService
  final inspectionController = Get.isRegistered<InspectionController>()
      ? Get.find<InspectionController>()
      : Get.put(InspectionController());

  @override
  void initState() {
    super.initState();
    _loadInspectionTemplate();
    _setupShipNameController();
  }

  void _setupShipNameController() {
    // Listen to ship name changes
    shipNameController.addListener(() {
      shipName.value = shipNameController.text;
      isShipNameValid.value = shipNameController.text.trim().isNotEmpty;
    });
    
    // Load saved ship name from Hive if exists
    _loadSavedShipName();
  }

  Future<void> _loadSavedShipName() async {
    try {
      // Check if there's any existing inspection with ship name
      final submissions = await HiveService.instance.getAllInspectionSubmissions();
      if (submissions.isNotEmpty) {
        final firstSubmissionWithShipName = submissions.firstWhere(
          (submission) => submission.shipName != null && submission.shipName!.isNotEmpty,
          orElse: () => submissions.first,
        );
        if (firstSubmissionWithShipName.shipName != null) {
          shipNameController.text = firstSubmissionWithShipName.shipName!;
          shipName.value = firstSubmissionWithShipName.shipName!;
          isShipNameValid.value = true;
        }
      }
    } catch (e) {
      print('Error loading saved ship name: $e');
    }
  }

  @override
  void dispose() {
    shipNameController.dispose();
    super.dispose();
  }

  Future<void> _loadInspectionTemplate() async {
    try {
      print('Loading inspection template...');
      await inspectionController.getAllInspections().then((value) async {
        if (value != null) {
          inspectionTemplate(value);
          // Load section statuses from Hive
          await _loadSectionStatuses();
        }
        isLoad.value = false;
      });
    } catch (e) {
      MyToasts.toastError("Failed to load inspection template: $e");
      print('Failed to load inspection template: $e');
      isLoad.value = false;
    }
  }

  /// Load section statuses from Hive database
  Future<void> _loadSectionStatuses() async {
    if (inspectionTemplate.value?.sections != null) {
      for (final section in inspectionTemplate.value!.sections) {
        final status = await _getSectionStatus(section.sectionId);
        sectionStatuses[section.sectionId] = status;
      }
    }
  }

  /// Get section status based on Hive data
  Future<String> _getSectionStatus(String sectionId) async {
    try {
      // Get submissions for this section from Hive
      final sectionSubmissions = await HiveService.instance
          .getInspectionSubmissionsBySectionId(sectionId);

      if (sectionSubmissions == null) {
        return 'Not Started';
      }

      inspectionId = sectionSubmissions.inspectionId;

      final section = inspectionTemplate.value?.sections.firstWhere(
        (s) => s.sectionId == sectionId,
      );

      if (section != null) {
        final requiredQuestions = section.questions
            .where((q) => q.required)
            .length;
        final answeredQuestions = sectionSubmissions.answers
            .where((a) => a.satisfied.isNotEmpty)
            .length;

        if (answeredQuestions >= requiredQuestions) {
          return 'Completed';
        } else if (answeredQuestions > 0) {
          return 'In Progress';
        }
      }

      return 'In Progress'; // Has submissions but not recent or incomplete
    } catch (e) {
      print('Error getting section status: $e');
      return 'Not Started';
    }
  }

  /// Build progress card widget
  Widget _buildProgressCard(String status, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(count.toString(), style: FontHelper.ts18w700(color: color)),
          const SizedBox(height: 4),
          Text(
            status,
            style: FontHelper.ts12w500(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
                  // Sync Status Widget
                  const SyncStatusWidget(showDetails: false),
               
                  const SizedBox(height: 16),

                  // Ship Name Input Field
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
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_boat,
                              color: AppColors.kcPrimaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ship Information',
                              style: FontHelper.ts16w600(color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: shipNameController,
                          decoration: InputDecoration(
                            labelText: 'Enter Ship Name *',
                            hintText: 'e.g., MV Ocean Explorer',
                            prefixIcon: const Icon(Icons.anchor),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.kcPrimaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            shipName.value = value;
                            isShipNameValid.value = value.trim().isNotEmpty;
                          },
                        ),
                        const SizedBox(height: 8),
                        Obx(() => Row(
                          children: [
                            Icon(
                              isShipNameValid.value ? Icons.check_circle : Icons.info,
                              color: isShipNameValid.value ? Colors.green : Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isShipNameValid.value 
                                  ? 'Ship name saved' 
                                  : 'Ship name is required before starting inspection',
                              style: TextStyle(
                                fontSize: 12,
                                color: isShipNameValid.value ? Colors.green : Colors.orange,
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress Summary Card
                  Obx(
                    () => Container(
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
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildProgressCard(
                              'Not Started',
                              sectionStatuses.values
                                  .where((s) => s == 'Not Started')
                                  .length,
                              Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildProgressCard(
                              'In Progress',
                              sectionStatuses.values
                                  .where((s) => s == 'In Progress')
                                  .length,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildProgressCard(
                              'Completed',
                              sectionStatuses.values
                                  .where((s) => s == 'Completed')
                                  .length,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Submit button: enabled only when all sections are completed
                  Obx(() {
                    final allCompleted = inspectionTemplate.value!.sections
                        .every(
                          (section) =>
                              sectionStatuses[section.sectionId] == 'Completed',
                        );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: MyButton(
                        text: "Submit Inspection",
                        color: allCompleted
                            ? AppColors.kcPrimaryColor
                            : Colors.grey,
                        onPressed: allCompleted
                            ? () async {
                              if(!(await NetworkUtils.isConnected())){
                                MyToasts.toastError(
                                  'Please check your internet connection before submitting.',
                                );
                                return;
                              }
                                // Reset all section statuses to 'Not Started'
                                for (final section
                                    in inspectionTemplate.value!.sections) {
                                  sectionStatuses[section.sectionId] =
                                      'Not Started';
                                }

                                HiveService.instance
                                    .clearAllInspectionSubmissions();
                                
                                // Clear ship name after successful submission
                                shipNameController.clear();
                                shipName.value = '';
                                isShipNameValid.value = false;
                                
                                MyToasts.toastSuccess(
                                  'Submission successful! You can start a new inspection.',
                                );
                                // Clear Hive submissions
                                // await HiveService.instance.clearAlldSubmissions();
                                setState(() {}); // Refresh UI
                              }
                            : () async {
                                MyToasts.toastError(
                                  'Please complete all sections before submitting.',
                                );
                              },
                      ),
                    );
                  }),
                  // Dynamic sections from API with status from Hive
                  ...inspectionTemplate.value!.sections.map(
                    (section) => Obx(
                      () => GestureDetector(
                        onTap: () {
                          // Validate ship name before navigation
                          if (shipName.value.trim().isEmpty) {
                            MyToasts.toastError(
                              'Please enter the ship name before starting inspection.',
                            );
                            return;
                          }
                          
                          // Navigate to question answer screen with section data and ship name
                          context
                              .push(
                                AppPages.questionAnswer,
                                extra: {
                                  'section': section,
                                  'templateId':
                                      inspectionTemplate.value!.templateId,
                                  'inspectionId': inspectionId,
                                  'shipName': shipName.value.trim(),
                                },
                              )
                              .then((_) {
                                // Refresh statuses when returning from question screen
                                _loadSectionStatuses();
                              });
                        },
                        child: InspectionCard(
                          section: section,
                          status:
                              sectionStatuses[section.sectionId] ??
                              'Not Started',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '👤 RAHUL SHIVHARE',
                    style: FontHelper.ts16w500(color: AppColors.kcPrimaryColor),
                  ),
                ],
              ),
            );
    });
  }
}
