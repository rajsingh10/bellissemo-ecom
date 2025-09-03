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
  Widget _buildButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
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
    rightButtons.add(_buildButton(Icons.search_rounded, onSearch));
  }

  return Container(
    margin: EdgeInsets.only(top: 5.h, bottom: 2.h),
    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
    decoration: BoxDecoration(
      color: clr ?? Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      borderRadius: BorderRadius.circular(16),
    ),
    child: SizedBox(
      height: 6.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Left Side
          if (isBackEnabled)
            _buildButton(Icons.arrow_back_rounded, () => Get.back())
          else if (isDrawerEnabled)
            _buildButton(Icons.menu_rounded, drawerCallback)
          else
            const SizedBox(width: 45),

          /// Title
          Expanded(
            child: Center(
              child: Text(
                title ?? "",
                style: TextStyle(
                  fontSize: 19.sp,
                  fontFamily: FontFamily.semiBold,
                  color: AppColors.blackColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          /// Right Side (only search if enabled)
          Row(
            children: List.generate(
              rightButtons.length,
              (i) => Row(
                children: [
                  rightButtons[i],
                  if (i != rightButtons.length - 1) SizedBox(width: 2.w),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
