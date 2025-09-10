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

  bool isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Column(
        children: [
          // Top Section with Gradient, Logo and Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8.h),
              Image.asset(
                Imgs.onlyLogo,
                height: 40.w,
                width: 50.w,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 2.h),
              Text(
                "Welcome to Bellissemo",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteColor,
                  fontFamily: FontFamily.regular,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                "Your style, delivered. Log in to explore deals and offers.",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.whiteColor.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ).paddingSymmetric(horizontal: 5.w),
              SizedBox(height: 2.h),
            ],
          ),

          // Bottom Section with White Card Style Container
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.w),
                  topRight: Radius.circular(8.w),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackColor,
                        fontFamily: FontFamily.regular,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "Discover exclusive products and seamless shopping.",
                      style: TextStyle(fontSize: 14.sp, color: AppColors.gray),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 3.h),
                    AppTextField(
                      controller: emailController,
                      hintText: "Email Address",
                      text: "Email Address",
                      isTextavailable: true,
                      textInputType: TextInputType.emailAddress,
                      prefix: Icon(Icons.email_outlined, color: AppColors.gray),
                    ),
                    SizedBox(height: 2.h),
                    AppTextField(
                      controller: passwordController,
                      hintText: "Password",
                      text: "Password",
                      isTextavailable: true,
                      obscureText: true,
                      textInputType: TextInputType.visiblePassword,
                      prefix: Icon(Icons.lock_outline, color: AppColors.gray),
                    ),
                    SizedBox(height: 3.h),
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
                      height: 6.h,
                      fontsize: 17.sp,
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
