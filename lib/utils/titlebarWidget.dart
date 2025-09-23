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
  Callback? onDownload,
  Color? clr,
  bool isSearchEnabled = false,
  bool isDrawerEnabled = true,
  bool isBackEnabled = false,
  bool showDownloadButton = false, // Add a flag to control the download button
}) {
  final bool isTablet = 100.w >= 800;

  Widget buildButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.mainColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        child: Icon(
          icon,
          color: AppColors.mainColor,
          size: isTablet ? 20.sp : 22.sp,
        ),
      ),
    );
  }

  Widget buildDownloadButton() {
    return buildButton(Icons.download_rounded, onDownload);
  }

  final List<Widget> rightButtons = [];

  if (isSearchEnabled) {
    rightButtons.add(buildButton(Icons.search_rounded, onSearch));
  }

  // Show download button conditionally
  if (showDownloadButton) {
    rightButtons.add(buildDownloadButton());
  }

  return Container(
    margin: EdgeInsets.only(
      top: isTablet ? 6.h : 5.h,
      bottom: isTablet ? 2.h : 1.h,
    ),
    padding: EdgeInsets.symmetric(
      horizontal: isTablet ? 2.w : 3.w,
      vertical: isTablet ? 2.h : 1.h,
    ),
    decoration: BoxDecoration(
      color: clr ?? Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      borderRadius: BorderRadius.circular(isTablet ? 20 : 14),
    ),
    child: SizedBox(
      height: isTablet ? 8.h : 6.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side
          if (isBackEnabled)
            buildButton(Icons.arrow_back_rounded, () => Get.back())
          else if (isDrawerEnabled)
            buildButton(Icons.menu_rounded, drawerCallback)
          else
            SizedBox(width: isTablet ? 60 : 45),

          // Title
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

          // Right Side
          Row(
            children: List.generate(
              rightButtons.length,
              (i) => Row(
                children: [
                  rightButtons[i],
                  if (i != rightButtons.length - 1)
                    SizedBox(width: isTablet ? 2.w : 3.w),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
