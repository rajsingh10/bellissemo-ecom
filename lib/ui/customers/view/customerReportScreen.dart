import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/ui/customers/modal/fetchCustomersModal.dart';
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
import '../modal/customerReportScreen.dart';
import '../provider/customerProvider.dart';

class CustomerReportScreen extends StatefulWidget {
  const CustomerReportScreen({super.key});

  @override
  State<CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends State<CustomerReportScreen> {
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
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime now = DateTime.now();
    _fetchCustomers();
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
  List<FetchCustomersModal> customersList = [];
  int? selectedCustomerId;
  String? selectedCustomerName;
  Future<void> _fetchCustomers() async {
    var box = HiveService().getCustomerBox();

    if (!await checkInternet()) {
      final cachedData = box.get('customers');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        customersList =
            data
                .map<FetchCustomersModal>(
                  (e) => FetchCustomersModal.fromJson(e),
            )
                .toList();
      } else {
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
      }
      return;
    }

    try {
      final response = await CustomerProvider().fetchCustomers();
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        customersList =
            data
                .map<FetchCustomersModal>(
                  (e) => FetchCustomersModal.fromJson(e),
            )
                .toList();

        await box.put('customers', response.body);
      } else {
        final cachedData = box.get('customers');
        if (cachedData != null) {
          final List data = json.decode(cachedData);
          customersList =
              data
                  .map<FetchCustomersModal>(
                    (e) => FetchCustomersModal.fromJson(e),
              )
                  .toList();
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      final cachedData = box.get('customers');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        customersList =
            data
                .map<FetchCustomersModal>(
                  (e) => FetchCustomersModal.fromJson(e),
            )
                .toList();
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      drawer: CustomDrawer(),
      key: _scaffoldKeyCustomerreport,
      body:isLoading?Loader(): Column(
        children: [
          TitleBar(
            title: 'Customer Reports',
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedCustomerId,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(90),
                            borderSide: BorderSide(
                              color: AppColors.mainColor,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(90),
                            borderSide: BorderSide(
                              color: AppColors.mainColor,
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintText: "Select Customer",
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        items: customersList.map((customer) {
                          return DropdownMenuItem<int>(
                            value: customer.id,
                            child: Text("${customer.firstName} ${customer.lastName}"),
                          );
                        }).toList(),
                        onChanged: (value) {
                          final customer = customersList.firstWhere((c) => c.id == value);
                          setState(() {
                            selectedCustomerId = customer.id;
                            selectedCustomerName = "${customer.firstName} ${customer.lastName}";
                            print("zxczxczxczxzc=====>>>>>>${selectedCustomerId}");
                            _fetchCustomerReport();
                          });
                        },
                      ),
                    )

                  ],
                ),
                SizedBox(height: 1.h,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    filterChip("Monthly"),
                    filterChip("Quarterly"),
                    filterChip("Yearly"),
                  ],
                ),
                const SizedBox(height: 15),

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
                //     // getCustomerData(selectedFilter, fromDate, toDate);
                //   },
                //   child: const Text(
                //     "Apply Filter",
                //     style: TextStyle(color: Colors.white),
                //   ),
                // ),
              ],
            ),
          ),

          const Divider(),
          Row(
            children: [
              Text(
                "LeadBoard",
                style: TextStyle(
                  fontSize: 17.sp,
                  fontFamily: FontFamily.bold,
                  color: AppColors.blackColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          SizedBox(
            height: isIpad ? 21.h : 14.h,
            child: customerReportList.isEmpty ||
                customerReportList[0].leaderboard == null ||
                customerReportList[0].leaderboard!.isEmpty
                ? Center(
              child: Text(
                "No Leaderboard Available",
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

              itemCount: customerReportList[0].leaderboard!.length,

              itemBuilder: (context, index) {
                var customer = customerReportList[0];
                var leadbord = customer.leaderboard?[index];

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
                            // NAME
                            Row(
                              children: [
                                Text(
                                  "Customer Name :- ",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                                Text(
                                  leadbord?.name ?? "N/A",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ],
                            ),

                            // EMAIL
                            Row(
                              children: [
                                Text(
                                  "Customer Email :- ",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                                Text(
                                  leadbord?.email ?? "N/A",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ],
                            ),

                            // SPENT
                            Row(
                              children: [
                                Text(
                                  "Spent :- ",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                                Text(
                                  "${customer.currencySymbol} ${leadbord?.spent ?? "0"}",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ],
                            ),

                            // AVG ORDER
                            Row(
                              children: [
                                Text(
                                  "AvgOrder :- ",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.bold,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                                Text(
                                  "${customer.currencySymbol} ${leadbord?.avgOrder ?? "0"}",
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
                "Order",
                style: TextStyle(
                  fontSize: 17.sp,
                  fontFamily: FontFamily.bold,
                  color: AppColors.blackColor,
                ),
              ),
            ],
          ),

          // ---------- CUSTOMER SALES LIST ----------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  if (customerReportList.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          "No Data Available",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: FontFamily.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    for (var customer in customerReportList)
                      if (customer.customerOrders != null &&
                          customer.customerOrders!.isNotEmpty) ...[
                        for (var p in customer.customerOrders!)
                          Card(
                            elevation: 3,
                            shadowColor: Colors.white,
                            margin: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 1.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 1.2.h,
                              ),
                              child: Row(
                                children: [
                                  // IMAGE
                                  // ClipRRect(
                                  //   borderRadius: BorderRadius.circular(8),
                                  //   child: CustomNetworkImage(
                                  //     imageUrl: p.items? ?? "",
                                  //     height: 12.w,
                                  //     width: 12.w,
                                  //     isFit: true,
                                  //     radius: 0,
                                  //   ),
                                  // ),

                                  // SizedBox(width: 3.w),

                                  // TITLE + DETAILS
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.customerName==" "||  p.customerName == null || p.customerName!.isEmpty
                                              ? "N/A"
                                              : p.customerName!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontFamily: FontFamily.bold,
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                        Text(
                                          "Order ID ${p.orderId ?? "0"}",
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

                                  // PRICE
                                  // Text(
                                  //   "${customer.currencySymbol} ${p.totalAmount ?? '0'}",
                                  //   style: TextStyle(
                                  //     fontSize: 16.sp,
                                  //     fontFamily: FontFamily.bold,
                                  //     color: AppColors.mainColor,
                                  //   ),
                                  // ),
                                  Text(
    "${customer.currencySymbol} ${p.totalAmount != null ? double.parse(p.totalAmount!).toStringAsFixed(2) : '0.00'}",

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
                        Padding(
                          padding: EdgeInsets.only(top: 20),
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
                  ]
                ],
              ),
            ),
          )

        ],
      ).paddingSymmetric(horizontal: 2.w),
    );
  }

  Future<void> _fetchCustomerReport() async {
    setState(() {
      isLoading=true;
    });
    var box = HiveService().getCustomerReportBox();

    if (!await checkInternet()) {
      _loadCachedCustomerReport();
      return;
    }

    try {
      final response = await CustomerProvider().fetchCustomerReport(
        customerId: selectedCustomerId ?? 0,
        fromDate:DateFormat('yyyy-MM-dd').format(fromDate),
        toDate: DateFormat('yyyy-MM-dd').format(toDate),
        groupBy: selectedFilter=="Monthly"?"monthly":selectedFilter=="Yearly"?"yearly":"quarterly",
      );

      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List) {
          customerReportList =
              decoded
                  .map<CustomerReportModal>(
                    (e) => CustomerReportModal.fromJson(e),
                  )
                  .toList();
          setState(() {
            isLoading=false;
          });
        } else if (decoded is Map<String, dynamic>) {
          customerReportList = [CustomerReportModal.fromJson(decoded)];
          setState(() {
            isLoading=false;
          });
        }

        await box.put('customer_report', response.body);
      } else {
        _loadCachedCustomerReport();
        setState(() {
          isLoading=false;
        });
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (e, stackTrace) {
      print("Error Fetching Customer Report: $e");
      print("StackTrace: $stackTrace");
      setState(() {
        isLoading=false;
      });
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
      setState(() {
        isLoading=false;
      });
      log("Error loading customers: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<CustomerReportModal> customerReportList = [];
  List<CustomerReportModal> filteredCustomerReportList = [];

  void _loadCachedCustomerReport() {
    var reportBox = HiveService().getCustomerReportBox();

    final cachedReport = reportBox.get('customer_report');

    if (cachedReport != null) {
      final decoded = json.decode(cachedReport);

      if (decoded is List) {
        customerReportList =
            decoded
                .map<CustomerReportModal>(
                  (e) => CustomerReportModal.fromJson(e),
                )
                .toList();
      } else if (decoded is Map<String, dynamic>) {
        customerReportList = [CustomerReportModal.fromJson(decoded)];
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
          _fetchCustomerReport();
          print("selectedFilter====>>>>${selectedFilter}");
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
          border: Border.all(color: AppColors.mainColor),
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
