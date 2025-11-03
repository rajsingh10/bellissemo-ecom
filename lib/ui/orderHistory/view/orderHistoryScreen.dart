import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/ui/orderHistory/provider/orderHistoryProvider.dart';
import 'package:bellissemo_ecom/utils/customMenuDrawer.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/colors.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/emptyWidget.dart';
import '../../../utils/searchFields.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/titlebarWidget.dart';
import '../modal/customerOrderWiseModal.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();

  String selectedSort = "All";
  bool isIpad = 100.w >= 800;

  final List<String> sortOptions = [
    "All",
    "Newest First",
    "Oldest First",
    "Yesterday",
    "Today",
    "This Week",
    "This Month",
  ];

  DateTime parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime(1900);
    return DateTime.tryParse(dateStr) ?? DateTime(1900);
  }

  List<CustomerOrderWiseModal> _allOrdersList = [];

  void sortOrders(String option) {
    setState(() {
      selectedSort = option;
      final now = DateTime.now();

      // Reset to all orders first before applying filters
      ordersList = List.from(_allOrdersList);

      if (option == "All") {
        ordersList.sort(
          (a, b) =>
              parseDate(b.dateCreated).compareTo(parseDate(a.dateCreated)),
        );
      } else if (option == "Newest First") {
        ordersList.sort(
          (a, b) =>
              parseDate(b.dateCreated).compareTo(parseDate(a.dateCreated)),
        );
      } else if (option == "Oldest First") {
        ordersList.sort(
          (a, b) =>
              parseDate(a.dateCreated).compareTo(parseDate(b.dateCreated)),
        );
      } else if (option == "Yesterday") {
        final yesterday = now.subtract(const Duration(days: 1));
        ordersList =
            ordersList.where((order) {
              final date = parseDate(order.dateCreated);
              return date.year == yesterday.year &&
                  date.month == yesterday.month &&
                  date.day == yesterday.day;
            }).toList();
      } else if (option == "Today") {
        ordersList =
            ordersList.where((order) {
              final date = parseDate(order.dateCreated);
              return date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
            }).toList();
      } else if (option == "This Week") {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        ordersList =
            ordersList.where((order) {
              final date = parseDate(order.dateCreated);
              return date.isAfter(
                    startOfWeek.subtract(const Duration(seconds: 1)),
                  ) &&
                  date.isBefore(endOfWeek.add(const Duration(days: 1)));
            }).toList();
      } else if (option == "This Month") {
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        ordersList =
            ordersList.where((order) {
              final date = parseDate(order.dateCreated);
              return date.isAfter(
                    startOfMonth.subtract(const Duration(seconds: 1)),
                  ) &&
                  date.isBefore(endOfMonth.add(const Duration(days: 1)));
            }).toList();
      }
    });
  }

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "";

    try {
      final dateTime = DateTime.parse(rawDate); // parse ISO8601 string
      return DateFormat("dd MMM yyyy").format(dateTime);
    } catch (e) {
      return rawDate; // fallback if parsing fails
    }
  }

  List<CustomerOrderWiseModal> ordersList = [];
  String? customerName;
  int? customerId;

  Future<void> _loadCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customerId = prefs.getInt("customerId");
      customerName = prefs.getString("customerName");
    });
  }

  bool isLoading = true;

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);
    _loadCachedData();
    final stopwatch = Stopwatch()..start();
    try {
      await Future.wait([_fetchOrders().then((_) => setState(() {}))]);
    } catch (e) {
      log("Error loading initial data: $e");
    } finally {
      stopwatch.stop();
      log("All API calls completed in ${stopwatch.elapsed.inMilliseconds} ms");
      setState(() => isLoading = false);
    }
  }

  void _loadCachedData() {
    var ordersBox = HiveService().getOrdersBox();

    final cachedOrders = ordersBox.get('orders_$customerId');
    if (cachedOrders != null) {
      final List data = json.decode(cachedOrders);
      ordersList = data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCustomer();
    loadInitialData();
  }

  final GlobalKey<ScaffoldState> _scaffoldKeyOrder = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      key: _scaffoldKeyOrder,
      drawer: CustomDrawer(),
      body:
          isLoading
              ? Loader()
              : Column(
                children: [
                  TitleBar(
                    title: 'Order History',
                    isDrawerEnabled: true,
                    isSearchEnabled: true,
                    drawerCallback: () {
                      _scaffoldKeyOrder.currentState?.openDrawer();
                    },
                    onSearch: () {
                      setState(() {
                        isSearchEnabled = !isSearchEnabled;
                      });
                    },
                  ),
                  if (isSearchEnabled)
                    SearchField(controller: searchController),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Showing", // Show total items dynamically
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontFamily: FontFamily.semiBold,
                                color: AppColors.blackColor,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(
                              Icons.shopping_bag,
                              color: AppColors.mainColor,
                              size: 20.sp,
                            ),

                            Text(
                              "${ordersList.length} Items",
                              // Show total items dynamically
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontFamily: FontFamily.semiBold,
                                color: AppColors.mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Sort By ",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontFamily: FontFamily.semiBold,
                                color: AppColors.blackColor,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            DropdownButtonHideUnderline(
                              // <-- Wrap to remove underline
                              child: DropdownButton<String>(
                                value: selectedSort,
                                icon: Icon(
                                  Icons.sort,
                                  color: AppColors.mainColor,
                                ),
                                items:
                                    sortOptions
                                        .map(
                                          (option) => DropdownMenuItem(
                                            value: option,
                                            child: Text(
                                              option,
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontFamily: FontFamily.semiBold,
                                                color: AppColors.mainColor,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  if (value != null) sortOrders(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.h),
                  ordersList.isEmpty || ordersList.isEmpty
                      ? Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isIpad ? 2.h : 15.h,
                        ),
                        child: emptyWidget(
                          icon: Icons.shopping_cart_outlined,
                          text: 'Order History',
                        ),
                      )
                      : Expanded(
                        child: SingleChildScrollView(
                          physics: ClampingScrollPhysics(),
                          child: Column(
                            children: [
                              for (var order in ordersList)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    elevation: 2,
                                    shadowColor: AppColors.containerColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    color: AppColors.whiteColor,
                                    child: ExpansionTile(
                                      tilePadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: AppColors.whiteColor,
                                      // collapsedBackgroundColor: AppColors.whiteColor,
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Order No #${order.id}",
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: FontFamily.bold,
                                                  color: AppColors.blackColor,
                                                ),
                                              ),
                                              Text(
                                                formatDate(order.dateCreated),
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: AppColors.gray,
                                                  fontFamily: FontFamily.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                customerName ?? "",
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: AppColors.blackColor,
                                                  fontFamily: FontFamily.bold,
                                                ),
                                              ),
                                              Text(
                                                "${order.currencySymbol} ${order.total}",
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: FontFamily.bold,
                                                  color: AppColors.greenColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      children: [
                                        Column(
                                          children: [
                                            Builder(
                                              builder: (context) {
                                                double subtotal = 0.0;
                                                for (var item
                                                    in order.lineItems ?? []) {
                                                  // Convert subtotal to double safely
                                                  final double price =
                                                      double.tryParse(
                                                        item.price
                                                                ?.toString() ??
                                                            "0",
                                                      ) ??
                                                      0.0;

                                                  final int qty =
                                                      item.quantity ?? 0;

                                                  subtotal += price * qty;
                                                }

                                                return Column(
                                                  children: [
                                                    for (var item
                                                        in order.lineItems!)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 6,
                                                              horizontal: 12,
                                                            ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // Product Image
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              child: CustomNetworkImage(
                                                                imageUrl:
                                                                    item
                                                                        .image
                                                                        ?.src ??
                                                                    "",
                                                                height: 100,
                                                                width: 100,
                                                                isCircle: true,
                                                                isFit: true,
                                                                isProfile:
                                                                    false,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 2.w,
                                                            ),

                                                            // Product Details + Quantity & Cart Button
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  // Product Name
                                                                  Text(
                                                                    item.name ??
                                                                        "",
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          16.sp,
                                                                      fontFamily:
                                                                          FontFamily
                                                                              .semiBold,
                                                                      color:
                                                                          AppColors
                                                                              .blackColor,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        0.5.h,
                                                                  ),

                                                                  // Qty + Price
                                                                  Text(
                                                                    "Qty: ${item.quantity}  •  ${order.currencySymbol} ${(item.subtotal ?? 0)}",
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          16.sp,
                                                                      color:
                                                                          AppColors
                                                                              .gray,
                                                                      fontFamily:
                                                                          FontFamily
                                                                              .semiBold,
                                                                    ),
                                                                  ),

                                                                  SizedBox(
                                                                    height: 1.h,
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () async {
                                                                      final response = await OrderHistoryProvider.reOrder(
                                                                        orderId:
                                                                            order.id,
                                                                        itemId:
                                                                            item.id,
                                                                      );

                                                                      if (response !=
                                                                              null &&
                                                                          (response.statusCode ==
                                                                                  200 ||
                                                                              response.statusCode ==
                                                                                  201)) {
                                                                        // ✅ Online success
                                                                        // showCustomSuccessSnackbar(
                                                                        //   title:
                                                                        //       "Reorder",
                                                                        //   message:
                                                                        //       "Reorder has been successfully added to your cart.",
                                                                        // );
                                                                      } else {
                                                                        // ⚠️ Offline queued (or failed but saved offline)
                                                                        // showCustomSuccessSnackbar(
                                                                        //   title:
                                                                        //       "Reorder",
                                                                        //   message:
                                                                        //       "Reorder has been successfully added to your cart.",
                                                                        // );
                                                                      }
                                                                    },
                                                                    child: Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            2.w,
                                                                        vertical:
                                                                            1.h,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                        color:
                                                                            AppColors.mainColor,
                                                                      ),
                                                                      child: Text(
                                                                        "Reorder",
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              14.sp,
                                                                          fontFamily:
                                                                              FontFamily.semiBold,
                                                                          color:
                                                                              AppColors.whiteColor,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    Divider(),

                                                    SizedBox(height: 0.5.h),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                          ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              "Delivery Note: ${order.orderNote}",
                                                              style: TextStyle(
                                                                fontSize: 16.sp,

                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    FontFamily
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 0.5.h),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                          ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Delivery Date:",
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            "${order.deliveryDate == "" || order.deliveryDate == "null" || order.deliveryDate == null ? "N/A" : order.deliveryDate}",
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .bold,
                                                              color:
                                                                  AppColors
                                                                      .blackColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    SizedBox(height: 0.5.h),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                          ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Sub Total:",
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            "${order.currencySymbol} ${subtotal.toStringAsFixed(2)}",
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .bold,
                                                              color:
                                                                  AppColors
                                                                      .blackColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Shipping :",
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontFamily.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    " + ${order.currencySymbol} ${order.shippingTotal ?? ""}",
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontFamily.bold,
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Discount :",
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontFamily.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "- ${order.currencySymbol} ${((double.tryParse(order.discountTotal?.toString() ?? "0") ?? 0)).toStringAsFixed(2)}",

                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontFamily.bold,
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Total:",
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontFamily.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${order.currencySymbol} ${((double.tryParse(order.total?.toString() ?? "0") ?? 0)).toStringAsFixed(2)}",

                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontFamily.bold,
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 1.5.h),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                ],
              ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
      bottomNavigationBar: SizedBox(
        height: isIpad ? 14.h : 10.h,
        child: CustomBar(selected: 2),
      ),
    );
  }

  // Future<void> _fetchOrders() async {
  //   var box = HiveService().getOrdersBox();
  //
  //   if (!await checkInternet()) {
  //     final cachedData = box.get('orders_$customerId');
  //     if (cachedData != null) {
  //       final List data = json.decode(cachedData);
  //       ordersList =
  //           data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();
  //     } else {
  //       showCustomErrorSnackbar(
  //         title: 'No Internet',
  //         message: 'Please check your connection and try again.',
  //       );
  //     }
  //     return;
  //   }
  //
  //   try {
  //     final response = await OrderHistoryProvider().fetchOrders(customerId);
  //     if (response.statusCode == 200) {
  //       final List data = json.decode(response.body);
  //       ordersList =
  //           data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();
  //
  //       // Save banner to Hive
  //       await box.put('orders_$customerId', response.body);
  //     } else {
  //       // Fallback: load cache if server fails
  //       final cachedData = box.get('orders_$customerId');
  //       if (cachedData != null) {
  //         final List data = json.decode(cachedData);
  //         ordersList =
  //             data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();
  //       }
  //       showCustomErrorSnackbar(
  //         title: 'Server Error',
  //         message: 'Something went wrong. Please try again later.',
  //       );
  //     }
  //   } catch (_) {
  //     // Fallback: load cache on network error
  //     final cachedData = box.get('orders_$customerId');
  //     if (cachedData != null) {
  //       final List data = json.decode(cachedData);
  //       ordersList =
  //           data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();
  //     }
  //     showCustomErrorSnackbar(
  //       title: 'Network Error',
  //       message: 'Unable to connect. Please check your internet and try again.',
  //     );
  //   }
  // }
  Future<void> _fetchOrders() async {
    var box = HiveService().getOrdersBox();

    if (!await checkInternet()) {
      final cachedData = box.get('orders_$customerId');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        final fetchedOrders =
            data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();

        setState(() {
          _allOrdersList = fetchedOrders;
          ordersList = List.from(_allOrdersList);
          // Apply current sort option after fetching
          if (selectedSort.isNotEmpty && selectedSort != "All") {
            sortOrders(selectedSort);
          } else {
            // Default to newest first
            ordersList.sort(
              (a, b) =>
                  parseDate(b.dateCreated).compareTo(parseDate(a.dateCreated)),
            );
          }
        });
      } else {
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
      }
      return;
    }

    try {
      final response = await OrderHistoryProvider().fetchOrders(customerId);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final fetchedOrders =
            data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();

        setState(() {
          _allOrdersList = fetchedOrders;
          ordersList = List.from(_allOrdersList);
          // Apply current sort option after fetching
          if (selectedSort.isNotEmpty && selectedSort != "All") {
            sortOrders(selectedSort);
          } else {
            // Default to newest first
            ordersList.sort(
              (a, b) =>
                  parseDate(b.dateCreated).compareTo(parseDate(a.dateCreated)),
            );
          }
        });

        // Save to Hive
        await box.put('orders_$customerId', response.body);
      } else {
        // Fallback: load cache if server fails
        final cachedData = box.get('orders_$customerId');
        if (cachedData != null) {
          final List data = json.decode(cachedData);
          final fetchedOrders =
              data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();

          setState(() {
            _allOrdersList = fetchedOrders;
            ordersList = List.from(_allOrdersList);
            if (selectedSort.isNotEmpty && selectedSort != "All") {
              sortOrders(selectedSort);
            }
          });
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      // Fallback: load cache on network error
      final cachedData = box.get('orders_$customerId');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        final fetchedOrders =
            data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();

        setState(() {
          _allOrdersList = fetchedOrders;
          ordersList = List.from(_allOrdersList);
          if (selectedSort.isNotEmpty && selectedSort != "All") {
            sortOrders(selectedSort);
          }
        });
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }

  // Add a refresh method
  Future<void> refreshOrders() async {
    setState(() {
      ordersList = List.from(_allOrdersList);
      selectedSort = "All";
      // Reset to default sort (newest first)
      ordersList.sort(
        (a, b) => parseDate(b.dateCreated).compareTo(parseDate(a.dateCreated)),
      );
    });
  }

  // Or if you want a simple reset method
  void resetOrders() {
    setState(() {
      ordersList = List.from(_allOrdersList);
      selectedSort = "All";
      ordersList.sort(
        (a, b) => parseDate(b.dateCreated).compareTo(parseDate(a.dateCreated)),
      );
    });
  }
}
