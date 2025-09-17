import 'package:bellissemo_ecom/ui/home/view/homeMenuScreen.dart';
import 'package:bellissemo_ecom/ui/login/view/loginScreen.dart';
import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../ApiCalling/apiConfigs.dart';
import '../Apicalling/sharedpreferance.dart';
import '../utils/fontFamily.dart';

class GreetingsScreen extends StatefulWidget {
  const GreetingsScreen({super.key});

  @override
  State<GreetingsScreen> createState() => _GreetingsScreenState();
}

class _GreetingsScreenState extends State<GreetingsScreen> {
  getdata() async {
    loginData = await SaveDataLocal.getDataFromLocal();

    Future.delayed(Duration(seconds: 2), () {
      if (loginData?.userDisplayName == '' ||
          loginData?.userDisplayName == null) {
        Get.offAll(LoginScreen());
      } else {
        Get.offAll(HomeMenuScreen());
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60.w,
              width: 80.w,
              child: Image.asset(Imgs.onlyLogo),
            ),
            SizedBox(height: 1.h),
            Text(
              "Welcome to Bellissemo App",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.mainColor,
                fontFamily: FontFamily.regular,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
