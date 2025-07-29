import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marine_inspection/shared/constant/default_appbar.dart';
import 'package:marine_inspection/shared/constant/font_helper.dart';
import 'package:marine_inspection/models/inspection_template.dart';

import '../../shared/constant/app_colors.dart';

class QuestionAnswerScreen extends StatefulWidget {
  final InspectionSection? section;
  final String? templateId;

  const QuestionAnswerScreen({
    super.key,
    this.section,
    this.templateId,
  });

  @override
  State<QuestionAnswerScreen> createState() => _QuestionAnswerScreenState();
}

class _QuestionAnswerScreenState extends State<QuestionAnswerScreen> {
  // Map to store answers for each question
  Map<String, dynamic> selectedAnswers = {};
  
  // PageView controller
  PageController _pageController = PageController();
  int currentPage = 0;

  // Additional notes for each question
  Map<String, String> additionalNotes = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleAnswerChange(String questionId, dynamic answer) {
    setState(() {
      selectedAnswers[questionId] = answer;
    });
  }

  void _handleNotesChange(String questionId, String notes) {
    setState(() {
      additionalNotes[questionId] = notes;
    });
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionText,
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        
        // Yes / No buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _handleAnswerChange(question.questionId, true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedAnswers[question.questionId] == true 
                        ? Colors.green.shade600 
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedAnswers[question.questionId] == true 
                          ? Colors.green.shade700 
                          : Colors.grey.shade300,
                      width: selectedAnswers[question.questionId] == true ? 2 : 1,
                    ),
                    boxShadow: selectedAnswers[question.questionId] == true ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selectedAnswers[question.questionId] == true)
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        if (selectedAnswers[question.questionId] == true) const SizedBox(width: 8),
                        Text(
                          'Yes',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: selectedAnswers[question.questionId] == true 
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
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => _handleAnswerChange(question.questionId, false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedAnswers[question.questionId] == false 
                        ? Colors.red.shade600 
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedAnswers[question.questionId] == false 
                          ? Colors.red.shade700 
                          : Colors.grey.shade300,
                      width: selectedAnswers[question.questionId] == false ? 2 : 1,
                    ),
                    boxShadow: selectedAnswers[question.questionId] == false ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selectedAnswers[question.questionId] == false)
                          const Icon(
                            Icons.cancel_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        if (selectedAnswers[question.questionId] == false) const SizedBox(width: 8),
                        Text(
                          'No',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: selectedAnswers[question.questionId] == false 
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
          ],
        ),
      ],
    );
  }

  Widget _buildTextQuestion(InspectionQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionText,
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          maxLines: 3,
          onChanged: (value) => _handleAnswerChange(question.questionId, value),
          decoration: InputDecoration(
            hintText: 'Enter your answer here...',
            hintStyle: FontHelper.ts14w400(color: AppColors.kcButtonDisabledColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.kcPrimaryAccentColor, width: 2),
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
        Text(
          question.questionText,
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ...question.options.map((option) => 
          RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedAnswers[question.questionId],
            onChanged: (value) => _handleAnswerChange(question.questionId, value),
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

    return Scaffold(
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
          if (questions.length > 1)
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  
                  // Next button
                  ElevatedButton.icon(
                    onPressed: currentPage < questions.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                    iconAlignment: IconAlignment.end,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kcPrimaryAccentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
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
      onPageChanged: (index) {
        setState(() {
          currentPage = index;
        });
      },
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildQuestionCard(questions[index], index),
        );
      },
    );
  }

  Widget _buildQuestionCard(InspectionQuestion question, int index) {
    return Container(
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
          // Header
          Container(
            decoration: BoxDecoration(
              color: AppColors.kcPrimaryAccentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic question widget based on type
                _buildQuestionWidget(question),
                
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 20),
            
                // Attach Evidence
                const Text(
                  'Attach Evidence',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                          if (pickedFile != null) {
                            // Handle the captured image
                          }
                        },
                        icon: const Icon(Icons.camera_alt, color: Colors.black),
                        label: const Text(
                          'Take Photo',
                          style: TextStyle(color: Colors.black87),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            // Handle the selected file
                          }
                        },
                        icon: const Icon(Icons.upload_file, color: Colors.black),
                        label: const Text(
                          'Upload File',
                          style: TextStyle(color: Colors.black87),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
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
                  onChanged: (value) => _handleNotesChange(question.questionId, value),
                  decoration: InputDecoration(
                    hintText: 'Write any additional notes here...',
                    hintStyle: FontHelper.ts14w400(color: AppColors.kcButtonDisabledColor),
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
