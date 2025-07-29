import 'package:flutter/material.dart';
import 'package:marine_inspection/shared/constant/default_appbar.dart';
import 'package:marine_inspection/shared/constant/font_helper.dart';

import '../../shared/constant/app_colors.dart';

class QuestionAnswerScreen extends StatefulWidget {
  const QuestionAnswerScreen({super.key});

  @override
  State<QuestionAnswerScreen> createState() => _QuestionAnswerScreenState();
}

class _QuestionAnswerScreenState extends State<QuestionAnswerScreen> {
  // Map to store answers for each inspection item
  Map<String, bool?> selectedAnswers = {};

  // Dynamic inspection items data
  final List<Map<String, dynamic>> inspectionItems = [
    {
      'id': 'A1',
      'title': 'A1 - Emergency Generator',
      'questions': [
        '1. Means of Starting + 3 starts on each',
        '2. Last tried out on auto / load test',
        '3. D.O Tank - Min level – 18 hours operation + QCV mechanism',
        '4. Any alarms',
      ],
    },
    {
      'id': 'A2',
      'title': 'A2 - Emergency Fire Pump',
      'questions': [
        '1. Check pump operation and pressure',
        '2. Verify automatic start function',
        '3. Inspect suction and discharge valves',
        '4. Check fuel level and quality',
      ],
    },
    {
      'id': 'A3',
      'title': 'A3 - Emergency Lighting',
      'questions': [
        '1. Test battery backup duration',
        '2. Check LED functionality',
        '3. Verify charging system',
        '4. Inspect emergency exit signs',
      ],
    },
     {
      'id': 'A3',
      'title': 'A3 - Emergency Lighting',
      'questions': [
        '1. Test battery backup duration',
        '2. Check LED functionality',
        '3. Verify charging system',
        '4. Inspect emergency exit signs',
      ],
    },
     {
      'id': 'A3',
      'title': 'A3 - Emergency Lighting',
      'questions': [
        '1. Test battery backup duration',
        '2. Check LED functionality',
        '3. Verify charging system',
        '4. Inspect emergency exit signs',
      ],
    },
    {
      'id': 'A4',
      'title': 'A4 - Emergency Communications',
      'questions': [
        '1. Test radio communication systems',
        '2. Check backup power supply',
        '3. Verify antenna connections',
        '4. Test emergency frequencies',
      ],
    },
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: defaultAppBar(context, isLeading: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text('Progress'),
              // const SizedBox(height: 6),
              // LinearProgressIndicator(
              //   value: 0.2,
              //   color: Colors.blue.shade700,
              //   backgroundColor: Colors.grey.shade300,
              //   minHeight: 6,
              // ),
              // const SizedBox(height: 20),
              Container(
                width: double.infinity,
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A) EMERGENCIES + ENGINE ROOM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Complete all inspection items in this section',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
          
              // Dynamic Inspection Items
              ...inspectionItems.map((item) => Column(
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
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.white
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
              
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dynamic Questions
                              ...item['questions'].map<Widget>((question) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(question),
                              )).toList(),
                              
                              const SizedBox(height: 16),
                          
                              // Yes / No buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedAnswers[item['id']] = true; // Yes selected
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: selectedAnswers[item['id']] == true 
                                              ? Colors.green.shade600 
                                              : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: selectedAnswers[item['id']] == true 
                                                ? Colors.green.shade700 
                                                : Colors.grey.shade300,
                                            width: selectedAnswers[item['id']] == true ? 2 : 1,
                                          ),
                                          boxShadow: selectedAnswers[item['id']] == true ? [
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
                                              if (selectedAnswers[item['id']] == true)
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              if (selectedAnswers[item['id']] == true) const SizedBox(width: 15),
                                              Text(
                                                'Yes',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  color: selectedAnswers[item['id']] == true 
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
                                      onTap: () {
                                        setState(() {
                                          selectedAnswers[item['id']] = false; // No selected
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: selectedAnswers[item['id']] == false 
                                              ? Colors.red.shade600 
                                              : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: selectedAnswers[item['id']] == false 
                                                ? Colors.red.shade700 
                                                : Colors.grey.shade300,
                                            width: selectedAnswers[item['id']] == false ? 2 : 1,
                                          ),
                                          boxShadow: selectedAnswers[item['id']] == false ? [
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
                                              if (selectedAnswers[item['id']] == false)
                                                const Icon(
                                                  Icons.cancel,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              if (selectedAnswers[item['id']] == false) const SizedBox(width: 15),
                                              Text(
                                                'No',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  color: selectedAnswers[item['id']] == false 
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
                              const SizedBox(height: 15),
                              Divider(
                                color: Colors.grey.shade200,
                                thickness: 1,
                              ),
                              const SizedBox(height: 15),
                          
                              // Attach Evidence
                              const Text(
                                'Attach Evidence',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.camera_alt,color: Colors.black,),
                                      label: const Text('Take Photo',
                                      style: TextStyle(
                                        color: Colors.black87,
                                      ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        backgroundColor: Colors.grey.shade200,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.upload_file,color: Colors.black,),
                                      label: const Text('Upload File',
                                      style: TextStyle(
                                        color: Colors.black87,
                                      ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        backgroundColor: Colors.grey.shade200,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          
                              const SizedBox(height: 15),
                              Divider(
                                color: Colors.grey.shade200,
                                thickness: 1,
                              ),
                              const SizedBox(height: 15),
                          
                              const Text(
                                'Additional Notes',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                maxLines: 3,
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
                  ),
                  const SizedBox(height: 16), // Space between items
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
