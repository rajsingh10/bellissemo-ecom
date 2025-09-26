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
import '../../../utils/emptyWidget.dart';
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

    if (cachedCart != null && cachedCart.toString().isNotEmpty) {
      try {
        final data = json.decode(cachedCart);
        viewCartData = ViewCartDataModal.fromJson(data);
      } catch (e) {
        log("Error decoding cached cart: $e");
        viewCartData = null;
      }
    } else {
      viewCartData = null; // No offline data
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
      backgroundColor: AppColors.bgColor,
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
                  SizedBox(height: 1.h),
                  viewCartData?.items?.length == 0 ||
                          viewCartData?.items?.length == null ||
                          viewCartData?.items?.length == []
                      ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        child: emptyWidget(
                          icon: Icons.shopping_cart_outlined,
                          text: 'Cart',
                        ),
                      )
                      : Expanded(
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

                                                                IntrinsicWidth(
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(
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
                                                                          onTap: () async {
                                                                            final item =
                                                                                viewCartData?.items?[i];
                                                                            if (item ==
                                                                                null)
                                                                              return;

                                                                            final cartService =
                                                                                CartService();
                                                                            final currentQty =
                                                                                item.quantity ??
                                                                                1;

                                                                            try {
                                                                              // 🔹 Offline/Online increase
                                                                              await cartService.decreaseCart(
                                                                                cartItemKey:
                                                                                    item.key ??
                                                                                    "",
                                                                                currentQuantity:
                                                                                    currentQty,
                                                                              );

                                                                              // 🔹 Immediately update UI
                                                                              setState(
                                                                                () {
                                                                                  item.quantity =
                                                                                      currentQty -
                                                                                      1;
                                                                                  updateCartTotalsLocally();
                                                                                },
                                                                              );

                                                                              // 🔹 Only fetch cart from server if online
                                                                              if (await checkInternet()) {
                                                                                await _fetchCart(); // just call it
                                                                                setState(
                                                                                  () {},
                                                                                ); // refresh UI after _fetchCart updates viewCartData
                                                                              }
                                                                            } catch (
                                                                              e
                                                                            ) {
                                                                              showCustomErrorSnackbar(
                                                                                title:
                                                                                    "Error",
                                                                                message:
                                                                                    "Failed to update cart\n$e",
                                                                              );
                                                                            }
                                                                          },
                                                                          child: Container(
                                                                            padding: EdgeInsets.all(
                                                                              1.5.w,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              color:
                                                                                  AppColors.cardBgColor,
                                                                              shape:
                                                                                  BoxShape.circle,
                                                                            ),
                                                                            child: Icon(
                                                                              Icons.remove,
                                                                              size:
                                                                                  isIpad
                                                                                      ? 12.sp
                                                                                      : 16.sp,
                                                                              color:
                                                                                  AppColors.blackColor,
                                                                            ),
                                                                          ),
                                                                        ),

                                                                        SizedBox(
                                                                          width:
                                                                              1.w,
                                                                        ),

                                                                        // Quantity text
                                                                        Text(
                                                                          (viewCartData?.items?[i].quantity ??
                                                                                  0)
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                14.sp,
                                                                            fontFamily:
                                                                                FontFamily.semiBold,
                                                                            color:
                                                                                AppColors.blackColor,
                                                                          ),
                                                                        ),

                                                                        SizedBox(
                                                                          width:
                                                                              1.w,
                                                                        ),

                                                                        // Increase
                                                                        GestureDetector(
                                                                          onTap: () async {
                                                                            final item =
                                                                                viewCartData?.items?[i];
                                                                            if (item ==
                                                                                null)
                                                                              return;

                                                                            final cartService =
                                                                                CartService();
                                                                            final currentQty =
                                                                                item.quantity ??
                                                                                1;

                                                                            try {
                                                                              // 🔹 Offline/Online increase
                                                                              await cartService.increaseCart(
                                                                                cartItemKey:
                                                                                    item.key ??
                                                                                    "",
                                                                                currentQuantity:
                                                                                    currentQty,
                                                                              );

                                                                              // 🔹 Immediately update UI
                                                                              setState(
                                                                                () {
                                                                                  item.quantity =
                                                                                      currentQty +
                                                                                      1;
                                                                                  updateCartTotalsLocally();
                                                                                },
                                                                              );

                                                                              // 🔹 Only fetch cart from server if online
                                                                              if (await checkInternet()) {
                                                                                await _fetchCart(); // just call it
                                                                                setState(
                                                                                  () {},
                                                                                ); // refresh UI after _fetchCart updates viewCartData
                                                                              }
                                                                            } catch (
                                                                              e,
                                                                              stackTrace
                                                                            ) {
                                                                              showCustomErrorSnackbar(
                                                                                title:
                                                                                    "Error",
                                                                                message:
                                                                                    "Failed to update cart\n$e",
                                                                              );
                                                                              print(
                                                                                "e========>>>>>>$e",
                                                                              );
                                                                              print(
                                                                                "e========>>>>>>$stackTrace",
                                                                              );
                                                                              print(
                                                                                "e========>>>>>>$stackTrace",
                                                                              );
                                                                            }
                                                                          },
                                                                          child: Container(
                                                                            padding: EdgeInsets.all(
                                                                              1.5.w,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              color:
                                                                                  AppColors.cardBgColor,
                                                                              shape:
                                                                                  BoxShape.circle,
                                                                            ),
                                                                            child: Icon(
                                                                              Icons.add,
                                                                              size:
                                                                                  isIpad
                                                                                      ? 12.sp
                                                                                      : 16.sp,
                                                                              color:
                                                                                  AppColors.blackColor,
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
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              InkWell(
                                                                onTap: () async {
                                                                  final item =
                                                                      viewCartData
                                                                          ?.items?[i];
                                                                  if (item ==
                                                                      null)
                                                                    return;

                                                                  final cartService =
                                                                      CartService();

                                                                  try {
                                                                    // 🔹 Offline/Online increase
                                                                    await cartService.removeFromCart(
                                                                      cartItemKey:
                                                                          item.key ??
                                                                          "",
                                                                    );

                                                                    // 🔹 Immediately update UI
                                                                    setState(() {
                                                                      viewCartData
                                                                          ?.items
                                                                          ?.removeAt(
                                                                            i,
                                                                          );
                                                                      updateCartTotalsLocally();
                                                                    });

                                                                    // 🔹 Only fetch cart from server if online
                                                                    if (await checkInternet()) {
                                                                      await _fetchCart(); // just call it
                                                                      setState(
                                                                        () {},
                                                                      ); // refresh UI after _fetchCart updates viewCartData
                                                                    }
                                                                  } catch (
                                                                    e,
                                                                    stackTrace
                                                                  ) {
                                                                    showCustomErrorSnackbar(
                                                                      title:
                                                                          "Error",
                                                                      message:
                                                                          "Failed to update cart\n$e",
                                                                    );
                                                                    print(
                                                                      "e========>>>>>>$e",
                                                                    );
                                                                    print(
                                                                      "e========>>>>>>$stackTrace",
                                                                    );
                                                                    print(
                                                                      "e========>>>>>>$stackTrace",
                                                                    );
                                                                  }
                                                                  log(
                                                                    'Hello Clear Button',
                                                                  );
                                                                },
                                                                child: Icon(
                                                                  Icons
                                                                      .delete_outline_rounded,
                                                                  color:
                                                                      AppColors
                                                                          .redColor,
                                                                  size:
                                                                      isIpad
                                                                          ? 16.sp
                                                                          : 18.sp,
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
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 12,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor:
                                                  AppColors.containerColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Apply discount code logic here
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.mainColor,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                          "Sub Total",
                                          style: TextStyle(
                                            color: AppColors.blackColor,
                                            fontSize: 16.sp,
                                            fontFamily: FontFamily.semiBold,
                                          ),
                                        ),
                                        Text(
                                          "${viewCartData?.totals?.currencySymbol} ${(viewCartData?.totals?.totalItems ?? 0).toString()}",
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
                                          " ${viewCartData?.totals?.currencySymbol} ${viewCartData?.totals?.totalShipping ?? "0"}",
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
          viewCartData?.items?.length == 0 ||
                  viewCartData?.items?.length == null ||
                  viewCartData?.items?.length == []
              ? Container()
              : Container(
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
                          "${viewCartData?.totals?.currencySymbol} ${(viewCartData?.totals?.totalPrice).toString()}",
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

  void updateCartTotalsLocally() {
    if (viewCartData == null) return;

    double subtotal = 0.0;
    double tax = 0.0;
    double shipping =
        double.tryParse(viewCartData?.totals?.totalShipping ?? '0') ?? 0.0;
    double discount =
        double.tryParse(viewCartData?.totals?.totalDiscount ?? '0') ?? 0.0;

    for (var item in viewCartData!.items ?? []) {
      // Safe way - check if prices exists
      if (item.prices != null) {
        double itemPrice = double.tryParse(item.prices!.price ?? '0') ?? 0.0;
        int quantity = item.quantity ?? 0;

        subtotal += itemPrice * quantity;

        double itemTax = 0.0; // Temporary - tax નો issue solve થઈ જશે

        tax += itemTax * quantity;
      }
    }

    double totalPrice = subtotal + tax + shipping - discount;

    viewCartData!.totals = Totals(
      currencySymbol: viewCartData!.totals?.currencySymbol ?? "\$",
      totalItems: subtotal.round().toString(),
      totalTax: tax.round().toString(),
      totalShipping: shipping.round().toString(),
      totalDiscount: discount.round().toString(),
      totalPrice: totalPrice.round().toString(),
    );
  }

  Future<void> _fetchCart() async {
    var box = HiveService().getViewCartBox();

    // ✅ Offline mode
    if (!await checkInternet()) {
      final cachedData = box.get('cart_$customerId');

      if (cachedData != null && cachedData.toString().isNotEmpty) {
        try {
          final data = json.decode(cachedData);
          viewCartData = ViewCartDataModal.fromJson(data);
        } catch (e) {
          log("Error decoding cached cart: $e");
          viewCartData = null;
        }
      } else {
        viewCartData = null;
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Your cart is empty or offline data not found.',
        );
      }
      return;
    }

    // ✅ Online mode
    try {
      final response = await CartService().fetchCart(customerId);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data == null || (data['items'] as List).isEmpty) {
          viewCartData = null;
          await box.delete('cart_$customerId'); // clear cache
        } else {
          viewCartData = ViewCartDataModal.fromJson(data);
          await box.put(
            'cart_$customerId',
            response.body,
          ); // save raw JSON string
        }
      } else {
        // fallback to cache
        final cachedData = box.get('cart_$customerId');
        if (cachedData != null && cachedData.toString().isNotEmpty) {
          final data = json.decode(cachedData);
          viewCartData = ViewCartDataModal.fromJson(data);
        } else {
          viewCartData = null;
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (e) {
      // fallback to cache
      final cachedData = box.get('cart_$customerId');
      if (cachedData != null && cachedData.toString().isNotEmpty) {
        try {
          final data = json.decode(cachedData);
          viewCartData = ViewCartDataModal.fromJson(data);
        } catch (_) {
          viewCartData = null;
        }
      } else {
        viewCartData = null;
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }

  // Future<void> _fetchCart() async {
  //   var box = HiveService().getViewCartBox();
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
  //       viewCartData = ViewCartDataModal.fromJson(data);
  //       await box.put("cart_$customerId", response.body);
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
}
