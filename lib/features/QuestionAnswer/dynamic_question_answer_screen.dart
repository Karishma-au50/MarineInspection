import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marine_inspection/features/Inspections/controller/inspection_controller.dart';
import 'package:marine_inspection/routes/app_pages.dart';
import 'package:marine_inspection/shared/constant/default_appbar.dart';
import 'package:marine_inspection/shared/constant/font_helper.dart';
import 'package:marine_inspection/models/inspection_template.dart';

import '../../models/inspection_answer_model.dart';
import '../../models/inspection_submission_model.dart';
import '../../services/hive_service.dart';
import '../../shared/constant/app_colors.dart';

class QuestionAnswerScreen extends StatefulWidget {
  final InspectionSection? section;
  final String? templateId;
  final String? inspectionId;
  final String? shipName;

  const QuestionAnswerScreen({
    super.key, 
    this.section, 
    this.templateId, 
    this.inspectionId,
    this.shipName,
  });

  @override
  State<QuestionAnswerScreen> createState() => _QuestionAnswerScreenState();
}

class _QuestionAnswerScreenState extends State<QuestionAnswerScreen> {
  // Map to store answers for each question
  Map<String, dynamic> selectedAnswers = {};
  InspectionSubmission inspectionSubmissions = InspectionSubmission(
    answers: [],
    inspectionDate: DateTime.now(),
    sectionId: "",
    inspectionId: "",
    shipName: "",
  );
  final InspectionController inspectionController =
      Get.isRegistered<InspectionController>()
      ? Get.find<InspectionController>()
      : Get.put(InspectionController());
  // PageView controller
  final PageController _pageController = PageController();
  int currentPage = 0;

  // Additional notes for each question
  Map<String, String> additionalNotes = {};

  @override
  void initState() {
    super.initState();
    HiveService.instance
        .getInspectionSubmissionsBySectionId(widget.section?.sectionId ?? '')
        .then((value) {
          if (value != null) {
            inspectionSubmissions = value;
            // Update ship name if provided and not already set
            if (widget.shipName != null && widget.shipName!.isNotEmpty) {
              inspectionSubmissions = InspectionSubmission(
                answers: inspectionSubmissions.answers,
                inspectionDate: inspectionSubmissions.inspectionDate,
                sectionId: inspectionSubmissions.sectionId,
                inspectionId: inspectionSubmissions.inspectionId,
                shipName: widget.shipName,
              );
            }
          } else {
            inspectionSubmissions = InspectionSubmission(
              answers:
                  widget.section?.questions
                      .map(
                        (q) => InspectionAnswer(
                          questionId: q.questionId,
                          answer: q.questionType,
                          satisfied: '',
                          comments: '',
                        ),
                      )
                      .toList() ??
                  [],
              inspectionDate: DateTime.now(),
              sectionId: widget.section?.sectionId ?? '',
              inspectionId: widget.inspectionId ?? '',
              shipName: widget.shipName ?? '',
            );
          }
          setState(() {
            
          });
        });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleAnswerChange(String questionId, dynamic answer) {
    // setState(() {
    //   selectedAnswers[questionId] = answer;
    // });

    // Update the answer in the corresponding submission
    setState(() {
      inspectionSubmissions.answers
              .firstWhere((a) => a.questionId == questionId)
              .satisfied =
          answer;
    });
  }

  void _handleNotesChange(String questionId, String notes) {
    // setState(() {
    //   additionalNotes[questionId] = notes;
    // });

    // Update the notes in the corresponding submission
    setState(() {
      inspectionSubmissions.answers
              .firstWhere((a) => a.questionId == questionId)
              .comments =
          notes;
    });
  }

  void _showFullScreenImage(File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.file(imageFile, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isVideoFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return [
      'mp4',
      'mov',
      'avi',
      'mkv',
      '3gp',
      'webm',
      'flv',
    ].contains(extension);
  }

  Widget _buildQuestionWidget(InspectionQuestion question) {
    switch (question.questionType.toLowerCase()) {
      case 'checkbox':
        return _buildCheckboxQuestion(question);
      case 'text':
        return _buildTextQuestion(question);
      case 'radio':
        return _buildRadioQuestion(question);
      default:
        return _buildCheckboxQuestion(question); // Default to checkbox
    }
  }

  Widget _buildCheckboxQuestion(InspectionQuestion question) {
    String isChecked =
        inspectionSubmissions.answers
            .firstWhereOrNull((a) => a.questionId == question.questionId)
            ?.satisfied ??
        "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Html(data: question.questionText),
        // Text(
        //   question.questionText,
        //   style: const TextStyle(
        //     fontSize: 15,
        //     height: 1.4,
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
        const SizedBox(height: 10),

        // Yes / No buttons
        Row(
          children: [
            SizedBox(
              width: 100,
              child: GestureDetector(
                onTap: () => _handleAnswerChange(question.questionId, "yes"),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isChecked == 'yes'
                        ? Colors.green.shade600
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isChecked == 'yes'
                          ? Colors.green.shade700
                          : Colors.grey.shade300,
                      width: isChecked == 'yes' ? 2 : 1,
                    ),
                 
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Yes',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: isChecked == 'yes'
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 100,
              child: GestureDetector(
                onTap: () => _handleAnswerChange(question.questionId, "no"),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isChecked == 'no'
                        ? Colors.red.shade600
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isChecked == 'no'
                          ? Colors.red.shade700
                          : Colors.grey.shade300,
                      width: isChecked == 'no' ? 2 : 1,
                    ),
                 
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                     
                        Text(
                          'No',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: isChecked == 'no'
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    _handleAnswerChange(question.questionId, 'notApplicable'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isChecked == 'notApplicable'
                        ? Colors.black54
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isChecked == 'notApplicable'
                          ? Colors.black54
                          : Colors.grey.shade300,
                      width: isChecked == 'notApplicable' ? 2 : 1,
                    ),
                    // boxShadow: isChecked == 'notApplicable'
                    //     ? [
                    //         BoxShadow(
                    //           color: Colors.black54.withOpacity(0.3),
                    //           spreadRadius: 1,
                    //           blurRadius: 4,
                    //           offset: const Offset(0, 2),
                    //         ),
                    //       ]
                    //     : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Not Applicable',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: isChecked == 'notApplicable'
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ), // Placeholder for spacing
          ],
        ),
      ],
    );
  }

  Widget _buildTextQuestion(InspectionQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Html(data: question.questionText),
        const SizedBox(height: 16),
        TextField(
          maxLines: 3,
          onChanged: (value) => _handleAnswerChange(question.questionId, value),
          decoration: InputDecoration(
            hintText: 'Enter your answer here...',
            hintStyle: FontHelper.ts14w400(
              color: AppColors.kcButtonDisabledColor,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.kcPrimaryAccentColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioQuestion(InspectionQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Html(data: question.questionText),
        const SizedBox(height: 16),
        ...question.options.map(
          (option) => RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedAnswers[question.questionId],
            onChanged: (value) =>
                _handleAnswerChange(question.questionId, value),
            activeColor: AppColors.kcPrimaryAccentColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no section data is passed, show error
    if (widget.section == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: defaultAppBar(context, isLeading: true),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('No section data available'),
            ],
          ),
        ),
      );
    }

    final section = widget.section!;
    final questions = section.questions;

    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: defaultAppBar(context, isLeading: true),
        body: Column(
          children: [
            // Header with section info
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
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
                      Expanded(
                        child: Text(
                          widget.shipName ?? 'Unknown Ship',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.kcPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    section.sectionName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Complete all ${questions.length} inspection items in this section',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
      
            // Page indicator
            if (questions.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < questions.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentPage == i ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentPage == i
                            ? AppColors.kcPrimaryAccentColor
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
      
            const SizedBox(height: 16),
      
            // PageView for questions
            Expanded(
              child: questions.length == 1
                  ? _buildSingleQuestionView(questions.first)
                  : _buildPageView(questions),
            ),
      
            // Navigation buttons (only show for multiple questions)
            if (questions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    ElevatedButton.icon(
                      onPressed: currentPage > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
      
                    // Next button
                    ElevatedButton.icon(
                      onPressed: currentPage < questions.length - 1
                          ? () async {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                              HiveService.instance.saveInspectionSubmission(
                                inspectionSubmissions,
                              );
      
                              var data = await HiveService.instance
                                  .getAllInspectionSubmissions();
                              print(data);
                            }
                          : () async {
                              var res = 
                              await inspectionController
                                  .submitInspection(inspectionSubmissions);
                              if (res) {
                                // ignore: use_build_context_synchronously
                                context.go(AppPages.home);
                              }
                            },
                      icon: const Icon(Icons.chevron_right),
                      label: Text(
                        currentPage < questions.length - 1 ? 'Next' : 'Submit',
                      ),
                      iconAlignment: IconAlignment.end,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kcPrimaryAccentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleQuestionView(InspectionQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildQuestionCard(question, 0),
    );
  }

  Widget _buildPageView(List<InspectionQuestion> questions) {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          currentPage = index;
        });
      },
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return SingleChildScrollView(
          // padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildQuestionCard(questions[index], index),
        );
      },
    );
  }

  Widget _buildQuestionCard(InspectionQuestion question, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(70),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: AppColors.kcPrimaryAccentColor,
              // borderRadius: const BorderRadius.only(
              //   topLeft: Radius.circular(12),
              //   topRight: Radius.circular(12),
              // ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      // 'Question ${index + 1}',
                      question.questionId,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (widget.section!.questions.length > 1)
                    Text(
                      '${index + 1}/${widget.section!.questions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic question widget based on type
                _buildQuestionWidget(question),

                const SizedBox(height: 10),
                const Divider(thickness: 1),
                const SizedBox(height: 10),

                // Attach Evidence
                const Text(
                  'Upload Evidence',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                // Upload buttons
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final pickedFile = await ImagePicker().pickImage(
                                source: ImageSource.camera,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  inspectionSubmissions.answers
                                      .firstWhere(
                                        (a) =>
                                            a.questionId == question.questionId,
                                      )
                                      .files
                                      .add(File(pickedFile.path));
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                            ),
                            label: const Text(
                              'Take Photo',
                              style: TextStyle(color: Colors.black87),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final pickedFile = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  inspectionSubmissions.answers
                                      .firstWhere(
                                        (a) =>
                                            a.questionId == question.questionId,
                                      )
                                      .files
                                      .add(File(pickedFile.path));
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.photo_library,
                              color: Colors.black,
                            ),
                            label: const Text(
                              'Gallery',
                              style: TextStyle(color: Colors.black87),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final pickedFile = await ImagePicker().pickVideo(
                                source: ImageSource.camera,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  inspectionSubmissions.answers
                                      .firstWhere(
                                        (a) =>
                                            a.questionId == question.questionId,
                                      )
                                      .files
                                      .add(File(pickedFile.path));
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.videocam,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Record Video',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final pickedFile = await ImagePicker().pickVideo(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  inspectionSubmissions.answers
                                      .firstWhere(
                                        (a) =>
                                            a.questionId == question.questionId,
                                      )
                                      .files
                                      .add(File(pickedFile.path));
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.video_library,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Video Gallery',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Multi-select images
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final pickedFiles = await ImagePicker()
                              .pickMultiImage();
                          if (pickedFiles.isNotEmpty) {
                            setState(() {
                              final answerIndex = inspectionSubmissions.answers
                                  .indexWhere(
                                    (a) => a.questionId == question.questionId,
                                  );
                              if (answerIndex != -1) {
                                for (var pickedFile in pickedFiles) {
                                  inspectionSubmissions
                                      .answers[answerIndex]
                                      .files
                                      .add(File(pickedFile.path));
                                }
                              }
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.black,
                        ),
                        label: const Text(
                          'Select Multiple Photos',
                          style: TextStyle(color: Colors.black87),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Display uploaded media (images and videos)
                if (inspectionSubmissions.answers
                        .firstWhereOrNull(
                          (a) => a.questionId == question.questionId,
                        )
                        ?.files
                        .isNotEmpty ??
                    false)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Uploaded Media (${inspectionSubmissions.answers.firstWhere((a) => a.questionId == question.questionId).files.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                inspectionSubmissions.answers
                                    .firstWhere(
                                      (a) =>
                                          a.questionId == question.questionId,
                                    )
                                    .files
                                    .clear();
                              });
                            },
                            icon: const Icon(
                              Icons.clear_all,
                              size: 16,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Clear All',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                        itemCount: inspectionSubmissions.answers
                            .firstWhere(
                              (a) => a.questionId == question.questionId,
                            )
                            .files
                            .length,
                        itemBuilder: (context, fileIndex) {
                          final file = inspectionSubmissions.answers
                              .firstWhere(
                                (a) => a.questionId == question.questionId,
                              )
                              .files[fileIndex];

                          final isVideo = _isVideoFile(file.path);

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (isVideo) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Video preview functionality can be added here',
                                          ),
                                        ),
                                      );
                                    } else {
                                      _showFullScreenImage(file);
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: isVideo
                                        ? Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            color: Colors.black87,
                                            child: const Center(
                                              child: Icon(
                                                Icons.play_circle_fill,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            ),
                                          )
                                        : Image.file(
                                            file,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                // Media type indicator
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isVideo ? Colors.red : Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isVideo ? 'VIDEO' : 'IMAGE',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Delete button
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        inspectionSubmissions.answers
                                            .firstWhere(
                                              (a) =>
                                                  a.questionId ==
                                                  question.questionId,
                                            )
                                            .files
                                            .removeAt(fileIndex);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                // File name at bottom
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      file.path.split('/').last,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 20),

                // Additional Notes
                const Text(
                  'Additional Notes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 3,
                  onChanged: (value) =>
                      _handleNotesChange(question.questionId, value),
                  decoration: InputDecoration(
                    hintText: 'Write any additional notes here...',
                    hintStyle: FontHelper.ts14w400(
                      color: AppColors.kcButtonDisabledColor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
