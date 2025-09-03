import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

buildErrorDialog(
  BuildContext context,
  String title,
  String contant, {
  VoidCallback? callback,
  String? buttonname,
}) {
  Widget okButton = GestureDetector(
    child: Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.0),
        // color: primary
      ),
      child: Center(
        child: Text(
          buttonname ?? 'OK',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'task',
            letterSpacing: 1,
            decorationColor: Colors.black,
            color: Colors.blue,
          ),
        ),
      ),
    ),
    onTap: () {
      // if (callback == null) {
      Get.back();
      // } else {

      // }
    },
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: 73.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 3.h),
              (title != "")
                  ? Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.blue,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            decorationColor: Colors.black,
                            fontFamily: 'task',
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                    ],
                  )
                  : Container(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  children: [
                    SizedBox(height: 1.h),
                    Text(
                      contant,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        decorationColor: Colors.black,
                        letterSpacing: 1,
                        fontFamily: 'task',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Divider(height: 1.0, color: Colors.grey),
              SizedBox(height: 2.h),
              okButton,
              SizedBox(height: 2.h),
            ],
          ),
        ),
      );
    },
  );
}

buildErrorDialog1(
  BuildContext context,
  String title,
  String contant,
  VoidCallback? callback, {
  String? buttonname,
}) {
  Widget okButton = GestureDetector(
    child: Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.0),
        // color: primary
      ),
      child: Center(
        child: Text(
          buttonname ?? 'OK',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'task',
            letterSpacing: 1,
            decorationColor: Colors.black,
            color: Colors.blue,
          ),
        ),
      ),
    ),
    onTap:
        // if (callback == null) {
        callback,

    // } else {

    // }
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: 73.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 3.h),
              (title != "")
                  ? Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            decorationColor: Colors.black,
                            fontFamily: 'task',
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                    ],
                  )
                  : Container(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  children: [
                    SizedBox(height: 1.h),
                    Text(
                      contant,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        decorationColor: Colors.black,
                        fontFamily: 'task',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Divider(height: 1.0, color: Colors.grey),
              SizedBox(height: 2.h),
              okButton,
              SizedBox(height: 2.h),
            ],
          ),
        ),
      );
    },
  );
}
