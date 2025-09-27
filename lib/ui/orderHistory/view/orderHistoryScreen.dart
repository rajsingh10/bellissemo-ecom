import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/ui/orderHistory/provider/orderHistoryProvider.dart';
import 'package:bellissemo_ecom/utils/customMenuDrawer.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  String selectedSort = "Newest First";
  bool isIpad = 100.w >= 800;

  final List<String> sortOptions = ["Newest First", "Oldest First"];

  void sortOrders(String option) {
    setState(() {
      selectedSort = option;
      if (option == "Newest First") {
        ordersList.sort((a, b) => b.dateCreated!.compareTo(a.dateCreated!));
      } else if (option == "Oldest First") {
        ordersList.sort((a, b) => a.dateCreated!.compareTo(b.dateCreated!));
      }
    });
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
                        padding: EdgeInsets.symmetric(vertical: 15.h),
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
                                          Text(
                                            "Order No #${order.id}",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: FontFamily.bold,
                                              color: AppColors.blackColor,
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.greenColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  order
                                                          .status
                                                          ?.capitalizeFirst ??
                                                      '',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: FontFamily.bold,
                                                    color: AppColors.greenColor,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                order.dateCreated ?? "",
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: AppColors.gray,
                                                  fontFamily: FontFamily.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(width: 3.w),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            "Customer : ", // label
                                                        style: TextStyle(
                                                          fontSize: 16.sp,
                                                          color:
                                                              AppColors
                                                                  .blackColor,
                                                          fontFamily:
                                                              FontFamily
                                                                  .bold, // bold for label
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            customerName ?? "",
                                                        // dynamic name
                                                        style: TextStyle(
                                                          fontSize: 16.sp,
                                                          color:
                                                              AppColors
                                                                  .blackColor,
                                                          fontFamily:
                                                              FontFamily
                                                                  .regular, // normal for value
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            for (var item in order.lineItems!)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 12,
                                                    ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Product Image
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: CustomNetworkImage(
                                                        imageUrl:
                                                            item.image?.src ??
                                                            "",
                                                        height: 100,
                                                        width: 100,
                                                        isCircle: true,
                                                        isFit: true,
                                                        isProfile: false,
                                                      ),
                                                    ),
                                                    SizedBox(width: 2.w),

                                                    // Product Details + Quantity & Cart Button
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Product Name
                                                          Text(
                                                            item.name ?? "",
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .semiBold,
                                                              color:
                                                                  AppColors
                                                                      .blackColor,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 0.5.h,
                                                          ),

                                                          // Qty + Price
                                                          Text(
                                                            "Qty: ${item.quantity}  •  \$${item.price ?? ""}",
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              color:
                                                                  AppColors
                                                                      .gray,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .semiBold,
                                                            ),
                                                          ),
                                                          // SizedBox(height: 1.h),
                                                          // IntrinsicWidth(
                                                          //   child: Container(
                                                          //     padding:
                                                          //         EdgeInsets.symmetric(
                                                          //           horizontal:
                                                          //               isIpad
                                                          //                   ? 0
                                                          //                   : 2.w,
                                                          //           vertical:
                                                          //               0.5.h,
                                                          //         ),
                                                          //     decoration: BoxDecoration(
                                                          //       color:
                                                          //           AppColors
                                                          //               .containerColor,
                                                          //       borderRadius:
                                                          //           BorderRadius.circular(
                                                          //             30,
                                                          //           ),
                                                          //     ),
                                                          //     child: Row(
                                                          //       children: [
                                                          //         // Decrease
                                                          //         GestureDetector(
                                                          //           onTap:
                                                          //               () {},
                                                          //           child: Container(
                                                          //             padding:
                                                          //                 EdgeInsets.all(
                                                          //                   1.5.w,
                                                          //                 ),
                                                          //             decoration: BoxDecoration(
                                                          //               color:
                                                          //                   AppColors.cardBgColor,
                                                          //               shape:
                                                          //                   BoxShape.circle,
                                                          //             ),
                                                          //             child: Icon(
                                                          //               Icons
                                                          //                   .remove,
                                                          //               size:
                                                          //                   isIpad
                                                          //                       ? 12.sp
                                                          //                       : 16.sp,
                                                          //               color:
                                                          //                   AppColors.blackColor,
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //
                                                          //         SizedBox(
                                                          //           width: 4.w,
                                                          //         ),
                                                          //
                                                          //         // Increase
                                                          //         GestureDetector(
                                                          //           onTap: () {
                                                          //             setState(
                                                          //               () {},
                                                          //             );
                                                          //           },
                                                          //           child: Container(
                                                          //             padding:
                                                          //                 EdgeInsets.all(
                                                          //                   1.5.w,
                                                          //                 ),
                                                          //             decoration: BoxDecoration(
                                                          //               color:
                                                          //                   AppColors.cardBgColor,
                                                          //               shape:
                                                          //                   BoxShape.circle,
                                                          //             ),
                                                          //             child: Icon(
                                                          //               Icons
                                                          //                   .add,
                                                          //               size:
                                                          //                   isIpad
                                                          //                       ? 12.sp
                                                          //                       : 16.sp,
                                                          //               color:
                                                          //                   AppColors.blackColor,
                                                          //             ),
                                                          //           ),
                                                          //         ),
                                                          //       ],
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                          // Quantity Selector + Cart Button
                                                          // Row(
                                                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          //   children: [
                                                          //     // Quantity Selector
                                                          //     Container(
                                                          //       padding: EdgeInsets.symmetric(
                                                          //         horizontal: isIpad ? 0 : 2.w,
                                                          //         vertical: 0.5.h,
                                                          //       ),
                                                          //       decoration: BoxDecoration(
                                                          //         color: AppColors.containerColor,
                                                          //         borderRadius: BorderRadius.circular(30),
                                                          //       ),
                                                          //       child: Row(
                                                          //         children: [
                                                          //           // Decrease Button
                                                          //           GestureDetector(
                                                          //             onTap: product.inStock && product.quantity > 0
                                                          //                 ? () => setState(() => product.quantity--)
                                                          //                 : null,
                                                          //             child: Container(
                                                          //               padding: EdgeInsets.all(1.5.w),
                                                          //               decoration: BoxDecoration(
                                                          //                 color: AppColors.cardBgColor,
                                                          //                 shape: BoxShape.circle,
                                                          //               ),
                                                          //               child: Icon(
                                                          //                 Icons.remove,
                                                          //                 size: isIpad ? 12.sp : 16.sp,
                                                          //                 color: AppColors.blackColor,
                                                          //               ),
                                                          //             ),
                                                          //           ),
                                                          //           SizedBox(width: 1.w),
                                                          //
                                                          //           // Quantity Text
                                                          //           Text(
                                                          //             product.quantity.toString(),
                                                          //             style: TextStyle(
                                                          //               fontSize: 14.sp,
                                                          //               fontFamily: FontFamily.semiBold,
                                                          //               color: AppColors.blackColor,
                                                          //             ),
                                                          //           ),
                                                          //           SizedBox(width: 1.w),
                                                          //
                                                          //           // Increase Button
                                                          //           GestureDetector(
                                                          //             onTap: product.inStock
                                                          //                 ? () => setState(() => product.quantity++)
                                                          //                 : null,
                                                          //             child: Container(
                                                          //               padding: EdgeInsets.all(1.5.w),
                                                          //               decoration: BoxDecoration(
                                                          //                 color: AppColors.cardBgColor,
                                                          //                 shape: BoxShape.circle,
                                                          //               ),
                                                          //               child: Icon(
                                                          //                 Icons.add,
                                                          //                 size: isIpad ? 12.sp : 16.sp,
                                                          //                 color: AppColors.blackColor,
                                                          //               ),
                                                          //             ),
                                                          //           ),
                                                          //         ],
                                                          //       ),
                                                          //     ),
                                                          //
                                                          //     // Add to Cart Button
                                                          //     InkWell(
                                                          //       onTap: product.inStock
                                                          //           ? () {
                                                          //         // handle add to cart
                                                          //       }
                                                          //           : null,
                                                          //       borderRadius: BorderRadius.circular(30),
                                                          //       child: Container(
                                                          //         padding: EdgeInsets.all(1.5.w),
                                                          //         decoration: BoxDecoration(
                                                          //           color: AppColors.mainColor,
                                                          //           shape: BoxShape.circle,
                                                          //         ),
                                                          //         child: Icon(
                                                          //           Icons.shopping_cart_outlined,
                                                          //           color: Colors.white,
                                                          //           size: isIpad ? 15.sp : 18.sp,
                                                          //         ),
                                                          //       ),
                                                          //     ),
                                                          //   ],
                                                          // ),
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
                                                  Text(
                                                    "Total Tax:",
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontFamily.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "\$${order.totalTax ?? ""}",
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
                                                    "Shipping Total:",
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontFamily.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "\$${order.shippingTotal ?? ""}",
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
                                                    "Discount Total:",
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontFamily.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "\$${order.discountTotal ?? ""}",
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
                                                    "\$${order.total ?? ""}",
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

  Future<void> _fetchOrders() async {
    var box = HiveService().getOrdersBox();

    if (!await checkInternet()) {
      final cachedData = box.get('orders_$customerId');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        ordersList =
            data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();
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
        ordersList =
            data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();

        // Save banner to Hive
        await box.put('orders_$customerId', response.body);
      } else {
        // Fallback: load cache if server fails
        final cachedData = box.get('orders_$customerId');
        if (cachedData != null) {
          final List data = json.decode(cachedData);
          ordersList =
              data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();
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
        ordersList =
            data.map((e) => CustomerOrderWiseModal.fromJson(e)).toList();
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }
}
