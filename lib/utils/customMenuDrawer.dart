import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/Apicalling/sharedpreferance.dart';
import 'package:bellissemo_ecom/ui/cart/View/cartScreen.dart';
import 'package:bellissemo_ecom/ui/customers/view/customersScreen.dart';
import 'package:bellissemo_ecom/ui/login/view/loginScreen.dart';
import 'package:bellissemo_ecom/ui/orderhistory/view/orderHistoryScreen.dart';
import 'package:bellissemo_ecom/ui/profile/view/profileScreen.dart';
import 'package:bellissemo_ecom/utils/snackBars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/colors.dart';
import '../../../utils/fontFamily.dart';
import '../ApiCalling/apiConfigs.dart';
import '../apiCalling/checkInternetModule.dart';
import '../services/hiveServices.dart';
import '../ui/category/view/categoryScreen.dart';
import '../ui/home/view/homeMenuScreen.dart';
import '../ui/profile/modal/profileModal.dart';
import '../ui/profile/provider/profileProvider.dart';
import '../ui/reports/view/reportsScreen.dart';
import 'cachedNetworkImage.dart';
import 'customButton.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

bool isIpad = 100.w >= 800;
bool isLoading = true;
bool isFiltering = true;

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInitialData();
  }

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
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: Device.height,
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  backgroundColor: AppColors.mainColor,
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      bottom: 2.h,
                      left: 4.w,
                      right: 4.w,
                      top: 8.h,
                    ),
                    color: AppColors.mainColor.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        CustomNetworkImage(
                          imageUrl: profile?.avatarUrls?.s96 ?? '',
                          height: 60,
                          width: 60,
                          isCircle: true,
                          isProfile: true,
                        ),
                        SizedBox(width: 3.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile?.name ?? '',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontFamily: FontFamily.bold,
                                  color: AppColors.blackColor,
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
                                  color: AppColors.gray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Spacer(),
                        // // Close button
                        // IconButton(
                        //   onPressed: widget.onClose,
                        //   icon: Icon(Icons.close, size: 28, color: AppColors.blackColor),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  _drawerItem(Icons.home_outlined, "Home", () {
                    Get.offAll(HomeMenuScreen());
                  }),
                  // _drawerItem(Icons.home_outlined, "Home 2", () {
                  //   Get.offAll(() => Homescreen());
                  // }),
                  _drawerItem(Icons.shopping_bag_outlined, "Orders", () {
                    Get.offAll(() => OrderHistoryScreen());
                  }),
                  _drawerItem(Icons.menu_book_outlined, "Catalog", () {
                    Get.offAll(() => CategoriesScreen());
                  }),
                  _drawerItem(Icons.people_alt_outlined, "Customers", () {
                    Get.to(() => CustomersScreen());
                  }),
                  _drawerItem(Icons.area_chart, "Report", () {
                    Get.to(() => ReportScreen());
                  }),
                  _drawerItem(Icons.shopping_cart_outlined, "Cart", () {
                    Get.offAll(() => CartScreen());
                  }),
                  _drawerItem(Icons.person_outline, "Account", () {
                    Get.offAll(() => ProfileScreen());
                  }),

                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: CustomButton(
                      title: "Log Out",
                      route: () {
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
                                    final prefs =
                                        await SharedPreferences.getInstance();
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
                      },
                      color: AppColors.mainColor,
                      fontcolor: AppColors.whiteColor,
                      height: 6.h,
                      width: double.infinity,
                      fontsize: 18.sp,
                      fontWeight: FontWeight.w400,
                      radius: isIpad ? 1.w : 3.w,
                      iconData: Icons.logout,
                      iconsize: 20.sp,
                      shadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 1.w),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.mainColor,
          size: isIpad ? 18.sp : 20.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isIpad ? 16.sp : 18.sp,
            fontFamily: FontFamily.bold,
            color: AppColors.blackColor,
          ),
        ),
        onTap: onTap,
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
