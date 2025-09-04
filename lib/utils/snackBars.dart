import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'fontFamily.dart';

void showCustomErrorSnackbar({required String title, required String message}) {
  Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.TOP,
    duration: const Duration(seconds: 3),
    backgroundColor: Colors.red.withValues(alpha: 0.9),
    colorText: Colors.white,
    margin: const EdgeInsets.all(10),
    borderRadius: 8,
    icon: const Icon(Icons.error, color: Colors.white),
    titleText: Text(
      title,
      style: TextStyle(
        fontFamily: FontFamily.bold,
        fontSize: 16.sp,
        color: Colors.white,
      ),
    ),
    messageText: Text(
      message,
      style: TextStyle(
        fontFamily: FontFamily.regular,
        fontSize: 15.sp,
        color: Colors.white,
      ),
    ),
  );
}

void showCustomSuccessSnackbar({
  required String title,
  required String message,
}) {
  Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.TOP,
    duration: const Duration(seconds: 4),
    backgroundColor: Colors.green.withValues(alpha: 0.9),
    colorText: Colors.white,
    margin: const EdgeInsets.all(10),
    borderRadius: 8,
    icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    titleText: Text(
      title,
      style: TextStyle(
        fontFamily: FontFamily.bold,
        fontSize: 16.sp,
        color: Colors.white,
      ),
    ),
    messageText: Text(
      message,
      style: TextStyle(
        fontFamily: FontFamily.regular,
        fontSize: 15.sp,
        color: Colors.white,
      ),
    ),
  );
}
