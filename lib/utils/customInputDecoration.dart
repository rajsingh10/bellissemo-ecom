import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'colors.dart';

InputDecoration inputDecoration({
  required String hintText,
  Widget? searchIcon,
  Widget? ico,
  String? errortext,
  Color? cr,
}) {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 0.80.h, horizontal: 4.w),
    suffixIcon: ico,
    errorText: errortext,
    hintText: hintText,
    prefixIcon: searchIcon,
    errorStyle: TextStyle(
      fontFamily: FontFamily.regular,
      color: Colors.red,
      fontWeight: FontWeight.normal,
      fontSize: 15.sp,
      letterSpacing: 1,
    ),
    hintStyle: TextStyle(
      fontFamily: FontFamily.regular,
      color: AppColors.gray,
      fontWeight: FontWeight.normal,
      fontSize: 15.5.sp,
      letterSpacing: 1,
    ),
    fillColor: Colors.white,
    filled: true,
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: 1),
      borderRadius: BorderRadius.circular(16),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade400, width: 1),
      borderRadius: BorderRadius.circular(16),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: 1),
      borderRadius: BorderRadius.circular(16),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: 1),
      borderRadius: BorderRadius.circular(16),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: 1),
      borderRadius: BorderRadius.circular(16),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: 1),
      borderRadius: BorderRadius.circular(16),
    ),
  );
}
