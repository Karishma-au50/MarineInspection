import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class MyToasts {
  static _getSimpleSnackbar({required String text, bool isError = false}) {
  
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static toastSuccess(String text) {
    _getSimpleSnackbar(text: text, isError: false);
  }

  static toastError(String text) {
    // Log.error(text);
    _getSimpleSnackbar(text: text, isError: true);
  }

  static getButtonSnackbar(
      {required String text,
      bool isError = false,
      required Function onPressed}) {
    Get.showSnackbar(
      GetSnackBar(
        message: text,
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(20),
        borderRadius: 10,
        mainButton: TextButton(
          onPressed: () {
            onPressed();
          },
          child: ElevatedButton(
            onPressed: () {
              onPressed();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
            ),
            child: const Text("Login"),
          ),
        ),
      ),
    );
  }
}
