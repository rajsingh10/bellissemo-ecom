import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:sizer/sizer.dart';

import 'colors.dart';

Widget TitleBar({
  required String? title,
  Callback? drawerCallback,
  Callback? onSearch,
  Color? clr,
  bool isSearchEnabled = false,
  bool isDrawerEnabled = true,
  bool isBackEnabled = false,
}) {
  /// Helper: Build button
  Widget buildButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w), // responsive padding
        decoration: BoxDecoration(
          color: AppColors.mainColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.mainColor, size: 22.sp),
      ),
    );
  }

  /// Build right-side buttons dynamically
  final List<Widget> rightButtons = [];

  if (isSearchEnabled) {
    rightButtons.add(buildButton(Icons.search_rounded, onSearch));
  }

  // Drawer logic (right side only if back is enabled)
  if (isDrawerEnabled && isBackEnabled) {
    rightButtons.add(buildButton(Icons.menu_rounded, drawerCallback));
  }

  // Check if only one button total
  final int totalButtons =
      (isBackEnabled || isDrawerEnabled ? 1 : 0) + rightButtons.length;

  return Container(
    margin: EdgeInsets.only(top: 5.h, bottom: 1.h),
    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
    decoration: BoxDecoration(
      color: clr ?? Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8, // kept small for cleaner look
          offset: const Offset(0, 4),
        ),
      ],
      borderRadius: BorderRadius.circular(14),
    ),
    child: SizedBox(
      height: 6.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Left Side
          if (isBackEnabled)
            buildButton(Icons.arrow_back_rounded, () => Get.back())
          else if (isDrawerEnabled)
            buildButton(Icons.menu_rounded, drawerCallback)
          else
            SizedBox(width: 45), // responsive placeholder
          /// Title
          Expanded(
            child: Center(
              child: Text(
                title ?? "",
                style: TextStyle(
                  fontSize: 19.sp,
                  fontFamily: FontFamily.regular,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          /// Right Side
          if (rightButtons.isNotEmpty)
            Row(
              children: List.generate(
                rightButtons.length,
                (i) => Row(
                  children: [
                    rightButtons[i],
                    if (i != rightButtons.length - 1) SizedBox(width: 3.w),
                  ],
                ),
              ),
            )
          else if (totalButtons == 1)
            SizedBox(width: 12.w) // balance with left side
          else
            const SizedBox.shrink(),
        ],
      ),
    ),
  );
}
