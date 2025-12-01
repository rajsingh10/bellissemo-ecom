import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/colors.dart';
import '../../../utils/customMenuDrawer.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/titlebarWidget.dart';
import '../../customers/provider/customerProvider.dart';
import '../modal/ProductReportModal.dart';


class ProducatReportScreen extends StatefulWidget {
  const ProducatReportScreen({super.key});

  @override
  State<ProducatReportScreen> createState() => _ProducatReportScreenState();
}

class _ProducatReportScreenState extends State<ProducatReportScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyCustomerreport =
  GlobalKey<ScaffoldState>();

  String selectedFilter = "Yearly";

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  Future<void> pickFromDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime(now.year, 1, 1),
      firstDate: DateTime(now.year, 1, 1),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        fromDate = picked;
        _fetchCustomerReport();
      });
    }
  }

  Future<void> pickToDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? now,
      firstDate: DateTime(now.year, 1, 1),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        toDate = picked;
        _fetchCustomerReport();
      });
    }
  }

  List<Map<String, dynamic>> customers = [
    {"name": "John Doe", "totalSales": 18500},
    {"name": "Emma Stone", "totalSales": 22400},
    {"name": "Robert Smith", "totalSales": 15200},
    {"name": "Sophia Lee", "totalSales": 31800},
  ];
  bool isIpad = 100.w >= 800;

  @override
  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();

    setState(() {
      // default from date = 1 Jan of current year
      fromDate = DateTime(now.year, 1, 1);

      // default to date = today
      toDate = now;
    });

    print("fromDate => ${DateFormat('yyyy-MM-dd').format(fromDate)}");
    print("toDate   => ${DateFormat('yyyy-MM-dd').format(toDate)}");

    loadInitialData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      drawer: CustomDrawer(),
      key: _scaffoldKeyCustomerreport,
      body: isLoading?Loader():Column(
        children: [
          TitleBar(
            title: 'Product Reports',
            isDrawerEnabled: true,
            isSearchEnabled: false,
            drawerCallback: () {
              _scaffoldKeyCustomerreport.currentState?.openDrawer();
            },
          ),

          // ---------- FILTERS ----------
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                // Filter type
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     filterChip("Monthly"),
                //     filterChip("Quarterly"),
                //     filterChip("Yearly"),
                //   ],
                // ),
                // const SizedBox(height: 15),

                // Date pickers
                Row(
                  children: [
                    Expanded(
                      child: datePickerBox(
                        title: "From Date",
                        value:
                        fromDate == null
                            ? "Select"
                            : DateFormat('dd-MM-yyyy').format(fromDate!),
                        onTap: pickFromDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: datePickerBox(
                        title: "To Date",
                        value:
                        toDate == null
                            ? "Select"
                            : DateFormat('dd-MM-yyyy').format(toDate!),
                        onTap: pickToDate,
                      ),
                    ),
                  ],
                ),

                // const SizedBox(height: 15),
                //
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: AppColors.mainColor,
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 30,
                //       vertical: 12,
                //     ),
                //   ),
                //   onPressed: () {
                //     // CALL YOUR API HERE
                //     _fetchCustomerReport();
                //   },
                //   child: const Text(
                //     "Apply Filter",
                //     style: TextStyle(color: Colors.white),
                //   ),
                // ),
              ],
            ),
          ),

          Row(
            children: [
              Text(
                "Top Category",
                style: TextStyle(
                  fontSize: 17.sp,
                  fontFamily: FontFamily.bold,
                  color: AppColors.blackColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // SizedBox(
          //   height: isIpad ? 13.h : 14.h,
          //   child: ListView.builder(
          //     padding: EdgeInsets.zero,
          //     scrollDirection: Axis.horizontal,
          //
          //     // IMPORTANT → leaderboard ની length
          //     itemCount:
          //     customerReportList.isNotEmpty
          //         ? customerReportList[0].topCategories?.length ?? 0
          //         : 0,
          //
          //     itemBuilder: (context, index) {
          //       var customer = customerReportList[0];
          //       var leadbord = customer.topCategories?[index];
          //
          //       return Card(
          //         elevation: 3,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: Container(
          //           padding: EdgeInsets.symmetric(
          //             horizontal: 2.w,
          //             vertical: 1.h,
          //           ),
          //           child: Row(
          //             children: [
          //               Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   // NAME
          //                   Row(
          //                     children: [
          //                       Text(
          //                         "Category Name :- ",
          //                         style: TextStyle(
          //                           fontSize: 16.sp,
          //                           fontFamily: FontFamily.bold,
          //                           color: AppColors.mainColor,
          //                         ),
          //                       ),
          //                       Text(
          //                         leadbord?.category ?? "",
          //                         style: TextStyle(
          //                           fontSize: 16.sp,
          //                           fontFamily: FontFamily.bold,
          //                           color: AppColors.blackColor,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //
          //                   // EMAIL
          //                   Row(
          //                     children: [
          //                       Text(
          //                         "Qty:- ",
          //                         style: TextStyle(
          //                           fontSize: 16.sp,
          //                           fontFamily: FontFamily.bold,
          //                           color: AppColors.mainColor,
          //                         ),
          //                       ),
          //                       Text(
          //                         leadbord?.qty ?? "",
          //                         style: TextStyle(
          //                           fontSize: 16.sp,
          //                           fontFamily: FontFamily.bold,
          //                           color: AppColors.blackColor,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //
          //                   // SPENT
          //                   Row(
          //                     children: [
          //                       Text(
          //                         "Total Revenue :- ",
          //                         style: TextStyle(
          //                           fontSize: 16.sp,
          //                           fontFamily: FontFamily.bold,
          //                           color: AppColors.mainColor,
          //                         ),
          //                       ),
          //                       Text(
          //                         "${customer.currencySymbol} ${leadbord?.revenue ?? "0"}",
          //                         style: TextStyle(
          //                           fontSize: 16.sp,
          //                           fontFamily: FontFamily.bold,
          //                           color: AppColors.blackColor,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //
          //                   // AVG ORDER
          //
          //                 ],
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          SizedBox(
            height: isIpad ? 16.5.h : 12.h,
            child: customerReportList.isEmpty ||
                customerReportList[0].topCategories == null ||
                customerReportList[0].topCategories!.isEmpty
                ? Center(
              child: Text(
                "No Categories Available",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: FontFamily.bold,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,

              // Length of topCategories
              itemCount: customerReportList[0].topCategories!.length,

              itemBuilder: (context, index) {
                var customer = customerReportList[0];
                var leadbord = customer.topCategories?[index];

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(

                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 1.h,
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CATEGORY NAME
                            Row(
                              children: [
                                Text(
                                  "Category Name :- ",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                                Text(
                                  leadbord?.category ?? "N/A",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ],
                            ),

                            // QTY
                            Row(
                              children: [
                                Text(
                                  "Qty:- ",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                                Text(
                                  leadbord?.qty ?? "0",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ],
                            ),

                            // TOTAL REVENUE
                            Row(
                              children: [
                                Text(
                                  "Total Revenue :- ",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                                Text(
                                  "${customer.currencySymbol} ${leadbord?.revenue ?? "0"}",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 1.h),
          Row(
            children: [
              Text(
                "Top Products",
                style: TextStyle(
                  fontSize: 17.sp,
                  fontFamily: FontFamily.bold,
                  color: AppColors.blackColor,
                ),
              ),
            ],
          ),

          // ---------- CUSTOMER SALES LIST ----------
          // Expanded(
          //   child: SingleChildScrollView(
          //     padding: const EdgeInsets.only(bottom: 20),
          //     child: Column(
          //       children: [
          //         // Loop through CustomerReportModal list
          //         for (var customer in customerReportList)
          //         // Loop through ONLY topProducts inside each customer
          //           if (customer.data != null)
          //             if (customer.data != null)
          //               for (var p in customer.data!)
          //                 Card(
          //                   elevation: 3,
          //                   shadowColor: Colors.white,
          //                   margin: EdgeInsets.symmetric(
          //                     horizontal: 2.w,
          //                     vertical: 1.h,
          //                   ),
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(10),
          //                   ),
          //                   child: Padding(
          //                     padding: EdgeInsets.symmetric(
          //                       horizontal: 2.w,
          //                       vertical: 1.2.h,
          //                     ),
          //                     child: Row(
          //                       children: [
          //                         // IMAGE
          //                         ClipRRect(
          //                           borderRadius: BorderRadius.circular(8),
          //                           child: CustomNetworkImage(
          //                             imageUrl: p.image ?? "",
          //                             height: 12.w,
          //                             width: 12.w,
          //                             isFit: true,
          //                             radius: 0,
          //                           ),
          //                         ),
          //
          //                         SizedBox(width: 3.w),
          //
          //                         // TITLE + DETAILS
          //                         Expanded(
          //                           child: Column(
          //                             crossAxisAlignment:
          //                             CrossAxisAlignment.start,
          //                             mainAxisAlignment:
          //                             MainAxisAlignment.start,
          //                             children: [
          //                               Text(
          //                                 p.productName==null||  p.productName==""?"N/A": p.productName ?? "N/A",
          //                                 maxLines: 2,
          //                                 overflow: TextOverflow.ellipsis,
          //                                 style: TextStyle(
          //                                   fontSize: 16.sp,
          //                                   fontFamily: FontFamily.bold,
          //                                   color: AppColors.blackColor,
          //                                 ),
          //                               ),
          //                               Text(
          //                                 "Qty:- ${p.totalQty ?? ""}",
          //                                 maxLines: 2,
          //                                 overflow: TextOverflow.ellipsis,
          //                                 style: TextStyle(
          //                                   fontSize: 16.sp,
          //                                   fontFamily: FontFamily.bold,
          //                                   color: AppColors.blackColor,
          //                                 ),
          //                               ),
          //                             ],
          //                           ),
          //                         ),
          //
          //                         SizedBox(width: 2.w),
          //
          //                         // PRICE
          //                         Text(
          //                           "${customer.currencySymbol} ${p.totalRevenue ?? '0'}",
          //                           style: TextStyle(
          //                             fontSize: 16.sp,
          //                             fontFamily: FontFamily.bold,
          //                             color: AppColors.mainColor,
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  if (customerReportList.isEmpty) ...[
                    Center(
                      child: Text(
                        "No Customer Data Available",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: FontFamily.bold,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ] else ...[
                    for (var customer in customerReportList)
                      if (customer.data != null && customer.data!.isNotEmpty) ...[
                        for (var p in customer.data!)
                          Card(
                            elevation: 3,
                            shadowColor: Colors.white,
                            margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.2.h),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CustomNetworkImage(
                                      imageUrl: p.image ?? "",
                                      height: 12.w,
                                      width: 12.w,
                                      isFit: true,
                                      radius: 0,
                                    ),
                                  ),

                                  SizedBox(width: 3.w),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.productName == null || p.productName == ""
                                              ? "N/A"
                                              : p.productName!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontFamily: FontFamily.bold,
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                        Text(
                                          "Qty:- ${p.totalQty ?? ""}",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontFamily: FontFamily.bold,
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: 2.w),

                                  Text(
                                    "${customer.currencySymbol} ${p.totalRevenue ?? '0'}",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontFamily: FontFamily.bold,
                                      color: AppColors.mainColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ] else ...[
                        // Show message when no products inside customer
                        Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Center(
                            child: Text(
                              "No Products Available",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: FontFamily.semiBold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      ]
                  ],
                ],
              ),
            ),
          ),

        ],
      ).paddingSymmetric(horizontal: 2.w),
    );
  }

  Future<void> _fetchCustomerReport() async {
    setState(() {
      isLoading=true;
    });
    var box = HiveService().getProductReportBox();

    if (!await checkInternet()) {
      _loadCachedCustomerReport();
      return;
    }

    try {
      final response = await CustomerProvider().productReport(

        fromDate:DateFormat('yyyy-MM-dd').format(fromDate),
        toDate:DateFormat('yyyy-MM-dd').format(toDate),
        groupBy: "monthly",
      );

      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List) {
          customerReportList =
              decoded
                  .map<ProductReportModal>(
                    (e) => ProductReportModal.fromJson(e),
              )
                  .toList();
          setState(() {
            isLoading=false;
          });
        } else if (decoded is Map<String, dynamic>) {
          customerReportList = [ProductReportModal.fromJson(decoded)];
        }

        await box.put('product_report', response.body);
        setState(() {
          isLoading=false;
        });
      } else {
        _loadCachedCustomerReport();
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (e, stackTrace) {
      print("Error Fetching Customer Report: $e");
      print("StackTrace: $stackTrace");

      _loadCachedCustomerReport();
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);

    _loadCachedCustomerReport();

    try {
      await _fetchCustomerReport();
    } catch (e) {
      log("Error loading customers: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<ProductReportModal> customerReportList = [];
  List<ProductReportModal> filteredCustomerReportList = [];

  void _loadCachedCustomerReport() {
    var reportBox = HiveService().getProductReportBox();

    final cachedReport = reportBox.get('product_report');

    if (cachedReport != null) {
      final decoded = json.decode(cachedReport);

      if (decoded is List) {
        customerReportList =
            decoded
                .map<ProductReportModal>(
                  (e) => ProductReportModal.fromJson(e),
            )
                .toList();
      } else if (decoded is Map<String, dynamic>) {
        customerReportList = [ProductReportModal.fromJson(decoded)];
      }

      filteredCustomerReportList = List.from(customerReportList);
    }
  }

  Widget filterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.mainColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.mainColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget datePickerBox({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 14)),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
