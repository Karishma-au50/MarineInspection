import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_inspection/shared/constant/font_helper.dart';
import 'app_colors.dart';

AppBar defaultAppBar(BuildContext context,{bool isLeading = false}) {
  return AppBar(
    elevation: 6,
    backgroundColor: AppColors.kcPrimaryColor,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.grey.withOpacity(0.1),
    title:  Row(
      children: [
           Icon(
              Icons.directions_boat,
              size: 30,
              color: AppColors.kcWhite,
            ),
        const SizedBox(width: 15),
        Text(
          'Marine Inspection',
          style: FontHelper.ts20w700(color: Colors.white),
        ),
      ],
    ),
    leading: isLeading ? IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        context.pop();
      },
    ) : null,
  );
}
