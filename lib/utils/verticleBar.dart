import 'dart:ui';

import 'package:bellissemo_ecom/ui/cart/View/cartScreen.dart';
import 'package:bellissemo_ecom/ui/home/view/homeMenuScreen.dart';
import 'package:bellissemo_ecom/ui/orderhistory/view/orderHistoryScreen.dart';
import 'package:bellissemo_ecom/ui/profile/view/profileScreen.dart';
import 'package:bellissemo_ecom/utils/customButton.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../Apicalling/sharedpreferance.dart';
import '../ui/category/view/categoryScreen.dart';
import '../ui/login/view/loginScreen.dart';
import 'colors.dart';
import 'images.dart';

class VerticleBar extends StatefulWidget {
  final int? selected;

  const VerticleBar({super.key, this.selected});

  @override
  State<VerticleBar> createState() => _VerticleBarState();
}

class _VerticleBarState extends State<VerticleBar> {
  int selected = 1;

  final List<Map<String, dynamic>> _items = [
    {
      "title": "Catalogs",
      "icon": Imgs.firstImage,
      "page": () => CategoriesScreen(),
    },
    {
      "title": "Orders",
      "icon": Imgs.secondImage,
      "page": () => OrderHistoryScreen(),
    },
    {"title": "Home", "icon": Imgs.thirdImage, "page": () => HomeMenuScreen()},
    {"title": "Cart", "icon": Imgs.fourthImage, "page": () => CartScreen()},
    {
      "title": "Profile",
      "icon": Imgs.fifthImage,
      "page": () => ProfileScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    selected = widget.selected ?? 1;
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Logout",
            style: TextStyle(
              fontSize: 18.sp,
              fontFamily: FontFamily.bold,
              color: AppColors.blackColor,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            "Are you sure you wish to log out of your account?",
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: FontFamily.regular,
              color: AppColors.blackColor,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            CustomButton(
              title: "Cancel",
              route: () {
                Get.back(); // Close dialog
              },
              color: AppColors.containerColor,
              fontcolor: AppColors.blackColor,
              height: 5.h,
              width: 30.w,
              fontsize: 15.sp,
              radius: 12.0,
            ),
            CustomButton(
              title: "Confirm",
              route: () async {
                final prefs = await SharedPreferences.getInstance();
                SaveDataLocal.clearUserData();
                await prefs.clear();
                Get.offAll(LoginScreen());
              },
              color: AppColors.mainColor,
              fontcolor: AppColors.whiteColor,
              height: 5.h,
              width: 30.w,
              fontsize: 15.sp,
              radius: 12.0,
              iconData: Icons.check,
              iconsize: 17.sp,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Icon size logic
    double iconSize = 100.w >= 800 ? 4.w : 6.5.w;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(15),
        bottomRight: Radius.circular(15),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 5.h),
              // --- MENU ITEMS ---
              Expanded(
                child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                  itemCount: _items.length,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => SizedBox(height: 4.h),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final bool isActive = selected == index + 1;

                    return Tooltip(
                      message: item["title"], // Shows text on long press
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (!isActive) {
                            setState(() => selected = index + 1);
                            if (item["page"] != null) {
                              Get.offAll(
                                item["page"],
                                transition: Transition.fade,
                                duration: const Duration(milliseconds: 450),
                              );
                            }
                          }
                        },
                        child: Container(
                          // Transparent container to increase touch area
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            item["icon"],
                            width: iconSize,
                            height: iconSize,
                            colorFilter: ColorFilter.mode(
                              isActive ? AppColors.mainColor : AppColors.gray,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // --- LOGOUT BUTTON ---
              Divider(
                color: AppColors.gray.withOpacity(0.3),
                indent: 10,
                endIndent: 10,
              ),
              SizedBox(height: 1.h),
              Tooltip(
                message: "Logout",
                child: IconButton(
                  onPressed: _handleLogout,
                  icon: Icon(
                    Icons.logout_rounded,
                    size: iconSize,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
