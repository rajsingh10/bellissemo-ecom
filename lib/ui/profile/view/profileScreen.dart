import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/customMenuDrawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../ApiCalling/apiConfigs.dart';
import '../../../apiCalling/Check Internet Module.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/titlebarWidget.dart';
import '../modal/profileModal.dart';
import '../provider/profileProvider.dart';
import 'editProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

final bool isTablet = 100.w >= 800;
bool isLoading = true;

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> loadInitialData() async {
    setState(() => isLoading = true);

    // Load cached data first for immediate display
    _loadCachedData();

    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([_fetchProfile().then((_) => setState(() {}))]);
    } catch (e) {
      log("Error loading initial data: $e");
    } finally {
      stopwatch.stop();
      log("All API calls completed in ${stopwatch.elapsed.inMilliseconds} ms");
      setState(() => isLoading = false);
    }
  }

  void _loadCachedData() {
    var profileBox = HiveService().getProfileBox();

    final cachedProfile = profileBox.get('profile');
    if (cachedProfile != null) {
      profile = ProfileModal.fromJson(json.decode(cachedProfile));
    }

    setState(() {}); // Refresh UI immediately
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInitialData();
  }

  final GlobalKey<ScaffoldState> _scaffoldKeyProfile =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerColor,
      drawer: CustomDrawer(),
      key: _scaffoldKeyProfile,
      body:
          isLoading
              ? Loader()
              : SingleChildScrollView(
                child: Column(
                  children: [
                    TitleBar(
                      title: 'Profile',
                      isDrawerEnabled: true,
                      isSearchEnabled: false,
                      isBackEnabled: false,
                      drawerCallback: () {
                        _scaffoldKeyProfile.currentState?.openDrawer();
                      },
                    ),
                    Stack(
                      clipBehavior: Clip.none, // allows the image to overflow
                      children: [
                        Container(
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
                                  profile?.name ?? '',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  profile?.email ?? '',
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
                          top: isTablet ? 13.5.h : 10.h,
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.center,
                            child:
                                isTablet
                                    ? Container(
                                      width: 10.w,
                                      height: 10.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                      ),
                                      child: CustomNetworkImage(
                                        imageUrl:
                                            profile?.avatarUrls?.s96 ?? '',
                                        height: 10.w,
                                        width: 10.w,
                                        isCircle: true,
                                        isProfile: true,
                                        isFit: true,
                                      ),
                                    )
                                    : Container(
                                      width: 20.w,
                                      height: 20.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                      ),
                                      child: CustomNetworkImage(
                                        imageUrl:
                                            profile?.avatarUrls?.s96 ?? '',
                                        height: 20.w,
                                        width: 20.w,
                                        isCircle: true,
                                        isProfile: true,
                                        isFit: true,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 13.h : 9.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 2.h,
                        horizontal: 4.w,
                      ),
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
                                Icons.info_outline,
                                color: AppColors.mainColor,
                                size: 18.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'User Name',
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
                            profile?.username ?? '',
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
                                Icons.fiber_manual_record_sharp,
                                color: AppColors.mainColor,
                                size: 18.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'First Name',
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
                            profile?.firstName ?? '',
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
                                Icons.fiber_smart_record_sharp,
                                color: AppColors.mainColor,
                                size: 18.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Last Name',
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
                            profile?.lastName ?? '',
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
                                Icons.drive_file_rename_outline,
                                color: AppColors.mainColor,
                                size: 18.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Nick Name',
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
                            profile?.nickname ?? '',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontFamily: FontFamily.semiBold,
                              color: AppColors.blackColor,
                            ),
                          ),
                          // Divider(height: 2.h, color: Colors.grey[300]),
                          //
                          // Row(
                          //   children: [
                          //     Icon(
                          //       Icons.location_city_rounded,
                          //       color: AppColors.mainColor,
                          //       size: 18.sp,
                          //     ),
                          //     SizedBox(width: 2.w),
                          //     Text(
                          //       'Address',
                          //       style: TextStyle(
                          //         fontSize: 17.sp,
                          //         fontFamily: FontFamily.bold,
                          //         color: AppColors.mainColor,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 0.5.h),
                          // Text(
                          //   '117, Albany Gardens',
                          //   style: TextStyle(
                          //     fontSize: 17.sp,
                          //     fontFamily: FontFamily.semiBold,
                          //     color: AppColors.blackColor,
                          //   ),
                          // ),
                          // Divider(height: 2.h, color: Colors.grey[300]),
                          // Row(
                          //   children: [
                          //     Icon(
                          //       Icons.location_city_rounded,
                          //       color: AppColors.mainColor,
                          //       size: 18.sp,
                          //     ),
                          //     SizedBox(width: 2.w),
                          //     Text(
                          //       'City',
                          //       style: TextStyle(
                          //         fontSize: 17.sp,
                          //         fontFamily: FontFamily.bold,
                          //         color: AppColors.mainColor,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 0.5.h),
                          // Text(
                          //   'Colchester',
                          //   style: TextStyle(
                          //     fontSize: 17.sp,
                          //     fontFamily: FontFamily.semiBold,
                          //     color: AppColors.blackColor,
                          //   ),
                          // ),
                          // Divider(height: 2.h, color: Colors.grey[300]),
                          // Row(
                          //   children: [
                          //     Icon(
                          //       Icons.location_city_rounded,
                          //       color: AppColors.mainColor,
                          //       size: 18.sp,
                          //     ),
                          //     SizedBox(width: 2.w),
                          //     Text(
                          //       'State',
                          //       style: TextStyle(
                          //         fontSize: 17.sp,
                          //         fontFamily: FontFamily.bold,
                          //         color: AppColors.mainColor,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 0.5.h),
                          // Text(
                          //   'Essex',
                          //   style: TextStyle(
                          //     fontSize: 17.sp,
                          //     fontFamily: FontFamily.semiBold,
                          //     color: AppColors.blackColor,
                          //   ),
                          // ),
                          // Divider(height: 2.h, color: Colors.grey[300]),
                          // Row(
                          //   children: [
                          //     Icon(
                          //       Icons.location_city_rounded,
                          //       color: AppColors.mainColor,
                          //       size: 18.sp,
                          //     ),
                          //     SizedBox(width: 2.w),
                          //     Text(
                          //       'Country',
                          //       style: TextStyle(
                          //         fontSize: 17.sp,
                          //         fontFamily: FontFamily.bold,
                          //         color: AppColors.mainColor,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 0.5.h),
                          // Text(
                          //   'United Kingdom',
                          //   style: TextStyle(
                          //     fontSize: 17.sp,
                          //     fontFamily: FontFamily.semiBold,
                          //     color: AppColors.blackColor,
                          //   ),
                          // ),
                          // Divider(height: 2.h, color: Colors.grey[300]),
                          // Row(
                          //   children: [
                          //     Icon(
                          //       Icons.date_range_rounded,
                          //       color: AppColors.mainColor,
                          //       size: 18.sp,
                          //     ),
                          //     SizedBox(width: 2.w),
                          //     Text(
                          //       'Date of Birth',
                          //       style: TextStyle(
                          //         fontSize: 17.sp,
                          //         fontFamily: FontFamily.bold,
                          //         color: AppColors.mainColor,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 0.5.h),
                          // Text(
                          //   '01 Jan 1990',
                          //   style: TextStyle(
                          //     fontSize: 17.sp,
                          //     fontFamily: FontFamily.semiBold,
                          //     color: AppColors.blackColor,
                          //   ),
                          // ),
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
                    SizedBox(height: 3.h),
                  ],
                ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
              ),
      bottomNavigationBar: SizedBox(
        height: isTablet ? 14.h : 10.h,
        child: CustomBar(selected: 5),
      ),
    );
  }

  Future<void> _fetchProfile() async {
    var box = HiveService().getProfileBox();

    if (!await checkInternet()) {
      final cachedData = box.get('profile');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        profile = ProfileModal.fromJson(data);
      } else {
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
      }
      return;
    }

    try {
      final response = await ProfileProvider().fetchProfile();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        profile = ProfileModal.fromJson(data);
        await box.put('profile', response.body);
      } else {
        final cachedData = box.get('profile');
        if (cachedData != null) {
          final data = json.decode(cachedData);
          profile = ProfileModal.fromJson(data);
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      final cachedData = box.get('profile');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        profile = ProfileModal.fromJson(data);
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }
}
