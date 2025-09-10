import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/titlebarWidget.dart';
import 'editProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TitleBar(
              title: 'Profile',
              isDrawerEnabled: false,
              isSearchEnabled: false,
              isBackEnabled: true,
            ),
            Stack(
              clipBehavior: Clip.none, // allows the image to overflow
              children: [
                Container(
                  height: 16.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(200, 50),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: FontFamily.bold,
                            color: AppColors.whiteColor,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'johndoe@example.com',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: FontFamily.light,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: CustomNetworkImage(
                        imageUrl:
                            'https://images.unsplash.com/photo-1633332755192-727a05c4013d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlcnxlbnwwfHwwfHx8MA%3D%3D',
                        height: 80,
                        width: 80,
                        isCircle: true,
                        isProfile: true,
                        isFit: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 7.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.male_rounded,
                        color: AppColors.mainColor,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontFamily: FontFamily.bold,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '123, Main Street, City, Country',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontFamily: FontFamily.semiBold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  Divider(height: 2.h, color: Colors.grey[300]),
                  Row(
                    children: [
                      Icon(Icons.phone, color: AppColors.mainColor, size: 16),
                      SizedBox(width: 2.w),
                      Text(
                        'Phone',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontFamily: FontFamily.bold,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '+91 9876543210',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontFamily: FontFamily.semiBold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  Divider(height: 2.h, color: Colors.grey[300]),

                  Row(
                    children: [
                      Icon(
                        Icons.location_city_rounded,
                        color: AppColors.mainColor,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Address',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontFamily: FontFamily.bold,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '117, Albany Gardens',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontFamily: FontFamily.semiBold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  Divider(height: 2.h, color: Colors.grey[300]),
                  Row(
                    children: [
                      Icon(
                        Icons.location_city_rounded,
                        color: AppColors.mainColor,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'City',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontFamily: FontFamily.bold,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Colchester',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontFamily: FontFamily.semiBold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  Divider(height: 2.h, color: Colors.grey[300]),
                  Row(
                    children: [
                      Icon(
                        Icons.location_city_rounded,
                        color: AppColors.mainColor,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'State',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontFamily: FontFamily.bold,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Essex',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontFamily: FontFamily.semiBold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  Divider(height: 2.h, color: Colors.grey[300]),
                  Row(
                    children: [
                      Icon(
                        Icons.location_city_rounded,
                        color: AppColors.mainColor,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Country',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontFamily: FontFamily.bold,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'United Kingdom',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontFamily: FontFamily.semiBold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  Divider(height: 2.h, color: Colors.grey[300]),
                  Row(
                    children: [
                      Icon(
                        Icons.date_range_rounded,
                        color: AppColors.mainColor,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Date of Birth',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontFamily: FontFamily.bold,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '01 Jan 1990',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontFamily: FontFamily.semiBold,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            InkWell(
              onTap: () {
                Get.to(() => EditProfileScreen());
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 18.sp,
                      fontFamily: FontFamily.semiBold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
      ),
    );
  }
}
