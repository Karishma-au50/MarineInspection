import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_inspection/routes/app_pages.dart';

import '../../models/user_model.dart';
import '../services/storage_service.dart';

class AppFunctions {
  static UserModel? get userModel => StorageService.instance.getUserId();
  static RxBool isOfferClaimed = false.obs;
  static String claimOfferImage = "";
  static String cashBackInfo = "";
  static String cashBackText = "";
  static bool isLogedIn(BuildContext context) {
    if (StorageService.instance.getUserId() != null) {
      return true;
    } else {
      context.push(AppPages.login);
      return false;
    }
  }

  static Future<bool> isInternetAvailable(
      {int retry = 3, Duration delay = const Duration(seconds: 2)}) async {
    try {
      for (int i = 0; i < retry; i++) {
        if (await _checkConnection()) {
          return true;
        }
        await Future.delayed(delay);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  //The test to actually see if there is a connection
  static Future<bool> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }
}
