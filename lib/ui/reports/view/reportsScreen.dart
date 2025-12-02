import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/colors.dart';
import '../../../utils/customMenuDrawer.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/searchFields.dart';
import '../../../utils/titlebarWidget.dart';
import '../../customers/view/customerReportScreen.dart';
import '../../products/view/ProductReportScreen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();

  String selectedFilter = "This Year";
  final List<String> filters = ["This Year", "This Month", "This Week"];

  List<Map<String, dynamic>> apiData = [
    {
      "x": 9,
      "y": 30,
      "gradientColors": [Colors.greenAccent, Colors.green],
    },
    {
      "x": 12,
      "y": 50,
      "gradientColors": [Colors.blueAccent, Colors.blue],
    },
    {
      "x": 15,
      "y": 35,
      "gradientColors": [Colors.orangeAccent, Colors.orange],
    },
    {
      "x": 18,
      "y": 45,
      "gradientColors": [Colors.purpleAccent, Colors.purple],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerColor,
      body: Column(
        children: [
          TitleBar(
            title: 'Report',
            isDrawerEnabled: false,
            isSearchEnabled: false,
            isBackEnabled: true,
            onSearch: () {
              setState(() {
                isSearchEnabled = !isSearchEnabled;
              });
            },
          ),
          if (isSearchEnabled) SearchField(controller: searchController),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.4),
                child: _drawerItem(Icons.area_chart, "Customers Report", () {
                  Get.to(() => CustomerReportScreen());
                }),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.4),
                child:  _drawerItem(Icons.area_chart, "Product Report", () {
                  Get.to(() => ProducatReportScreen());
                }),
              ),

              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 3.w),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(30),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black12,
              //         blurRadius: 6,
              //         offset: Offset(0, 3),
              //       ),
              //     ],
              //   ),
              //   child: Row(
              //     children: [
              //       Text(
              //         "Filter by",
              //         style: TextStyle(
              //           fontSize: 15.sp,
              //           fontFamily: FontFamily.semiBold,
              //           color: AppColors.blackColor,
              //         ),
              //       ),
              //       SizedBox(width: 3.w),
              //       Expanded(
              //         child: DropdownButtonHideUnderline(
              //           child: DropdownButton<String>(
              //             value: selectedFilter,
              //             isExpanded: true,
              //             icon: Icon(
              //               Icons.arrow_drop_down,
              //               color: AppColors.gray,
              //             ),
              //             borderRadius: BorderRadius.circular(12),
              //             dropdownColor: Colors.white,
              //             items:
              //                 filters.map((String filter) {
              //                   return DropdownMenuItem<String>(
              //                     value: filter,
              //                     child: Text(
              //                       filter,
              //                       style: TextStyle(
              //                         fontSize: 15.sp,
              //                         fontFamily: FontFamily.semiBold,
              //                         color: AppColors.mainColor,
              //                       ),
              //                     ),
              //                   );
              //                 }).toList(),
              //             onChanged: (String? newValue) {
              //               if (newValue != null) {
              //                 setState(() {
              //                   selectedFilter = newValue;
              //                 });
              //               }
              //             },
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              //
              // SizedBox(height: 3.h),
              //
              // // Chart
              // SizedBox(
              //   height: 28.h,
              //   child: Stack(
              //     children: [
              //       BarChart(
              //         BarChartData(
              //           gridData: FlGridData(
              //             show: true,
              //             drawHorizontalLine: true,
              //             getDrawingHorizontalLine:
              //                 (value) => FlLine(
              //                   color: Colors.grey.shade300,
              //                   strokeWidth: 1,
              //                 ),
              //           ),
              //           borderData: FlBorderData(show: false),
              //           titlesData: FlTitlesData(
              //             bottomTitles: AxisTitles(
              //               sideTitles: SideTitles(
              //                 showTitles: true,
              //                 reservedSize: 30,
              //                 getTitlesWidget: (value, meta) {
              //                   return Text(
              //                     "${value.toInt()}PM",
              //                     // dynamic label if needed
              //                     style: TextStyle(color: AppColors.gray),
              //                   );
              //                 },
              //               ),
              //             ),
              //             leftTitles: AxisTitles(
              //               sideTitles: SideTitles(
              //                 showTitles: true,
              //                 reservedSize: 35,
              //                 getTitlesWidget:
              //                     (value, meta) => Text(
              //                       "${value.toInt()}mi",
              //                       style: TextStyle(
              //                         color: AppColors.gray,
              //                         fontFamily: FontFamily.semiBold,
              //                       ),
              //                     ),
              //               ),
              //             ),
              //             rightTitles: AxisTitles(
              //               sideTitles: SideTitles(showTitles: false),
              //             ),
              //             topTitles: AxisTitles(
              //               sideTitles: SideTitles(showTitles: false),
              //             ),
              //           ),
              //           barGroups:
              //               apiData.map((item) {
              //                 // item should have: x, y, color
              //                 return BarChartGroupData(
              //                   x: item['x'],
              //                   barRods: [
              //                     BarChartRodData(
              //                       toY: item['y'].toDouble(),
              //                       width: 16,
              //                       borderRadius: BorderRadius.circular(6),
              //                       gradient: LinearGradient(
              //                         colors: item['gradientColors'],
              //                         begin: Alignment.bottomCenter,
              //                         end: Alignment.topCenter,
              //                       ),
              //                       backDrawRodData: BackgroundBarChartRodData(
              //                         show: true,
              //                         toY: 60,
              //                         color: Colors.grey.shade200,
              //                       ),
              //                     ),
              //                   ],
              //                 );
              //               }).toList(),
              //           barTouchData: BarTouchData(
              //             enabled: true,
              //             touchTooltipData: BarTouchTooltipData(
              //               tooltipPadding: EdgeInsets.symmetric(
              //                 horizontal: 8,
              //                 vertical: 4,
              //               ),
              //               tooltipMargin: 8,
              //               getTooltipItem: (group, groupIndex, rod, rodIndex) {
              //                 return BarTooltipItem(
              //                   "${rod.toY.toInt()} units",
              //                   TextStyle(
              //                     color: Colors.white,
              //                     fontWeight: FontWeight.bold,
              //                     fontSize: 12.sp,
              //                   ),
              //                 );
              //               },
              //             ),
              //           ),
              //         ),
              //       ),
              //
              //       LineChart(
              //         LineChartData(
              //           minX: 6.9,
              //           maxX: 18,
              //           minY: 0,
              //           maxY: 60,
              //           gridData: FlGridData(show: false),
              //           titlesData: FlTitlesData(show: false),
              //           borderData: FlBorderData(show: false),
              //           lineBarsData: [
              //             LineChartBarData(
              //               spots:
              //                   apiData
              //                       .map(
              //                         (item) => FlSpot(
              //                           item['x'].toDouble(),
              //                           item['y'].toDouble(),
              //                         ),
              //                       )
              //                       .toList(),
              //               isCurved: true,
              //               color: AppColors.mainColor,
              //               barWidth: 3,
              //               belowBarData: BarAreaData(
              //                 show: true,
              //                 gradient: LinearGradient(
              //                   colors: [
              //                     AppColors.mainColor.withOpacity(0.4),
              //                     AppColors.mainColor.withOpacity(0.05),
              //                   ],
              //                   begin: Alignment.topCenter,
              //                   end: Alignment.bottomCenter,
              //                 ),
              //               ),
              //               dotData: FlDotData(show: true),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              //
              // SizedBox(height: 5.h),
              // Container(
              //   padding: EdgeInsets.all(2.w),
              //   decoration: BoxDecoration(
              //     color: AppColors.whiteColor,
              //     borderRadius: BorderRadius.circular(15),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.shade300,
              //         blurRadius: 10,
              //         offset: Offset(0, 5),
              //       ),
              //     ],
              //   ),
              //   child: Row(
              //     children: [
              //       CircleAvatar(
              //         radius: 22,
              //         backgroundColor: AppColors.greenColor.withOpacity(0.2),
              //         child: Icon(
              //           Icons.currency_rupee,
              //           color: AppColors.greenColor,
              //           size: 22,
              //         ),
              //       ),
              //       SizedBox(width: 3.w),
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Row(
              //             children: [
              //               Text(
              //                 "Revenue ",
              //                 style: TextStyle(
              //                   fontSize: 17.sp,
              //                   color: AppColors.gray,
              //                   fontFamily: FontFamily.bold,
              //                 ),
              //               ),
              //               SizedBox(width: 1.w),
              //               Icon(
              //                 Icons.stacked_line_chart_rounded,
              //                 color: AppColors.greenColor,
              //                 size: 22,
              //               ),
              //               Text(
              //                 "5%",
              //                 style: TextStyle(
              //                   fontSize: 17.sp,
              //                   color: AppColors.greenColor,
              //                   fontFamily: FontFamily.bold,
              //                 ),
              //               ),
              //             ],
              //           ),
              //           Text(
              //             "74,25,699 INR ",
              //             style: TextStyle(
              //               fontSize: 20.sp,
              //               color: AppColors.blackColor,
              //               fontFamily: FontFamily.bold,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 2.h),
              // Container(
              //   padding: EdgeInsets.all(2.w),
              //   decoration: BoxDecoration(
              //     color: AppColors.whiteColor,
              //     borderRadius: BorderRadius.circular(15),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.shade300,
              //         blurRadius: 10,
              //         offset: Offset(0, 5),
              //       ),
              //     ],
              //   ),
              //   child: Row(
              //     children: [
              //       CircleAvatar(
              //         radius: 22,
              //         backgroundColor: AppColors.appBlueColor.withOpacity(0.2),
              //         child: Icon(
              //           Icons.payments_outlined,
              //           color: AppColors.appBlueColor,
              //           size: 22,
              //         ),
              //       ),
              //       SizedBox(width: 3.w),
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Row(
              //             children: [
              //               Text(
              //                 "Total Payment",
              //                 style: TextStyle(
              //                   fontSize: 17.sp,
              //                   color: AppColors.gray,
              //                   fontFamily: FontFamily.bold,
              //                 ),
              //               ),
              //               SizedBox(width: 1.w),
              //               Icon(
              //                 Icons.stacked_line_chart_rounded,
              //                 color: AppColors.greenColor,
              //                 size: 22,
              //               ),
              //               Text(
              //                 "1%",
              //                 style: TextStyle(
              //                   fontSize: 17.sp,
              //                   color: AppColors.greenColor,
              //                   fontFamily: FontFamily.bold,
              //                 ),
              //               ),
              //             ],
              //           ),
              //           Text(
              //             "74,25,699 INR ",
              //             style: TextStyle(
              //               fontSize: 20.sp,
              //               color: AppColors.blackColor,
              //               fontFamily: FontFamily.bold,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              // // // Cards
              // // _StatCard(
              // //   icon: Icons.attach_money,
              // //   iconColor: Colors.green,
              // //   title: "Revenue",
              // //   value: "7,429,563 VND",
              // //   percentage: "+5%",
              // //   percentageColor: Colors.greenAccent,
              // // ),
              // // SizedBox(height: 1.5.h),
              // // _StatCard(
              // //   icon: Icons.receipt_long,
              // //   iconColor: Colors.blue,
              // //   title: "Total receipts",
              // //   value: "124 receipts",
              // //   percentage: "-1%",
              // //   percentageColor: Colors.redAccent,
              // // ),
              // // SizedBox(height: 1.5.h),
              // // _StatCard(
              // //   icon: Icons.payment,
              // //   iconColor: Colors.purple,
              // //   title: "Total payment",
              // //   value: "7,427,153 VND",
              // //   percentage: "+5%",
              // //   percentageColor: Colors.greenAccent,
              // // ),
            ],
          ),
        ],
      ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String percentage;
  final Color percentageColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.percentage,
    required this.percentageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      percentage,
                      style: TextStyle(
                        color: percentageColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }
}
