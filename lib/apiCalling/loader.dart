import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../utils/colors.dart';

Widget Loader() {
  return Center(
    child: Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 9.h, // Reduced height
        width: 18.w, // Reduced width
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          // Center the loader
          child: SizedBox(
            height: 4.5.h, // Smaller loader size
            width: 4.5.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              backgroundColor: AppColors.mainColor,
            ),
          ),
        ),
      ),
    ),
  );
}
