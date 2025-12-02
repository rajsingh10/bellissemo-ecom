import 'package:bellissemo_ecom/ui/reports/view/productReportScreen.dart';
import 'package:bellissemo_ecom/utils/customBottombar.dart';
import 'package:bellissemo_ecom/utils/verticleBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/colors.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/titlebarWidget.dart'; // Ensuring TitleBar is imported here
import 'customerReportScreen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();

  // Logic variables
  bool isIpad = 100.w >= 800;
  String selectedFilter = "This Year";
  final List<String> filters = ["This Year", "This Month", "This Week"];

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        // --- RESPONSIVE LOGIC ---
        bool isWideDevice = 100.w >= 700;
        bool isLandscape = orientation == Orientation.landscape;
        bool showSideBar =
            isWideDevice &&
            isLandscape; // This determines if "Vertical Bar" is shown

        int navigationIndex = 5;

        return Scaffold(
          backgroundColor: AppColors.containerColor,
          // SIDEBAR LOGIC
          body:
              showSideBar
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
                        child: VerticleBar(selected: navigationIndex),
                      ),
                      Expanded(child: _buildReportContent(showSideBar: true)),
                    ],
                  )
                  : _buildReportContent(showSideBar: false),

          // BOTTOM BAR LOGIC
          bottomNavigationBar:
              showSideBar
                  ? null
                  : SizedBox(
                    height: isIpad ? 12.h : 10.h,
                    child: CustomBar(selected: 10),
                  ),
        );
      },
    );
  }

  Widget _buildReportContent({required bool showSideBar}) {
    return Column(
      children: [
        !showSideBar
            ? TitleBarIpadPotrait(title: 'Report', isBackEnabled: true)
            : TitleBar(title: 'Report', isBackEnabled: true),

        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: Colors.grey.withOpacity(0.4),
                    child: _drawerItem(
                      Icons.area_chart,
                      "Customers Report",
                      () {
                        Get.to(() => CustomerReportScreen());
                      },
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: Colors.grey.withOpacity(0.4),
                    child: _drawerItem(
                      Icons.perm_data_setting_outlined,
                      "Product Report",
                      () {
                        Get.to(() => ProductReportScreen());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: isIpad ? 14.sp : 16.sp,
          color: AppColors.mainColor,
        ),
        onTap: onTap,
      ),
    );
  }
}
