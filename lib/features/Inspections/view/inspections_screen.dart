import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:marine_inspection/models/inspection_model.dart';

import '../../../routes/app_pages.dart';
import '../../../shared/constant/app_colors.dart';
import '../../../shared/constant/font_helper.dart';
import '../../../shared/widgets/toast/my_toast.dart';
import '../controller/inspection_controller.dart';

class InspectionsScreen extends StatefulWidget {
  const InspectionsScreen({super.key});

  @override
  State<InspectionsScreen> createState() => _InspectionsScreenState();
}

class _InspectionsScreenState extends State<InspectionsScreen> {
    final inspectionController = Get.isRegistered<InspectionController>()
      ? Get.find<InspectionController>(): Get.put(InspectionController());
        Rx<InspectionListResponse?> inspectionResponseList = Rx<InspectionListResponse?>(null);
    final RxBool isLoad = true.obs;

        @override
  void initState() {
    super.initState();
    _loadInspectionListResponse();
  }
  Future<void> _loadInspectionListResponse() async {
    try {
      print('Loading inspection list...');
      await inspectionController.getInspectionsByUserId('').then((value) {
        if (value != null) {
          inspectionResponseList(value);
        }
        isLoad.value = false;
      });
    } catch (e) {
      MyToasts.toastError("Failed to load inspection list: $e");
      isLoad.value = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:  Text('All Inspections',   style: FontHelper.ts20w700(color: Colors.white),),
        elevation: 6,
    backgroundColor: AppColors.kcPrimaryColor,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.grey.withOpacity(0.1),
      ),
      body: Obx(
        () {
          return isLoad.value
              ? const Center(child: CircularProgressIndicator())
              : inspectionResponseList.value == null || inspectionResponseList.value!.inspections.isEmpty
                  ? const Center(child: Text('No inspections found'))
                  : 
           SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                      ...inspectionResponseList.value!.inspections.map(
                      (section) =>
                       _buildInspectionCard(context, section),
               
                      )
                  ],
                ),
              ),
            ),
          );
        }
      ),
    
    );
  }


  Widget _buildInspectionCard(BuildContext context, InspectionModelData section) {
    String status;
    if (section.overallStatus == 'in-progress') {
      status = 'In Progress';
    } else if (section.overallStatus == 'pending') {
      status = 'Pending';
    } else {
      status = 'Completed';
    }
    Color color;

    switch (status) {
      case 'Completed':
        color = Colors.green;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      case 'In Progress':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return GestureDetector(
      onTap: () => {
          context.push(
          AppPages.inspectionDetail,
            extra: section.inspectionId,
          )
      
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(
              Icons.directions_boat,
              color: color,
            ),
          ),
          title: Text(section.templateName,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              // color: color,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // show date and time in a readable format
                'Date: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(section.inspectionDate))}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Status: $status',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
       
        ),
      ),
    );
  }
}
