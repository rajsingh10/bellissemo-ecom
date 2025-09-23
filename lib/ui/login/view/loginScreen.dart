import 'dart:convert';

import 'package:bellissemo_ecom/ui/home/view/homeMenuScreen.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:bellissemo_ecom/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../apiCalling/apiConfigs.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../apiCalling/sharedpreferance.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/colors.dart';
import '../../../utils/customButton.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/textFields.dart';
import '../modal/loginModal.dart';
import '../provider/loginProvider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // 🔑 Add form key
  late bool isIpad;
  bool isLogin = false;

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
                    color: AppColors.whiteColor.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ).paddingSymmetric(horizontal: isIpad ? 10.w : 5.w),
              ],
            ),
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: isIpad ? 0.43 : 0.58,
            minChildSize: isIpad ? 0.43 : 0.58,
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
                      color: Colors.black.withValues(alpha: 0.1),
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
                  child: Form(
                    key: _formKey, // 🔑 Wrap with Form
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

                        // 🔹 Email Field with Validator
                        AppTextField(
                          controller: emailController,
                          hintText: "User Name",
                          text: "User Name",
                          isTextavailable: true,
                          textInputType: TextInputType.emailAddress,
                          prefix: Icon(
                            Icons.email_outlined,
                            color: AppColors.gray,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your user name";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isIpad ? 2.h : 2.h),

                        // 🔹 Password Field with Validator
                        AppTextField(
                          controller: passwordController,
                          hintText: "Password",
                          text: "Password",
                          isTextavailable: true,
                          obscureText: true,
                          textInputType: TextInputType.visiblePassword,
                          prefix: Icon(
                            Icons.lock_outline,
                            color: AppColors.gray,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isIpad ? 4.h : 3.h),

                        // Sign In Button
                        isLogin
                            ? CustomButton(
                              title: 'Sign In',
                              route: () {},
                              color: AppColors.mainColor,
                              fontcolor: AppColors.whiteColor,
                              height: isIpad ? 7.h : 6.h,
                              fontsize: isIpad ? 19.sp : 17.sp,
                              radius: isIpad ? 1.w : 3.w,
                              isLoading: true,
                            )
                            : CustomButton(
                              title: 'Sign In',
                              route: () {
                                loginap();
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// only online login
  // loginap() {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       isLogin = true;
  //     });
  //     final Map<String, String> data = {
  //       'username': emailController.text.trim(),
  //       'password': passwordController.text.trim(),
  //     };
  //     print("🔹 Login Data: $data");
  //
  //     checkInternet().then((internet) async {
  //       if (internet) {
  //         try {
  //           LoginProvider()
  //               .loginapi(data)
  //               .then((response) async {
  //                 print("✅ API Response Status: ${response.statusCode}");
  //                 print("📩 API Response Body: ${response.body}");
  //
  //                 loginData = LoginModal.fromJson(json.decode(response.body));
  //
  //                 if (response.statusCode == 200) {
  //                   showCustomSuccessSnackbar(
  //                     title: 'Login Successful',
  //                     message: 'Welcome to Bellissemo! App',
  //                   );
  //                   SaveDataLocal.saveLogInData(loginData!);
  //
  //                   Get.offAll(HomeMenuScreen());
  //
  //                   setState(() {
  //                     isLogin = false;
  //
  //                     emailController.clear();
  //                     passwordController.clear();
  //                   });
  //                 } else if (response.statusCode == 403) {
  //                   showCustomErrorSnackbar(
  //                     title: 'Login Failed',
  //                     message:
  //                         'Invalid username or password. Please try again.',
  //                   );
  //                   setState(() {
  //                     isLogin = false;
  //                   });
  //                 } else {
  //                   showCustomErrorSnackbar(
  //                     title: 'Server Error',
  //                     message: 'Something went wrong. Please try again later.',
  //                   );
  //                   setState(() {
  //                     isLogin = false;
  //                   });
  //                 }
  //               })
  //               .catchError((error, stacktrace) {
  //                 print("❌ API CatchError: $error");
  //                 print("🛑 Stacktrace: $stacktrace");
  //
  //                 showCustomErrorSnackbar(
  //                   title: 'Network Error',
  //                   message:
  //                       'Unable to connect. Please check your internet and try again.',
  //                 );
  //                 setState(() {
  //                   isLogin = false;
  //                 });
  //               });
  //         } catch (e, s) {
  //           print("🔥 Exception Caught: $e");
  //           print("📌 Stacktrace: $s");
  //
  //           showCustomErrorSnackbar(
  //             title: 'Unexpected Error',
  //             message: 'Something went wrong. Please try again.',
  //           );
  //           setState(() {
  //             isLogin = false;
  //           });
  //         }
  //       } else {
  //         print("⚠️ No Internet Connection");
  //
  //         showCustomErrorSnackbar(
  //           title: 'No Internet',
  //           message: 'Please check your connection and try again.',
  //         );
  //         setState(() {
  //           isLogin = false;
  //         });
  //       }
  //     });
  //   }
  // }

  loginap() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLogin = true;
      });

      final String username = emailController.text.trim();
      final String password = passwordController.text.trim();

      final Map<String, String> data = {
        'username': username,
        'password': password,
      };
      print("🔹 Login Data: $data");

      checkInternet().then((internet) async {
        var loginBox = HiveService().getLoginBox();

        if (internet) {
          try {
            LoginProvider()
                .loginapi(data)
                .then((response) async {
                  print("✅ API Response Status: ${response.statusCode}");
                  print("📩 API Response Body: ${response.body}");

                  loginData = LoginModal.fromJson(json.decode(response.body));

                  if (response.statusCode == 200) {
                    // 🔹 Use username (or userId) as unique key
                    final userKey = username;

                    // ✅ Save login data in Hive for this user
                    await loginBox.put('${userKey}_loginData', response.body);
                    await loginBox.put('${userKey}_username', username);
                    await loginBox.put('${userKey}_password', password);

                    showCustomSuccessSnackbar(
                      title: 'Login Successful',
                      message: 'Welcome to Bellissemo!',
                    );

                    SaveDataLocal.saveLogInData(loginData!);
                    Get.offAll(HomeMenuScreen());

                    setState(() {
                      isLogin = false;
                      emailController.clear();
                      passwordController.clear();
                    });
                  } else if (response.statusCode == 403) {
                    showCustomErrorSnackbar(
                      title: 'Login Failed',
                      message:
                          'Invalid username or password. Please try again.',
                    );
                    setState(() {
                      isLogin = false;
                    });
                  } else {
                    showCustomErrorSnackbar(
                      title: 'Server Error',
                      message: 'Something went wrong. Please try again later.',
                    );
                    setState(() {
                      isLogin = false;
                    });
                  }
                })
                .catchError((error, stacktrace) {
                  print("❌ API CatchError: $error");
                  print("🛑 Stacktrace: $stacktrace");

                  showCustomErrorSnackbar(
                    title: 'Network Error',
                    message:
                        'Unable to connect. Please check your internet and try again.',
                  );
                  setState(() {
                    isLogin = false;
                  });
                });
          } catch (e, s) {
            print("🔥 Exception Caught: $e");
            print("📌 Stacktrace: $s");

            showCustomErrorSnackbar(
              title: 'Unexpected Error',
              message: 'Something went wrong. Please try again.',
            );
            setState(() {
              isLogin = false;
            });
          }
        } else {
          // 🔹 Offline Mode
          print("⚠️ No Internet Connection - Trying Offline Login");

          final userKey = username;
          final cachedData = loginBox.get('${userKey}_loginData');
          final cachedUsername = loginBox.get('${userKey}_username');
          final cachedPassword = loginBox.get('${userKey}_password');

          if (cachedData != null &&
              cachedUsername == username &&
              cachedPassword == password) {
            // ✅ Allow offline login for this user
            loginData = LoginModal.fromJson(json.decode(cachedData));

            showCustomSuccessSnackbar(
              title: 'Login Successful',
              message: 'Welcome back to Bellissemo!',
            );

            Get.offAll(HomeMenuScreen());
          } else {
            showCustomErrorSnackbar(
              title: 'Login Failed',
              message:
                  'No saved login found for this account. Please connect to the internet and try again.',
            );
          }

          setState(() {
            isLogin = false;
          });
        }
      });
    }
  }
}
