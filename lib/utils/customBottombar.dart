import 'dart:io';
import 'dart:ui';

import 'package:bellissemo_ecom/ui/home/view/homeScreen.dart';
import 'package:bellissemo_ecom/ui/products/view/productCatalogScreen.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:sizer/sizer.dart';
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

  /// ✅ Use functions returning widgets instead of widget instances
  final List<Map<String, dynamic>> _items = [
    {
      "title": "Products",
      "icon": Imgs.firstImage,
      "page": () => ProductCatalogScreen(),
    },
    {"title": "Orders", "icon": Imgs.secondImage, "page": () {}},
    {"title": "Home", "icon": Imgs.thirdImage, "page": () => Homescreen()},
    {"title": "Cart", "icon": Imgs.fourthImage, "page": () {}},
    {"title": "Profile", "icon": Imgs.fifthImage, "page": () {}},
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          height: Platform.isAndroid ? 10.h : 11.h,
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
                      Get.offAll(item["page"]);
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutQuint,
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.8.h,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        isActive
                            ? LinearGradient(
                              colors: [
                                AppColors.mainColor.withValues(alpha: 0.70),
                                AppColors.mainColor.withValues(alpha: 0.70),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : null,
                    color: isActive ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow:
                        isActive
                            ? [
                              BoxShadow(
                                color: AppColors.mainColor.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 16,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                            ]
                            : [],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                    child: Column(
                      key: ValueKey(isActive),
                      mainAxisSize: MainAxisSize.min, // ✅ prevent overflow
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          item["icon"],
                          width: 8.w,
                          height: 8.w,
                          color: isActive ? Colors.white : AppColors.mainColor,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          item["title"],
                          style: TextStyle(
                            color:
                                isActive ? Colors.white : AppColors.mainColor,
                            fontSize: 13.sp,
                            fontFamily: FontFamily.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
