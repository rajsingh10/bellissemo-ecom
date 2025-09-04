import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'colors.dart';

Future<void> OptionalDialog({
  required BuildContext context,
  String? title,
  String? content,
  VoidCallback? onYesPressed,
  VoidCallback? onNoPressed,
}) async {
  await showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: title != null ? Text(title) : null,
        content: content != null ? Text(content) : null,
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Get.back();
              if (onNoPressed != null) onNoPressed();
            },
            child: Text(
              'No',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.5.sp,
                fontFamily: FontFamily.regular,
                color: AppColors.gray,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Get.back();
              if (onYesPressed != null) onYesPressed();
            },
            child: Text(
              'Yes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.5.sp,
                fontFamily: FontFamily.regular,
                color: AppColors.gray,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> CustomDialog({
  required BuildContext context,
  String? title,
  String? content,
  required String buttonText,
  VoidCallback? onPressed,
}) async {
  await showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: title != null ? Text(title) : null,
        content: content != null ? Text(content) : null,
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Get.back();
              if (onPressed != null) onPressed();
            },
            child: Text(
              buttonText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.5.sp,
                fontFamily: FontFamily.regular,
                color: AppColors.gray,
              ),
            ),
          ),
        ],
      );
    },
  );
}
