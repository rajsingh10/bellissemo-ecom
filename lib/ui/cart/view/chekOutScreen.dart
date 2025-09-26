import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/ui/cart/modal/viewCartDataModal.dart';
import 'package:bellissemo_ecom/ui/cart/service/cartServices.dart';
import 'package:bellissemo_ecom/ui/home/view/homeScreen.dart';
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
import '../../../utils/textFields.dart';
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
      body:
          isLoading
              ? Loader()
              : Column(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                        onTap: () {
                                          Get.to(
                                            CustomerAddressScreen(
                                              id: customerId.toString(),
                                              email:
                                                  viewCartData
                                                      ?.billingAddress
                                                      ?.email,
                                              fName:
                                                  viewCartData
                                                      ?.billingAddress
                                                      ?.firstName,
                                              lName:
                                                  viewCartData
                                                      ?.billingAddress
                                                      ?.lastName,
                                              address1:
                                                  viewCartData
                                                      ?.billingAddress
                                                      ?.address1,
                                              address2:
                                                  viewCartData
                                                      ?.billingAddress
                                                      ?.address2,
                                              city:
                                                  viewCartData
                                                      ?.billingAddress
                                                      ?.city,
                                              country:
                                                  viewCartData
                                                      ?.billingAddress
                                                      ?.country,
                                              postcode:
                                                  viewCartData
                                                      ?.billingAddress
                                                      ?.postcode,
                                              state:
                                                  viewCartData
                                                      ?.billingAddress
                                                      ?.state,
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          Icons.edit_rounded,
                                          size: 20.sp,
                                          color: AppColors.mainColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  viewCartData?.billingAddress?.address1 == ''
                                      ? Center(
                                        child: Text(
                                          "No Address Available",
                                          style: TextStyle(
                                            color: AppColors.blackColor,
                                            fontSize: 16.sp,
                                            fontFamily: FontFamily.semiBold,
                                          ),
                                        ),
                                      )
                                      : Text(
                                        "${viewCartData?.billingAddress?.firstName ?? ""} ${viewCartData?.billingAddress?.lastName ?? ""}\n${viewCartData?.billingAddress?.email ?? ""}\n${viewCartData?.billingAddress?.address1 ?? ""} ${viewCartData?.billingAddress?.address2 ?? ""} ${viewCartData?.billingAddress?.city ?? ""} ${viewCartData?.billingAddress?.state ?? ""} ${viewCartData?.billingAddress?.country ?? ""} ${viewCartData?.billingAddress?.postcode ?? ""}",
                                        style: TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 16.sp,
                                          fontFamily: FontFamily.semiBold,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                                viewCartData?.items?.length ==
                                                    []
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
                                                            SizedBox(
                                                              width: 3.w,
                                                            ),

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
                                                                    height:
                                                                        0.5.h,
                                                                  ),

                                                                  Text(
                                                                    "Qty:  ${viewCartData?.items?[i].quantity ?? ""}",
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
                                                                          : 1.5
                                                                              .w,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        "${viewCartData?.totals?.currencySymbol} ${viewCartData?.totals?.totalDiscount ?? ""}",

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
                                        "${viewCartData?.totals?.currencySymbol} ${viewCartData?.totals?.totalPrice ?? ""}",
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
        route: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String? errorText;
              DateTime? selectedDate;

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    backgroundColor: AppColors.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Text(
                      "Item Notes",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: FontFamily.bold,
                        color: AppColors.blackColor,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Notes Field
                        AppTextField(
                          controller: notesController,
                          hintText: "Enter Item notes here...",
                          text: "Notes",
                          isTextavailable: true,
                          textInputType: TextInputType.multiline,
                          maxline: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter Item notes";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Text(
                              "Delivery Date",
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 17.sp,
                                fontFamily: FontFamily.semiBold,
                              ),
                            ),
                          ],
                        ),

                        /// Date Picker Field
                        GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              // ⬅️ હવે આજથી પહેલાંની date disable થઈ જશે
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate == null
                                      ? "Select Delivery Date"
                                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color:
                                        selectedDate == null
                                            ? Colors.grey
                                            : AppColors.blackColor,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: AppColors.mainColor,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 1.h),

                        /// Total Amount Field
                        AppTextField(
                          controller: totalController,
                          hintText: "Enter Shipping Charge",
                          text: "Shipping Charge",
                          isTextavailable: true,
                          textInputType: TextInputType.number,
                          maxline: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter Shipping Charge";
                            }
                            return null;
                          },
                        ),

                        if (errorText != null) ...[
                          SizedBox(height: 1.h),
                          Text(
                            errorText!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      CustomButton(
                        title: "Cancel",
                        route: () {
                          Get.back();
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
                        route: () {
                          if (viewCartData?.billingAddress?.address1 == '') {
                            showCustomErrorSnackbar(
                              title: 'Address Required',
                              message: 'Please add an address to continue',
                            );
                          } else {
                            sumbitOrderapi(
                              "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            );
                          }
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
          );
        },
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

  bool isAddingToCart = false;

  Future<void> sumbitOrderapi(date) async {
    setState(() {
      isAddingToCart = true;
    });
    final cartService = CartService();
    final box = HiveService().getViewCartBox();
    List<Map<String, dynamic>> items =
        viewCartData?.items?.map((item) {
          return {
            "product_id": item.id,
            "quantity": item.quantity,
            "override_price": item.prices?.price ?? 0,
            "note": item.description ?? "",
          };
        }).toList() ??
        [];
    try {
      final response = await cartService.submitOrderApi(
        deliveryDate: date,
        note: notesController.text.trim(),
        shippingCharge: totalController.text.trim(),
        customerId: customerId,
        items: items,
        coupons: [],
      );

      if (response != null && response.statusCode == 200) {
        showCustomSuccessSnackbar(
          title: "Added to Cart",
          message: "This product has been successfully added to your cart.",
        );
        setState(() {
          isAddingToCart = false;
        });
        Get.to(Homescreen());
      } else {
        await box.delete("cart_$customerId");
        showCustomSuccessSnackbar(
          title: "Offline Mode",
          message: "Product added offline. It will sync once internet is back.",
        );
        setState(() {
          isAddingToCart = false;
        });
        Get.to(Homescreen());
      }
    } catch (e) {
      showCustomErrorSnackbar(
        title: "Error",
        message: "Something went wrong while adding product.\n$e",
      );
      setState(() {
        isAddingToCart = false;
      });
    }
  }

  // Future<void> sumbitOrderapi(date) async {
  //   setState(() {
  //     isAddingToCart = true;
  //   });
  //
  //   final cartService = CartService();
  //   final box = HiveService().getViewCartBox();
  //
  //   try {
  //     final response = await cartService.submitOrderApi(
  //       deliveryDate: date,
  //       note: notesController.text.trim(),
  //       shippingCharge: totalController.text.trim(),
  //       customerId: customerId,
  //     );
  //
  //     if (response != null && response.statusCode == 200) {
  //       // Online Success
  //       showCustomSuccessSnackbar(
  //         title: "Added to Cart",
  //         message: "This product has been successfully added to your cart.",
  //       );
  //
  //       // Remove old cart and fetch fresh data
  //       await _fetchCart(forceDelete: true);
  //
  //       setState(() {
  //         isAddingToCart = false;
  //       });
  //       Get.to(Homescreen());
  //     } else {
  //       await box.delete("cart_$customerId");
  //       await box.put("cart_$customerId", json.encode({
  //         "offline_order": {
  //           // "date": date,
  //           // "note": notesController.text.trim(),
  //           // "shippingCharge": totalController.text.trim(),
  //           // "customerId": customerId,
  //
  //           "customer_id": customerId,
  //           "shipping_lines": [
  //             {
  //               "method_id": "flat_rate",
  //               "method_title": "Delivery",
  //               "total":  totalController.text.trim(),
  //             }
  //           ],
  //           "delivery_date": date,
  //           "order_note": notesController.text.trim(),
  //           "hide_prices_by_default": false,
  //           "status": "completed"
  //         }
  //       }));
  //
  //       // 🔹 Fetch cart (forceDelete = false to avoid double delete)
  //
  //
  //       showCustomSuccessSnackbar(
  //         title: "Offline Mode",
  //         message: "Product added offline. It will sync once internet is back.",
  //       );
  //
  //       setState(() {
  //         isAddingToCart = false;
  //       });
  //       Get.to(Homescreen());
  //     }
  //   } catch (e,stackTrace) {
  //     showCustomErrorSnackbar(
  //       title: "Error",
  //       message: "Something went wrong while adding product.\n$e",
  //     );
  //     print("stackTrace=======>>>>>>${stackTrace}");
  //     setState(() {
  //       isAddingToCart = false;
  //     });
  //   }
  // }
  //
  //
  // Future<void> _fetchCart({bool forceDelete = false}) async {
  //   var box = HiveService().getViewCartBox();
  //
  //   // 🔹 Only delete old cart if explicitly asked (forceDelete true)
  //   if (forceDelete) {
  //     await box.delete("cart_$customerId");
  //   }
  //
  //   if (!await checkInternet()) {
  //     final cachedData = box.get('cart_$customerId');
  //     if (cachedData != null) {
  //       final data = json.decode(cachedData);
  //       viewCartData = ViewCartDataModal.fromJson(data);
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
  //     final response = await CartService().fetchCart(customerId);
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //
  //       // 🔹 Save fresh data
  //       await box.put("cart_$customerId", response.body);
  //       viewCartData = ViewCartDataModal.fromJson(data);
  //
  //     } else {
  //       final cachedData = box.get('cart_$customerId');
  //       if (cachedData != null) {
  //         final data = json.decode(cachedData);
  //         viewCartData = ViewCartDataModal.fromJson(data);
  //       }
  //       showCustomErrorSnackbar(
  //         title: 'Server Error',
  //         message: 'Something went wrong. Please try again later.',
  //       );
  //     }
  //   } catch (_) {
  //     final cachedData = box.get('cart_$customerId');
  //     if (cachedData != null) {
  //       final data = json.decode(cachedData);
  //       viewCartData = ViewCartDataModal.fromJson(data);
  //     }
  //     showCustomErrorSnackbar(
  //       title: 'Network Error',
  //       message: 'Unable to connect. Please check your internet and try again.',
  //     );
  //   }
  // }

  TextEditingController notesController = TextEditingController();
  TextEditingController totalController = TextEditingController();
}
