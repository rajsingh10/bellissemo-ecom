import 'package:bellissemo_ecom/ui/home/view/homeScreen.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:bellissemo_ecom/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/colors.dart';
import '../../../utils/customButton.dart';
import '../../../utils/textFields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController(
    text: "nicholas@ergemla.com",
  );
  final TextEditingController passwordController = TextEditingController(
    text: "password",
  );

  late bool isIpad;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isIpad = 100.w >= 800; // Check for iPad or tablet based on screen width
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: [
          // Top Positioned Section
          Positioned(
            top: isIpad ? 6.h : 8.h,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  Imgs.onlyLogo,
                  height: isIpad ? 20.w : 40.w,
                  width: isIpad ? 25.w : 50.w,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: isIpad ? 2.h : 2.h),
                Text(
                  "Welcome to Bellissemo",
                  style: TextStyle(
                    fontSize: isIpad ? 20.sp : 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                    fontFamily: FontFamily.regular,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: isIpad ? 1.h : 0.5.h),
                Text(
                  "Your style, delivered. Log in to explore deals and offers.",
                  style: TextStyle(
                    fontSize: isIpad ? 14.sp : 15.sp,
                    color: AppColors.whiteColor.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ).paddingSymmetric(horizontal: isIpad ? 10.w : 5.w),
              ],
            ),
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: isIpad ? 0.46 : 0.58,
            minChildSize: isIpad ? 0.46 : 0.58,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isIpad ? 5.w : 8.w),
                    topRight: Radius.circular(isIpad ? 5.w : 8.w),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isIpad ? 6.w : 3.w,
                  vertical: isIpad ? 3.h : 2.h,
                ),
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  controller: scrollController,
                  child: Column(
                    children: [
                      Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: isIpad ? 19.sp : 21.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                          fontFamily: FontFamily.regular,
                        ),
                      ),
                      SizedBox(height: isIpad ? 1.h : 1.h),
                      Text(
                        "Discover exclusive products and seamless shopping.",
                        style: TextStyle(
                          fontSize: isIpad ? 12.sp : 14.sp,
                          color: AppColors.gray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isIpad ? 4.h : 3.h),
                      AppTextField(
                        controller: emailController,
                        hintText: "Email Address",
                        text: "Email Address",
                        isTextavailable: true,
                        textInputType: TextInputType.emailAddress,
                        prefix: Icon(
                          Icons.email_outlined,
                          color: AppColors.gray,
                        ),
                      ),
                      SizedBox(height: isIpad ? 2.h : 2.h),
                      AppTextField(
                        controller: passwordController,
                        hintText: "Password",
                        text: "Password",
                        isTextavailable: true,
                        obscureText: true,
                        textInputType: TextInputType.visiblePassword,
                        prefix: Icon(Icons.lock_outline, color: AppColors.gray),
                      ),
                      SizedBox(height: isIpad ? 4.h : 3.h),
                      CustomButton(
                        title: 'Sign In',
                        route: () {
                          Get.offAll(
                            Homescreen(),
                            transition: Transition.fade,
                            duration: const Duration(milliseconds: 450),
                          );
                        },
                        color: AppColors.mainColor,
                        fontcolor: AppColors.whiteColor,
                        height: isIpad ? 7.h : 6.h,
                        fontsize: isIpad ? 19.sp : 17.sp,
                        radius: isIpad ? 1.w : 3.w,
                      ),
                      SizedBox(height: isIpad ? 3.h : 2.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
