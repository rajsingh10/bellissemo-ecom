import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'colors.dart';
import 'fontFamily.dart';

Widget emptyWidget({required IconData icon, required String text}) {
  return Column(
    children: [
      Container(
        width: 25.w,
        height: 25.w,
        decoration: const BoxDecoration(
          color: Color(0xFFF0F0F0),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 12.w, color: Colors.grey[400]),
      ),
      SizedBox(height: 2.h),
      Text(
        "No $text Available",
        style: TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.gray,
        ),
      ),
      SizedBox(height: 5.h),
    ],
  );
}
