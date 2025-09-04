import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:sizer/sizer.dart';

InkWell CustomButton({
  required String? title,
  required Callback? route,
  required Color? color,
  required Color? fontcolor,
  required double? height,
  double? width,
  required double? fontsize,
  IconData? iconData,
  iconData1,
  FontWeight? fontWeight,
  List<BoxShadow>? shadow,
  double? iconsize,
  iconsize1,
  radius,
}) {
  return InkWell(
    onTap: route,
    child: Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(radius ?? 3.w),

      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius ?? 3.w),
          boxShadow: shadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(visible: iconData != null, child: SizedBox(width: 2.w)),
            if (iconData != null)
              Icon(iconData, color: fontcolor, size: iconsize),
            if (iconData != null) SizedBox(width: 2.w),
            Text(
              title.toString(),
              style: TextStyle(
                fontFamily: FontFamily.regular,
                color: fontcolor,
                fontWeight: fontWeight == null ? FontWeight.bold : fontWeight,
                letterSpacing: 1,
                fontSize: fontsize,
              ),
            ),
            if (iconData1 != null) SizedBox(width: 2.w),
            if (iconData1 != null)
              Icon(iconData1, color: fontcolor, size: iconsize1),
            if (iconData != null) SizedBox(width: 3.w),
          ],
        ),
      ),
    ),
  );
}
