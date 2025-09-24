import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/ui/cart/View/chekOutScreen.dart';
import 'package:bellissemo_ecom/ui/cart/modal/viewCartDataModal.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../apiCalling/apiConfigs.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/colors.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/customButton.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/titlebarWidget.dart';
import '../service/cartServices.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();

  List<bool> selectedItems = List.generate(5, (_) => false);
  bool selectAll = false;
  bool isIpad = 100.w >= 800;

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
      await Future.wait([_fetchCart().then((_) => setState(() {}))]);
    } catch (e) {
      log("Error loading initial data: $e");
    } finally {
      stopwatch.stop();
      log("All API calls completed in ${stopwatch.elapsed.inMilliseconds} ms");
      setState(() => isLoading = false);
    }
  }

  void _loadCachedData() {
    var viewCartbox = HiveService().getViewCartBox();

    final cachedCart = viewCartbox.get('cart_$customerId');
    if (cachedCart != null) {
      viewCartData = ViewCartDataModal.fromJson(json.decode(cachedCart));
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

  @override
  Widget build(BuildContext context) {
    // double subtotal = 0;
    // for (var item in cartItems) {
    //   subtotal += item["price"] * item["qty"];
    // }
    // double shipping = 5.0;
    // double tax = subtotal * 0.1;
    return Scaffold(
      backgroundColor: AppColors.containerColor,
      body:
          isLoading
              ? Loader()
              : Column(
                children: [
                  TitleBar(
                    title: 'Cart',
                    isDrawerEnabled: true,
                    isSearchEnabled: false,
                    onSearch: () {
                      setState(() {
                        isSearchEnabled = !isSearchEnabled;
                      });
                    },
                  ),
                  // isSearchEnabled
                  //     ? SearchField(controller: searchController)
                  //     : SizedBox.shrink(),
                  SizedBox(height: 1.h),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.whiteColor,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 1.h),
                                  Column(
                                    children: [
                                      for (
                                        int i = 0;
                                        i < (viewCartData?.items?.length ?? 0);
                                        i++
                                      )
                                        Column(
                                          children: [
                                            Container(
                                              // margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                                              padding: EdgeInsets.all(2.w),
                                              decoration: BoxDecoration(
                                                color: AppColors.whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade300,
                                                    blurRadius: 10,
                                                    offset: Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Product Image
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    child: CustomNetworkImage(
                                                      imageUrl:
                                                          viewCartData
                                                              ?.items?[i]
                                                              .images?[0]
                                                              .src ??
                                                          '',
                                                      height: 80,
                                                      width: 80,
                                                      radius: 12,
                                                      isCircle: false,
                                                      isFit: true,
                                                    ),
                                                  ),
                                                  SizedBox(width: 3.w),

                                                  // Product Details
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          viewCartData
                                                                  ?.items?[i]
                                                                  .name ??
                                                              "",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                FontFamily.bold,
                                                            fontSize: 15.sp,
                                                            color:
                                                                AppColors
                                                                    .blackColor,
                                                          ),
                                                          maxLines: 2,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        SizedBox(height: 0.5.h),

                                                        IntrinsicWidth(
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      isIpad
                                                                          ? 0
                                                                          : 2.w,
                                                                  vertical:
                                                                      0.5.h,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  AppColors
                                                                      .containerColor,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    30,
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                // Decrease
                                                                GestureDetector(
                                                                  onTap: () {},
                                                                  child: Container(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                          1.5.w,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          AppColors
                                                                              .cardBgColor,
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .remove,
                                                                      size:
                                                                          isIpad
                                                                              ? 12.sp
                                                                              : 16.sp,
                                                                      color:
                                                                          AppColors
                                                                              .blackColor,
                                                                    ),
                                                                  ),
                                                                ),

                                                                SizedBox(
                                                                  width: 1.w,
                                                                ),

                                                                // Quantity text
                                                                Text(
                                                                  "1",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        14.sp,
                                                                    fontFamily:
                                                                        FontFamily
                                                                            .semiBold,
                                                                    color:
                                                                        AppColors
                                                                            .blackColor,
                                                                  ),
                                                                ),

                                                                SizedBox(
                                                                  width: 1.w,
                                                                ),

                                                                // Increase
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setState(() {
                                                                      // cartItems[i]["qty"]++;
                                                                    });
                                                                  },
                                                                  child: Container(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                          1.5.w,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          AppColors
                                                                              .cardBgColor,
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
                                                                    ),
                                                                    child: Icon(
                                                                      Icons.add,
                                                                      size:
                                                                          isIpad
                                                                              ? 12.sp
                                                                              : 16.sp,
                                                                      color:
                                                                          AppColors
                                                                              .blackColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Price + Delete
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            // cartItems.removeAt(i);
                                                          });
                                                        },
                                                        child: Container(
                                                          height:
                                                              isIpad
                                                                  ? 24.sp
                                                                  : 0.sp,
                                                          padding:
                                                              EdgeInsets.all(
                                                                isIpad
                                                                    ? 1.w
                                                                    : 1.5.w,
                                                              ),
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    AppColors
                                                                        .mainColor,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                          child: Icon(
                                                            Icons
                                                                .delete_outline_rounded,
                                                            color:
                                                                AppColors
                                                                    .whiteColor,
                                                            size:
                                                                isIpad
                                                                    ? 16.sp
                                                                    : 0,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 2.h),
                                                      // Text(
                                                      //   "\$ ${  viewCartData?.items?[i].prices?.price ?? ""}",
                                                      //   style: TextStyle(
                                                      //     color: AppColors.blackColor,
                                                      //     fontSize: 14.sp,
                                                      //     fontFamily:
                                                      //         FontFamily.semiBold,
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.whiteColor,
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.receipt_long_rounded,
                                      color: AppColors.mainColor,
                                      size: isIpad ? 18.sp : 16.sp,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      "Summary Order",
                                      style: TextStyle(
                                        color: AppColors.mainColor,
                                        fontSize: 18.sp,
                                        fontFamily: FontFamily.semiBold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.5.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: "Enter Discount Code",
                                          hintStyle: TextStyle(
                                            fontSize: 16.sp,
                                            fontFamily: FontFamily.semiBold,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 12,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: AppColors.containerColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Apply discount code logic here
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.mainColor,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Apply",
                                        style: TextStyle(
                                          color: AppColors.whiteColor,
                                          fontSize: 16.sp,
                                          fontFamily: FontFamily.semiBold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total Tax",
                                      style: TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 16.sp,
                                        fontFamily: FontFamily.semiBold,
                                      ),
                                    ),
                                    Text(
                                      "\$ ${viewCartData?.totals?.totalTax}",
                                      style: TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 16.sp,
                                        fontFamily: FontFamily.semiBold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Shipping",
                                      style: TextStyle(
                                        color: AppColors.gray,
                                        fontSize: 16.sp,
                                        fontFamily: FontFamily.semiBold,
                                      ),
                                    ),
                                    Text(
                                      "\$ ${viewCartData?.totals?.totalShipping ?? "0.0"}",
                                      style: TextStyle(
                                        color: AppColors.gray,
                                        fontSize: 16.sp,
                                        fontFamily: FontFamily.semiBold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Discount Tax",
                                      style: TextStyle(
                                        color: AppColors.gray,
                                        fontSize: 16.sp,
                                        fontFamily: FontFamily.semiBold,
                                      ),
                                    ),
                                    Text(
                                      viewCartData?.totals?.totalDiscount ?? "",
                                      // "\$ ${tax.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: AppColors.gray,
                                        fontSize: 16.sp,
                                        fontFamily: FontFamily.semiBold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total",
                                      style: TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 17.sp,
                                        fontFamily: FontFamily.semiBold,
                                      ),
                                    ),
                                    Text(
                                      viewCartData?.totals?.totalPrice ?? "",
                                      // "\$ ${(subtotal + shipping + tax).toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 17.sp,
                                        fontFamily: FontFamily.semiBold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Estimated Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Estimated Total",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 17.5.sp,
                        fontFamily: FontFamily.semiBold,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "",
                      // "\$ ${(subtotal + shipping + tax).toStringAsFixed(2)}",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 18.sp,
                        fontFamily: FontFamily.semiBold,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 2.w),
                // Checkout Button
                Expanded(
                  child: CustomButton(
                    title: 'Checkout',
                    route: () {
                      Get.to(
                        () => CheckOutScreen(),
                        transition: Transition.fade,
                        duration: const Duration(milliseconds: 450),
                      );
                    },
                    color: AppColors.mainColor,
                    fontcolor: AppColors.whiteColor,
                    height: 5.h,
                    fontsize: 18.sp,
                    iconsize: 18.sp,
                    iconData: Icons.shopping_cart_checkout_outlined,
                    radius: isIpad ? 1.w : 3.w,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isIpad ? 14.h : 10.h, child: CustomBar(selected: 4)),
        ],
      ),
    );
  }

  Future<void> _fetchCart() async {
    var box = HiveService().getViewCartBox();

    if (!await checkInternet()) {
      final cachedData = box.get('cart_$customerId');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        viewCartData = ViewCartDataModal.fromJson(data);
      } else {
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
      }
      return;
    }

    try {
      final response = await CartService().fetchCart(customerId);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        viewCartData = ViewCartDataModal.fromJson(data);
        await box.put("cart_$customerId", response.body);
      } else {
        final cachedData = box.get('cart_$customerId');
        if (cachedData != null) {
          final data = json.decode(cachedData);
          viewCartData = ViewCartDataModal.fromJson(data);
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      final cachedData = box.get('cart_$customerId');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        viewCartData = ViewCartDataModal.fromJson(data);
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }
}
