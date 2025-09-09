import 'dart:io';
import 'dart:ui';

import 'package:bellissemo_ecom/ui/cart/View/cartScreen.dart';
import 'package:bellissemo_ecom/ui/home/view/homeMenuScreen.dart';
import 'package:bellissemo_ecom/ui/home/view/homeScreen.dart';
import 'package:bellissemo_ecom/ui/orderhistory/view/orderHistoryScreen.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../ui/category/view/categoryScreen.dart';
import '../ui/profile/view/profileScreen.dart';
import 'colors.dart';
import 'images.dart';

class CustomBar extends StatefulWidget {
  final int? selected;

  const CustomBar({super.key, this.selected});

  @override
  State<CustomBar> createState() => _CustomBarState();
}

class _CustomBarState extends State<CustomBar> {
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
      "page": () => OrderHistoryScreen()
    },
    {
      "title": "Home",
      "icon": Imgs.thirdImage,
      "page": () => Homescreen()
    },
    {
      "title": "Cart",
      "icon": Imgs.fourthImage,
      "page": () => CartScreen(customerName: '')
    },
    {
      "title": "Profile",
      "icon": Imgs.fifthImage,
      "page": () => HomeMenuScreen()
    },
  ];

  @override
  void initState() {
    super.initState();
    selected = widget.selected ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15), // glass effect
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          height: Platform.isAndroid ? 9.h : 10.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final bool isActive = selected == index + 1;

              return GestureDetector(
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      item["icon"],
                      width: 8.w,
                      height: 8.w,
                      colorFilter: ColorFilter.mode(
                        isActive ? AppColors.mainColor : AppColors.gray,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      item["title"],
                      style: TextStyle(
                        color: isActive ? AppColors.mainColor : AppColors.gray,
                        fontSize: 13.sp,
                        fontFamily: FontFamily.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
