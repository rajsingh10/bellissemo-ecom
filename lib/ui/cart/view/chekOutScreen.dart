import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/ui/cart/modal/viewCartDataModal.dart';
import 'package:bellissemo_ecom/ui/cart/service/cartServices.dart';
import 'package:bellissemo_ecom/utils/customButton.dart';
import 'package:bellissemo_ecom/utils/customMenuDrawer.dart';
import 'package:bellissemo_ecom/utils/snackBars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../ApiCalling/apiConfigs.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/colors.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/titlebarWidget.dart';
import '../../customers/view/customerAddressScreen.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {

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
    return Scaffold(
      backgroundColor: AppColors.containerColor,
      body: Column(
        children: [
          TitleBar(
            title: 'Checkout',
            isDrawerEnabled: false,
            isBackEnabled: true,
          ),
          SizedBox(height: 1.h),
          Expanded(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_shipping_rounded,
                                color: AppColors.mainColor,
                                size: 21.sp,
                              ),
                              Text(
                                "Shipping Details",
                                style: TextStyle(
                                  color: AppColors.mainColor,
                                  fontSize: 20.sp,
                                  fontFamily: FontFamily.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),

                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 20.sp,
                                color: AppColors.mainColor,
                              ),
                              Text(
                                "Customer Name",
                                style: TextStyle(
                                  color: AppColors.mainColor,
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            customerName.toString(),
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16.sp,
                              fontFamily: FontFamily.semiBold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 20.sp,
                                    color: AppColors.mainColor,
                                  ),
                                  Text(
                                    "Address",
                                    style: TextStyle(
                                      color: AppColors.mainColor,
                                      fontSize: 16.sp,
                                      fontFamily: FontFamily.semiBold,
                                    ),
                                  ),
                                ],
                              ),

                              InkWell(
                                onTap: (){
                                  Get.to(CustomerAddressScreen());
                                },
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: 20.sp,
                                  color: AppColors.mainColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "117, Albany Gardens,Colchester,Essex,United Kingdom",
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16.sp,
                              fontFamily: FontFamily.semiBold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          // Row(
                          //   children: [
                          //     Icon(Icons.location_on_outlined,size: 20.sp,color: AppColors.blackColor,),
                          //     Flexible(
                          //       child: Text("117, Albany Gardens,Colchester,Essex,United kingdom",
                          //         style: TextStyle(
                          //             color: AppColors.blackColor,fontSize: 16.sp,
                          //             fontFamily: FontFamily.semiBold
                          //
                          //         ),
                          //       ),
                          //     ),
                          //     Icon(Icons.edit_rounded,size: 20.sp,color: AppColors.mainColor,),
                          //   ],
                          // )
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
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_rounded,
                                color: AppColors.mainColor,
                                size: 21.sp,
                              ),
                              Text(
                                "Order",
                                style: TextStyle(
                                  color: AppColors.mainColor,
                                  fontSize: 20.sp,
                                  fontFamily: FontFamily.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),

                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.whiteColor,
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 1.h),
                                viewCartData?.items?.length == 0 ||
                                    viewCartData?.items?.length ==
                                        null ||
                                    viewCartData?.items?.length == []
                                    ? Text(
                                  "No Cart Available",
                                  style: TextStyle(
                                    fontFamily: FontFamily.bold,
                                    fontSize: 15.sp,
                                    color: AppColors.blackColor,
                                  ),
                                )
                                    : Column(
                                  children: [
                                    for (
                                    int i = 0;
                                    i <
                                        (viewCartData
                                            ?.items
                                            ?.length ??
                                            0);
                                    i++
                                    )
                                      Column(
                                        children: [
                                          Container(
                                            // margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                                            padding: EdgeInsets.all(
                                              2.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                              AppColors
                                                  .whiteColor,
                                              borderRadius:
                                              BorderRadius.circular(
                                                15,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                  Colors
                                                      .grey
                                                      .shade300,
                                                  blurRadius: 10,
                                                  offset: Offset(
                                                    0,
                                                    5,
                                                  ),
                                                ),
                                              ],
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
                                                          FontFamily
                                                              .bold,
                                                          fontSize:
                                                          15.sp,
                                                          color:
                                                          AppColors
                                                              .blackColor,
                                                        ),
                                                        maxLines: 2,
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(
                                                        height: 0.5.h,
                                                      ),

                                                      Text(
                                                        "Qty:  ${viewCartData
                                                            ?.items?[i]
                                                            .quantity ??
                                                            ""}",
                                                        style: TextStyle(
                                                          fontFamily:
                                                          FontFamily
                                                              .light,
                                                          fontSize:
                                                          15.sp,
                                                          color:
                                                          AppColors
                                                              .blackColor,
                                                        ),
                                                        maxLines: 2,
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Price + Delete
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .end,
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
                                                        padding: EdgeInsets.all(
                                                          isIpad
                                                              ? 1.w
                                                              : 1.5.w,
                                                        ),
                                                        decoration: BoxDecoration(
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
                                                    SizedBox(
                                                      height: 2.h,
                                                    ),
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
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                color: AppColors.mainColor,
                                size: 21.sp,
                              ),
                              Text(
                                "Order Summary",
                                style: TextStyle(
                                  color: AppColors.mainColor,
                                  fontSize: 20.sp,
                                  fontFamily: FontFamily.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),

                          // SizedBox(height: 1.h),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Sub Total",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                              Text(
                                "${viewCartData?.totals?.currencySymbol} ${viewCartData?.totals?.totalItems}",
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
                                "Total Tax",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                              Text(
                                "${viewCartData?.totals?.currencySymbol} ${viewCartData?.totals?.totalTax}",
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
                                " ${viewCartData?.totals?.currencySymbol} ${viewCartData?.totals?.totalShipping ?? "0.0"}",
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
                                "${viewCartData?.totals?.currencySymbol} ${ viewCartData?.totals?.totalDiscount ??
                                    ""}",

                                // "\$ ${tax.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: AppColors.gray,
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
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
                                "${viewCartData?.totals?.currencySymbol} ${viewCartData?.totals?.totalPrice ??
                                    ""}" ,
                                // "\$ ${(subtotal + shipping + tax).toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 17.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
      bottomNavigationBar: CustomButton(
        title: "Submit Order",
        route: () {},
        color: AppColors.mainColor,
        fontcolor: AppColors.whiteColor,
        height: 7.h,
        fontsize: 18.sp,
        radius: isIpad ? 1.w : 3.w,
        iconData: Icons.shopping_cart_checkout_sharp,
        iconsize: 18.sp,
      ).paddingSymmetric(horizontal: 3.w, vertical: 1.5.h),
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


