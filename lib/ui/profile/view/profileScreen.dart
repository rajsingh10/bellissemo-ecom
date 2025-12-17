import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/customMenuDrawer.dart';
import 'package:bellissemo_ecom/utils/verticleBar.dart'; // Ensure this is imported
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../ApiCalling/apiConfigs.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/titlebarWidget.dart';
import '../modal/profileModal.dart';
import '../provider/profileProvider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  Orientation? _lastOrientation; // Track orientation changes

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);
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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  final GlobalKey<ScaffoldState> _scaffoldKeyProfile =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        // Handle orientation state updates
        if (_lastOrientation != orientation) {
          _lastOrientation = orientation;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        }

        // --- RESPONSIVE LOGIC ---
        bool isWideDevice = 100.w >= 700;
        bool isLandscape = orientation == Orientation.landscape;
        bool showSideBar = isWideDevice && isLandscape;

        return Scaffold(
          backgroundColor: AppColors.containerColor,
          drawer: CustomDrawer(),
          key: _scaffoldKeyProfile,
          body:
              isLoading
                  ? Loader()
                  : showSideBar
                  // Case 1: iPad Landscape (Sidebar + Content)
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: VerticleBar(selected: 5),
                      ),
                      Expanded(child: _buildMainContent(isWideDevice)),
                    ],
                  )
                  // Case 2: Mobile/Portrait (Content Only)
                  : _buildMainContent(isWideDevice),

          bottomNavigationBar:
              showSideBar
                  ? null
                  : SizedBox(
                    height: isWideDevice ? 14.h : 10.h,
                    child: CustomBar(selected: 5),
                  ),
        );
      },
    );
  }

  // Extracted Main Content to avoid duplication
  Widget _buildMainContent(bool isTablet) {
    return SingleChildScrollView(
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
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: CustomNetworkImage(
                              imageUrl: profile?.avatarUrls?.s96 ?? '',
                              height: 10.w,
                              width: 10.w,
                              isCircle: true,
                              isProfile: true,
                              isFit: true,
                              isAssetFit: true,
                            ),
                          )
                          : Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: CustomNetworkImage(
                              imageUrl: profile?.avatarUrls?.s96 ?? '',
                              height: 20.w,
                              width: 20.w,
                              isCircle: true,
                              isProfile: true,
                              isFit: true,
                              isAssetFit: true,
                            ),
                          ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 13.h : 9.h),
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
                // Commented sections from original code are preserved below if needed
                /*
                Divider(height: 2.h, color: Colors.grey[300]),
                Row(
                  children: [
                    Icon(Icons.location_city_rounded, color: AppColors.mainColor, size: 18.sp),
                    SizedBox(width: 2.w),
                    Text('Address', style: TextStyle(fontSize: 17.sp, fontFamily: FontFamily.bold, color: AppColors.mainColor)),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text('117, Albany Gardens', style: TextStyle(fontSize: 17.sp, fontFamily: FontFamily.semiBold, color: AppColors.blackColor)),
                Divider(height: 2.h, color: Colors.grey[300]),
                */
              ],
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(height: 3.h),
        ],
      ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
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
          context,title: 'No Internet',
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
          context,title: 'Server Error',
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
        context,title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }
}
