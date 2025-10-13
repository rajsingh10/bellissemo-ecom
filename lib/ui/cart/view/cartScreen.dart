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
import '../../../utils/textFields.dart';
import '../../../utils/titlebarWidget.dart';
import '../modal/copunsListModal.dart';
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

    // 🔹 Load cached data first
    _loadCachedData();

    final stopwatch = Stopwatch()..start();
    try {
      // 🔹 Run APIs parallel (cart + coupons)
      await Future.wait([
        _fetchCart().then((_) => setState(() {})),
        _fetchCoupons().then((_) => setState(() {})),
      ]);
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
    var couponBox = HiveService().getCouponListBox();

    // 🔹 Load cached cart
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
      viewCartData = null; // No offline cart
    }

    // 🔹 Load cached coupons
    final cachedCoupons = couponBox.get('coupons'); // without customerId key
    if (cachedCoupons != null && cachedCoupons.toString().isNotEmpty) {
      try {
        final List data = json.decode(cachedCoupons);
        couponslist = data.map((e) => CouponListModal.fromJson(e)).toList();
      } catch (e) {
        log("Error decoding cached coupons: $e");
        couponslist = [];
      }
    } else {
      couponslist = []; // No offline coupons
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
                        padding: EdgeInsets.symmetric(
                          vertical: isIpad ? 2.h : 15.h,
                        ),
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
                                                                          // onTap: () async {
                                                                          //   final item =
                                                                          //       viewCartData?.items?[i];
                                                                          //   if (item ==
                                                                          //       null)
                                                                          //     return;
                                                                          //
                                                                          //   final cartService =
                                                                          //       CartService();
                                                                          //   final currentQty =
                                                                          //       item.quantity ??
                                                                          //       1;
                                                                          //
                                                                          //   try {
                                                                          //     // 🔹 Offline/Online increase
                                                                          //     await cartService.decreaseCart(
                                                                          //       cartItemKey:
                                                                          //           item.key ??
                                                                          //           "",
                                                                          //       currentQuantity:
                                                                          //           currentQty,
                                                                          //     );
                                                                          //
                                                                          //     // 🔹 Immediately update UI
                                                                          //     setState(
                                                                          //       () {
                                                                          //         item.quantity =
                                                                          //             currentQty -
                                                                          //             1;
                                                                          //         updateCartTotalsLocally();
                                                                          //       },
                                                                          //     );
                                                                          //
                                                                          //     // 🔹 Only fetch cart from server if online
                                                                          //     if (await checkInternet()) {
                                                                          //       await _fetchCart(); // just call it
                                                                          //       setState(
                                                                          //         () {},
                                                                          //       ); // refresh UI after _fetchCart updates viewCartData
                                                                          //     }
                                                                          //   } catch (
                                                                          //     e
                                                                          //   ) {
                                                                          //     showCustomErrorSnackbar(
                                                                          //       title:
                                                                          //           "Error",
                                                                          //       message:
                                                                          //           "Failed to update cart\n$e",
                                                                          //     );
                                                                          //   }
                                                                          // },
                                                                          onTap: () async {
                                                                            final item =
                                                                                viewCartData?.items?[i];
                                                                            if (item ==
                                                                                null) {
                                                                              return;
                                                                            }

                                                                            final currentQty =
                                                                                item.quantity ??
                                                                                1;
                                                                            final cartService =
                                                                                CartService();

                                                                            try {
                                                                              if (currentQty >
                                                                                  1) {
                                                                                // 🔹 Just decrease quantity
                                                                                setState(
                                                                                  () {
                                                                                    item.quantity =
                                                                                        currentQty -
                                                                                        1;
                                                                                    updateCartTotalsLocally();
                                                                                  },
                                                                                );

                                                                                // 🔹 Update Hive cache
                                                                                var box =
                                                                                    HiveService().getViewCartBox();
                                                                                final cachedData = box.get(
                                                                                  'cart_$customerId',
                                                                                );
                                                                                if (cachedData !=
                                                                                        null &&
                                                                                    cachedData.toString().isNotEmpty) {
                                                                                  try {
                                                                                    final data = json.decode(
                                                                                      cachedData,
                                                                                    );
                                                                                    final cachedCart = ViewCartDataModal.fromJson(
                                                                                      data,
                                                                                    );
                                                                                    cachedCart.items?[i].quantity =
                                                                                        currentQty -
                                                                                        1;
                                                                                    await box.put(
                                                                                      'cart_$customerId',
                                                                                      json.encode(
                                                                                        cachedCart.toJson(),
                                                                                      ),
                                                                                    );
                                                                                  } catch (
                                                                                    e
                                                                                  ) {
                                                                                    log(
                                                                                      "Error updating offline cache: $e",
                                                                                    );
                                                                                  }
                                                                                }

                                                                                // 🔹 Sync with server if online
                                                                                if (await checkInternet()) {
                                                                                  await cartService.decreaseCart(
                                                                                    cartItemKey:
                                                                                        item.key ??
                                                                                        "",
                                                                                    currentQuantity:
                                                                                        currentQty,
                                                                                  );
                                                                                  await _fetchCart();
                                                                                  setState(
                                                                                    () {},
                                                                                  );
                                                                                }
                                                                              } else {
                                                                                // 🔹 Quantity is 1, remove item
                                                                                setState(
                                                                                  () {
                                                                                    viewCartData?.items?.removeAt(
                                                                                      i,
                                                                                    );
                                                                                    updateCartTotalsLocally();
                                                                                  },
                                                                                );

                                                                                // 🔹 Update Hive cache
                                                                                var box =
                                                                                    HiveService().getViewCartBox();
                                                                                final cachedData = box.get(
                                                                                  'cart_$customerId',
                                                                                );
                                                                                if (cachedData !=
                                                                                        null &&
                                                                                    cachedData.toString().isNotEmpty) {
                                                                                  try {
                                                                                    final data = json.decode(
                                                                                      cachedData,
                                                                                    );
                                                                                    final cachedCart = ViewCartDataModal.fromJson(
                                                                                      data,
                                                                                    );
                                                                                    cachedCart.items?.removeAt(
                                                                                      i,
                                                                                    );
                                                                                    await box.put(
                                                                                      'cart_$customerId',
                                                                                      json.encode(
                                                                                        cachedCart.toJson(),
                                                                                      ),
                                                                                    );
                                                                                  } catch (
                                                                                    e
                                                                                  ) {
                                                                                    log(
                                                                                      "Error updating offline cache: $e",
                                                                                    );
                                                                                  }
                                                                                }

                                                                                // 🔹 Remove from server if online
                                                                                if (await checkInternet()) {
                                                                                  await cartService.removeFromCart(
                                                                                    cartItemKey:
                                                                                        item.key ??
                                                                                        "",
                                                                                  );
                                                                                  await _fetchCart();
                                                                                  setState(
                                                                                    () {},
                                                                                  );
                                                                                }
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
                                                                              log(
                                                                                "Error========>>>>>>$e",
                                                                              );
                                                                              log(
                                                                                "StackTrace========>>>>>>$stackTrace",
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
                                                                          // onTap: () async {
                                                                          //   final item =
                                                                          //       viewCartData?.items?[i];
                                                                          //   if (item ==
                                                                          //       null)
                                                                          //     return;
                                                                          //
                                                                          //   final cartService =
                                                                          //       CartService();
                                                                          //   final currentQty =
                                                                          //       item.quantity ??
                                                                          //       1;
                                                                          //
                                                                          //   try {
                                                                          //     // 🔹 Offline/Online increase
                                                                          //     await cartService.increaseCart(
                                                                          //       cartItemKey:
                                                                          //           item.key ??
                                                                          //           "",
                                                                          //       currentQuantity:
                                                                          //           currentQty,
                                                                          //     );
                                                                          //
                                                                          //     // 🔹 Immediately update UI
                                                                          //     setState(
                                                                          //       () {
                                                                          //         item.quantity =
                                                                          //             currentQty +
                                                                          //             1;
                                                                          //         updateCartTotalsLocally();
                                                                          //       },
                                                                          //     );
                                                                          //
                                                                          //     // 🔹 Only fetch cart from server if online
                                                                          //     if (await checkInternet()) {
                                                                          //       await _fetchCart(); // just call it
                                                                          //       setState(
                                                                          //         () {},
                                                                          //       ); // refresh UI after _fetchCart updates viewCartData
                                                                          //     }
                                                                          //   } catch (
                                                                          //     e,
                                                                          //     stackTrace
                                                                          //   ) {
                                                                          //     showCustomErrorSnackbar(
                                                                          //       title:
                                                                          //           "Error",
                                                                          //       message:
                                                                          //           "Failed to update cart\n$e",
                                                                          //     );
                                                                          //     print(
                                                                          //       "e========>>>>>>$e",
                                                                          //     );
                                                                          //     print(
                                                                          //       "e========>>>>>>$stackTrace",
                                                                          //     );
                                                                          //     print(
                                                                          //       "e========>>>>>>$stackTrace",
                                                                          //     );
                                                                          //   }
                                                                          // },
                                                                          onTap: () async {
                                                                            final item =
                                                                                viewCartData?.items?[i];
                                                                            if (item ==
                                                                                null) {
                                                                              return;
                                                                            }

                                                                            final currentQty =
                                                                                item.quantity ??
                                                                                1;

                                                                            // update local UI
                                                                            setState(() {
                                                                              item.quantity =
                                                                                  currentQty +
                                                                                  1;
                                                                              updateCartTotalsLocally();
                                                                            });

                                                                            // update Hive cache immediately
                                                                            var box =
                                                                                HiveService().getViewCartBox();
                                                                            final cachedData = box.get(
                                                                              'cart_$customerId',
                                                                            );
                                                                            if (cachedData !=
                                                                                    null &&
                                                                                cachedData.toString().isNotEmpty) {
                                                                              try {
                                                                                final data = json.decode(
                                                                                  cachedData,
                                                                                );
                                                                                final cachedCart = ViewCartDataModal.fromJson(
                                                                                  data,
                                                                                );
                                                                                cachedCart.items?[i].quantity =
                                                                                    currentQty +
                                                                                    1;
                                                                                await box.put(
                                                                                  'cart_$customerId',
                                                                                  json.encode(
                                                                                    cachedCart.toJson(),
                                                                                  ),
                                                                                );
                                                                              } catch (
                                                                                e
                                                                              ) {
                                                                                log(
                                                                                  "Error updating offline cache: $e",
                                                                                );
                                                                              }
                                                                            }

                                                                            // then only call server if online
                                                                            if (await checkInternet()) {
                                                                              try {
                                                                                await CartService().increaseCart(
                                                                                  overrideprice:
                                                                                      (double.parse(
                                                                                                viewCartData?.items?[i].prices?.price ??
                                                                                                    "0",
                                                                                              ) /
                                                                                              100)
                                                                                          .toInt(),

                                                                                  cartItemKey:
                                                                                      item.key ??
                                                                                      "",
                                                                                  online:
                                                                                      false,
                                                                                  currentQuantity:
                                                                                      currentQty,
                                                                                );
                                                                                await _fetchCart(); // refresh from server
                                                                                setState(
                                                                                  () {},
                                                                                ); // refresh UI after fetch
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
                                                                  setState(() {
                                                                    isLoading=true;
                                                                  });
                                                                  final item =
                                                                      viewCartData
                                                                          ?.items?[i];
                                                                  if (item ==
                                                                      null) {
                                                                    return;
                                                                  }

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
                                                                        () {
                                                                          isLoading=false;
                                                                        },
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
                                                                    log(
                                                                      "e========>>>>>>$e",
                                                                    );
                                                                    log(
                                                                      "e========>>>>>>$stackTrace",
                                                                    );
                                                                    log(
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
                                                              //     // ${(double.tryParse(viewCartData?.totals?.totalItems ?? '0')! / 100).toStringAsFixed(2)
                                                              //   "\$ ${(double.parse(viewCartData?.items?[i].prices?.price ?? "")! /100).toStringAsFixed(2) }",
                                                              //   style: TextStyle(
                                                              //     color: AppColors.blackColor,
                                                              //     fontSize: 14.sp,
                                                              //     fontFamily:
                                                              //         FontFamily.semiBold,
                                                              //   ),
                                                              // ),
                                                              InkWell(
                                                                onTap: () async {
                                                                  final discountResult = await Get.dialog<
                                                                    Map<
                                                                      String,
                                                                      String
                                                                    >
                                                                  >(
                                                                    Dialog(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      child: StatefulBuilder(
                                                                        builder: (
                                                                          context,
                                                                          setState,
                                                                        ) {
                                                                          final formKey =
                                                                              GlobalKey<
                                                                                FormState
                                                                              >();
                                                                          TextEditingController
                                                                          dialogController =
                                                                              TextEditingController();
                                                                          String
                                                                          selectedType =
                                                                              "Amount"; // 👈 default dropdown value

                                                                          return IntrinsicWidth(
                                                                            stepWidth:
                                                                                300,
                                                                            child: IntrinsicHeight(
                                                                              child: Container(
                                                                                padding: EdgeInsets.all(
                                                                                  16,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  color:
                                                                                      AppColors.whiteColor,
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    15,
                                                                                  ),
                                                                                ),
                                                                                child: Column(
                                                                                  mainAxisSize:
                                                                                      MainAxisSize.min,
                                                                                  children: [
                                                                                    Form(
                                                                                      key:
                                                                                          formKey,
                                                                                      child: AppTextField(
                                                                                        key: ValueKey(
                                                                                          selectedType,
                                                                                        ),
                                                                                        controller:
                                                                                            dialogController,
                                                                                        hintText:
                                                                                            "Increase",
                                                                                        text:
                                                                                            "Increase",
                                                                                        isTextavailable:
                                                                                            true,
                                                                                        textInputType:
                                                                                            TextInputType.number,
                                                                                        maxline:
                                                                                            1,
                                                                                        validator: (
                                                                                          value,
                                                                                        ) {
                                                                                          if (value !=
                                                                                                  null &&
                                                                                              value.isNotEmpty &&
                                                                                              double.tryParse(
                                                                                                    value,
                                                                                                  ) ==
                                                                                                  null) {
                                                                                            return "Enter a valid number";
                                                                                          }
                                                                                          return null;
                                                                                        },
                                                                                      ),
                                                                                    ),

                                                                                    SizedBox(
                                                                                      height:
                                                                                          24,
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment:
                                                                                          MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        CustomButton(
                                                                                          title:
                                                                                              "Cancel",
                                                                                          route:
                                                                                              () =>
                                                                                                  Get.back(),
                                                                                          color:
                                                                                              AppColors.containerColor,
                                                                                          fontcolor:
                                                                                              AppColors.blackColor,
                                                                                          height:
                                                                                              5.h,
                                                                                          width:
                                                                                              27.w,
                                                                                          fontsize:
                                                                                              15.sp,
                                                                                          radius:
                                                                                              12.0,
                                                                                        ),
                                                                                        CustomButton(
                                                                                          title:
                                                                                              "Increase Price",
                                                                                          route: () async {
                                                                                            bool increseprice =
                                                                                                true;
                                                                                            final item =
                                                                                                viewCartData?.items?[i];
                                                                                            if (item ==
                                                                                                null) {

                                                                                              return;
                                                                                            }

                                                                                            final currentQty =
                                                                                                item.quantity ??
                                                                                                1;
                                                                                            final newPrice =
                                                                                                double.tryParse(
                                                                                                  dialogController.text,
                                                                                                ) ??
                                                                                                0;
                                                                                            // update local UI
                                                                                            setState(
                                                                                              () {
                                                                                                // item.quantity =
                                                                                                //     currentQty + int.parse(item.quantity.toString())
                                                                                                //     ;
                                                                                                increseprice =
                                                                                                    true;
                                                                                                updateCartTotalsLocally(
                                                                                                  offlineitemamount:
                                                                                                      newPrice *
                                                                                                      100,
                                                                                                  itemIndex:
                                                                                                      i,
                                                                                                );
                                                                                                // Get.back();
                                                                                              },
                                                                                            );

                                                                                            // update Hive cache immediately
                                                                                            var box =
                                                                                                HiveService().getViewCartBox();
                                                                                            final cachedData = box.get(
                                                                                              'cart_$customerId',
                                                                                            );
                                                                                            if (cachedData !=
                                                                                                    null &&
                                                                                                cachedData.toString().isNotEmpty) {
                                                                                              try {
                                                                                                final data = json.decode(
                                                                                                  cachedData,
                                                                                                );
                                                                                                final cachedCart = ViewCartDataModal.fromJson(
                                                                                                  data,
                                                                                                );
                                                                                                cachedCart.items?[i].quantity = int.parse(
                                                                                                  item.quantity.toString(),
                                                                                                );
                                                                                                await box.put(
                                                                                                  'cart_$customerId',
                                                                                                  json.encode(
                                                                                                    cachedCart.toJson(),
                                                                                                  ),
                                                                                                );
                                                                                              } catch (
                                                                                                e
                                                                                              ) {
                                                                                                log(
                                                                                                  "Error updating offline cache: $e",
                                                                                                );
                                                                                              }
                                                                                            }

                                                                                            // update server if online
                                                                                            if (await checkInternet()) {
                                                                                              try {
                                                                                                await CartService().increaseCart(
                                                                                                  overrideprice: int.parse(
                                                                                                    dialogController.text.toString(),
                                                                                                  ),
                                                                                                  cartItemKey:
                                                                                                      item.key ??
                                                                                                      "",
                                                                                                  online:
                                                                                                      increseprice,
                                                                                                  currentQuantity:
                                                                                                      currentQty,
                                                                                                );
                                                                                                await _fetchCart();
                                                                                                // Get.back();
                                                                                                Get.offAll(
                                                                                                  CartScreen(),
                                                                                                );
                                                                                              } catch (
                                                                                                e,
                                                                                                trackTrace
                                                                                              ) {
                                                                                                showCustomErrorSnackbar(
                                                                                                  title:
                                                                                                      "Error",
                                                                                                  message:
                                                                                                      "Failed to update cart\n$e",
                                                                                                );
                                                                                                log(
                                                                                                  "shu errro ave che =====>>>>$trackTrace",
                                                                                                );
                                                                                              }
                                                                                            }
                                                                                          },
                                                                                          color:
                                                                                              AppColors.mainColor,
                                                                                          fontcolor:
                                                                                              AppColors.whiteColor,
                                                                                          height:
                                                                                              5.h,
                                                                                          width:
                                                                                              40.w,
                                                                                          fontsize:
                                                                                              15.sp,
                                                                                          radius:
                                                                                              12.0,
                                                                                          iconData:
                                                                                              Icons.check,
                                                                                          iconsize:
                                                                                              17.sp,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                    barrierDismissible:
                                                                        true,
                                                                  );
                                                                },
                                                                child: Container(
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(Icons.edit,color: AppColors.mainColor,),
                                                                      SizedBox(width: 2.w,),
                                                                      Text(
                                                                        (double.parse(
                                                                                  viewCartData?.items?[i].prices?.price ??
                                                                                      "0",
                                                                                ) /
                                                                                100)
                                                                            .toStringAsFixed(
                                                                              2,
                                                                            ),
                                                                        style: TextStyle(
                                                                          color:
                                                                              AppColors
                                                                                  .blackColor,
                                                                          fontSize:
                                                                              14.sp,
                                                                          fontFamily:
                                                                              FontFamily
                                                                                  .semiBold,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
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
                                          "${viewCartData?.totals?.currencySymbol} ${(double.tryParse(viewCartData?.totals?.totalItems ?? '0')! / 100).toStringAsFixed(2)}",
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
                                          "${viewCartData?.totals?.currencySymbol} ${(double.tryParse(viewCartData?.totals?.totalTax ?? '0')! / 100).toStringAsFixed(2)}",
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
                                        Row(
                                          children: [
                                            Text(
                                              "Discount",
                                              style: TextStyle(
                                                color: AppColors.gray,
                                                fontSize: 16.sp,
                                                fontFamily: FontFamily.semiBold,
                                              ),
                                            ),
                                            SizedBox(width: 2.w),

                                            InkWell(
                                              onTap: () async {
                                                final formKey =
                                                    GlobalKey<FormState>();
                                                TextEditingController
                                                dialogController =
                                                    TextEditingController();
                                                String selectedType =
                                                    "Fixed"; // default

                                                final discountResult = await Get.dialog<
                                                  Map<String, String>
                                                >(
                                                  Dialog(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    child: StatefulBuilder(
                                                      builder: (
                                                        context,
                                                        setState,
                                                      ) {
                                                        return IntrinsicWidth(
                                                          stepWidth: 300,
                                                          child: IntrinsicHeight(
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    16,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    AppColors
                                                                        .whiteColor,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      15,
                                                                    ),
                                                              ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    "Apply Discount",
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          18.sp,
                                                                      fontFamily:
                                                                          FontFamily
                                                                              .bold,
                                                                      color:
                                                                          AppColors
                                                                              .blackColor,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 16,
                                                                  ),

                                                                  // 👇 Dropdown for Amount / Percentage
                                                                  Row(
                                                                    children: [
                                                                      Container(
                                                                        width: 65.w,
                                                                        child: DropdownButtonFormField<
                                                                          String
                                                                        >(
                                                                          value:
                                                                              selectedType,
                                                                          items:
                                                                              [
                                                                                    "Fixed",
                                                                                    "Percentage",
                                                                                  ]
                                                                                  .map(
                                                                                    (
                                                                                      e,
                                                                                    ) => DropdownMenuItem(
                                                                                      value:
                                                                                          e,
                                                                                      child: Text(
                                                                                        e,
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                  .toList(),
                                                                          onChanged: (
                                                                            val,
                                                                          ) {
                                                                            setState(() {
                                                                              selectedType =
                                                                                  val!;
                                                                              log(
                                                                                "selectedType====>>>>> $selectedType",
                                                                              );
                                                                            });
                                                                          },
                                                                          decoration: InputDecoration(
                                                                            disabledBorder: OutlineInputBorder(),
                                                                            labelText:
                                                                                "Discount Type",
                                                                            border: OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(
                                                                                8,
                                                                              ),
                                                                            ),

                                                                          ),
                                                                        ),
                                                                      ),

                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 16,
                                                                  ),

                                                                  Form(
                                                                    key:
                                                                        formKey,
                                                                    child: AppTextField(
                                                                      key: ValueKey(
                                                                        selectedType,
                                                                      ),
                                                                      controller:
                                                                          dialogController,
                                                                      hintText:
                                                                          selectedType ==
                                                                                  "Fixed"
                                                                              ? "Enter Discount Fixed"
                                                                              : "Enter Discount percentage",
                                                                      text:
                                                                          selectedType ==
                                                                                  "Fixed"
                                                                              ? "Discount Fixed"
                                                                              : "Discount percentage",
                                                                      isTextavailable:
                                                                          true,
                                                                      textInputType:
                                                                          TextInputType
                                                                              .number,
                                                                      maxline:
                                                                          1,
                                                                      validator: (
                                                                        value,
                                                                      ) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return "Please enter a discount";
                                                                        }

                                                                        final parsed =
                                                                            double.tryParse(
                                                                              value,
                                                                            );
                                                                        if (parsed ==
                                                                            null) {
                                                                          return "Enter a valid number";
                                                                        }

                                                                        if (parsed <=
                                                                            0) {
                                                                          return "Value must be greater than 0";
                                                                        }

                                                                        // 💡 Get subtotal from cart
                                                                        final subtotalInCents =
                                                                            double.tryParse(
                                                                              viewCartData?.totals?.totalItems ??
                                                                                  '0',
                                                                            ) ??
                                                                            0.0;
                                                                        final subtotal =
                                                                            subtotalInCents /
                                                                            100;

                                                                        // 🔹 Percentage should not exceed 100
                                                                        if (selectedType ==
                                                                                "Percentage" &&
                                                                            parsed >
                                                                                100) {
                                                                          return "percentage can't be more than 100";
                                                                        }

                                                                        // 🔹 Amount should not exceed subtotal
                                                                        if (selectedType ==
                                                                                "Fixed" &&
                                                                            parsed >
                                                                                subtotal) {
                                                                          return "Discount can't exceed${viewCartData?.totals?.currencySymbol} ${subtotal.toStringAsFixed(2)}";
                                                                        }

                                                                        return null;
                                                                      },
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 24,
                                                                  ),

                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      CustomButton(
                                                                        title:
                                                                            "Cancel",
                                                                        route:
                                                                            () =>
                                                                                Get.back(),
                                                                        color:
                                                                            AppColors.containerColor,
                                                                        fontcolor:
                                                                            AppColors.blackColor,
                                                                        height:
                                                                            5.h,
                                                                        width:
                                                                            27.w,
                                                                        fontsize:
                                                                            15.sp,
                                                                        radius:
                                                                            12.0,
                                                                      ),
                                                                      CustomButton(
                                                                        title:
                                                                            "Apply Discount",
                                                                        route: () {
                                                                          if (!formKey
                                                                              .currentState!
                                                                              .validate()) {
                                                                            return;
                                                                          }

                                                                          final charge =
                                                                              dialogController.text.trim();
                                                                          log(
                                                                            "=========>>>>>>>>>>>>> $selectedType",
                                                                          );

                                                                          // 👇 Return result to parent
                                                                          Get.back(
                                                                            result: {
                                                                              "type":
                                                                                  selectedType,
                                                                              "value":
                                                                                  charge,
                                                                            },
                                                                          );
                                                                        },
                                                                        color:
                                                                            AppColors.mainColor,
                                                                        fontcolor:
                                                                            AppColors.whiteColor,
                                                                        height:
                                                                            5.h,
                                                                        width:
                                                                            40.w,
                                                                        fontsize:
                                                                            15.sp,
                                                                        radius:
                                                                            12.0,
                                                                        iconData:
                                                                            Icons.check,
                                                                        iconsize:
                                                                            17.sp,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  barrierDismissible: true,
                                                );

                                                if (discountResult != null) {
                                                  setState(() {
                                                    log(
                                                      "✅ Discount Selected: $discountResult",
                                                    );
                                                    log(
                                                      "=========>>>>>>>>>>>>>${selectedType.toString()}",
                                                    );
                                                    final cartService =
                                                        CartService();

                                                    cartService.applyDiscount(
                                                      customerId: int.parse(
                                                        customerId.toString(),
                                                      ),
                                                      discountType:
                                                          selectedType,
                                                      discountValue:
                                                          double.parse(
                                                            dialogController
                                                                .text
                                                                .trim(),
                                                          ),
                                                      enabled: true,
                                                      onSuccess: () {
                                                        log(
                                                          "API call successful",
                                                        );

                                                        WidgetsBinding.instance
                                                            .addPostFrameCallback((
                                                              _,
                                                            ) {
                                                              Get.offAll(
                                                                () =>
                                                                    CartScreen(),
                                                              );
                                                              _fetchCart();
                                                            });
                                                      },
                                                    );
                                                    if (selectedType ==
                                                        "Percentage") {
                                                      updateCartTotalsLocally(
                                                        offlineDiscount:
                                                            double.parse(
                                                              dialogController
                                                                  .text
                                                                  .trim(),
                                                            ),
                                                        discounttype:
                                                            selectedType,
                                                      );
                                                    } else {
                                                      updateCartTotalsLocally(
                                                        offlineDiscount:
                                                            double.parse(
                                                              dialogController
                                                                  .text
                                                                  .trim(),
                                                            ) *
                                                            100,
                                                        discounttype:
                                                            selectedType,
                                                      );
                                                    }

                                                    // Apply your discount here using discountResult["type"] and ["value"]
                                                  });
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback((
                                                        _,
                                                      ) {
                                                        Get.offAll(
                                                          () => CartScreen(),
                                                        );
                                                        // _fetchCart();
                                                      });
                                                }
                                              },

                                              child: Text(
                                                'Apply Discount',
                                                style: TextStyle(
                                                  color: AppColors.mainColor,
                                                  fontSize: 16.sp,
                                                  fontFamily:
                                                      FontFamily.semiBold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "- ${viewCartData?.totals?.currencySymbol} ${(double.tryParse(viewCartData?.totals?.customerDiscountValue ?? '0')! / 100).toStringAsFixed(2)}",

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
                                        // Text(
                                        //   "${viewCartData?.totals?.currencySymbol}${(double.tryParse((totalamount?.tostring ?? 0)! / 100).toStringAsFixed(2)}",
                                        //   // "\$ ${(subtotal + shipping + tax).toStringAsFixed(2)}",
                                        //   style: TextStyle(
                                        //     color: AppColors.blackColor,
                                        //     fontSize: 17.sp,
                                        //     fontFamily: FontFamily.semiBold,
                                        //   ),
                                        // ),
                                        Text(
                                          "${viewCartData?.totals?.currencySymbol}${((double.tryParse(totalamount == "" || totalamount == null ? (viewCartData?.totals?.totalPrice).toString() : totalamount ?? '0') ?? 0) / 100).toStringAsFixed(2)}",
                                          style: TextStyle(
                                            color: AppColors.blackColor,
                                            fontSize: 17.sp,
                                            fontFamily: FontFamily.semiBold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [

                                        // Text(
                                        //   "${viewCartData?.totals?.currencySymbol}${(double.tryParse((totalamount?.tostring ?? 0)! / 100).toStringAsFixed(2)}",
                                        //   // "\$ ${(subtotal + shipping + tax).toStringAsFixed(2)}",
                                        //   style: TextStyle(
                                        //     color: AppColors.blackColor,
                                        //     fontSize: 17.sp,
                                        //     fontFamily: FontFamily.semiBold,
                                        //   ),
                                        // ),
                                        viewCartData?.totals?.customerDiscount?.enabled==false?Container() : viewCartData?.totals?.customerDiscount?.type=="percentage"  ? Text(
                                    "*${viewCartData?.totals?.customerDiscount?.value}% Discount",
                                      style: TextStyle(
                                        color: AppColors.redColor,
                                        fontSize: 17.sp,
                                        fontFamily: FontFamily.semiBold,
                                      ),
                                    ):Text(
                                          "*${viewCartData?.totals?.currencySymbol}${viewCartData?.totals?.customerDiscount?.value} Discount",
                                          style: TextStyle(
                                            color: AppColors.redColor,
                                            fontSize: 17.sp,
                                            fontFamily: FontFamily.semiBold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // 👇 Shipping Checkbox
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 0.9,
                                        child: Checkbox(
                                          activeColor: AppColors.mainColor,
                                          value: credit,
                                          onChanged: (value) {
                                            setState(() {
                                              credit = value ?? false;
                                              log("=====>>>>>>>>$credit");
                                              proforma = false;
                                            });
                                          },
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            credit = true;
                                            log("=====>>>>>>>>$credit");
                                            proforma = false;
                                          });
                                        },
                                        child: Text(
                                          "Credit",
                                          style: TextStyle(
                                            color: AppColors.gray,
                                            fontSize: 16.sp,
                                            fontFamily: FontFamily.semiBold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(
                                    width: 20,
                                  ), // spacing between two checkboxes
                                  // 👇 Discount Checkbox
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 0.9,
                                        child: Checkbox(
                                          activeColor: AppColors.mainColor,
                                          value: proforma,
                                          onChanged: (value) {
                                            setState(() {
                                              proforma = value ?? false;
                                              log("=====>>>>>>>>$proforma");
                                              credit = false;
                                            });
                                          },
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            proforma = true;
                                            log("=====>>>>>>>>$proforma");
                                            credit = false;
                                          });
                                        },
                                        child: Text(
                                          "Proforma",
                                          style: TextStyle(
                                            color: AppColors.gray,
                                            fontSize: 16.sp,
                                            fontFamily: FontFamily.semiBold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
         isLoading|| viewCartData?.items?.length == 0 ||
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
                          "${viewCartData?.totals?.currencySymbol}${((double.tryParse(totalamount == "" || totalamount == null ? (viewCartData?.totals?.totalPrice).toString() : totalamount ?? '0') ?? 0) / 100).toStringAsFixed(2)}",
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
                          if (!credit && !proforma) {
                            showCustomErrorSnackbar(
                              title: "Credit or Proforma",
                              message: "Please Select Credit or Proforma",
                            );
                          } else {
                            Get.to(
                              CheckOutScreen(
                                cridit: credit == true ? "credit" : "proforma",
                              ),
                              transition: Transition.fade,
                              duration: const Duration(milliseconds: 450),
                            );
                          }
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

  double discount1 = 0.0;
  bool isShippingEnabled = false;

  Future<void> updateCartTotalsLocally({
    String? discounttype,
    double? offlineDiscount,
    double? offlineitemamount,
    int? itemIndex,
    bool removeCoupon = false,
  }) async {
    log("discounttype shu ave che =====>>>.$discounttype");
    if (viewCartData == null) return;

    log("offlineDiscount======>>>>>>> $offlineDiscount");

    double subtotal = 0.0;
    double tax = 0.0;
    double shipping =
        double.tryParse(viewCartData?.totals?.totalShipping ?? '0') ?? 0.0;
    double discount =
        double.tryParse(viewCartData?.totals?.customerDiscountValue ?? '0') ??
        0.0;

    // 🛒 Loop through items to calculate subtotal
    for (int i = 0; i < (viewCartData!.items?.length ?? 0); i++) {
      var item = viewCartData!.items![i];

      if (item.prices != null) {
        double itemPrice;

        // 🎯 If specific item needs to be updated
        if (itemIndex != null && i == itemIndex && offlineitemamount != null) {
          itemPrice = offlineitemamount;
          item.prices!.price = itemPrice.toString(); // Update item's price
          log("Updated item price =========>>>> ${item.prices!.price}");
        } else {
          itemPrice = double.tryParse(item.prices?.price ?? '0') ?? 0.0;
        }

        int quantity = item.quantity ?? 0;
        log("quantity====>>>> $quantity");

        subtotal += itemPrice * quantity;

        // Add tax per item if needed (currently zero)
        double itemTax = 0.0;
        tax += itemTax * quantity;
      }
    }

    // 💸 Apply discount logic
    if (removeCoupon) {
      discount = 0.0;
    } else if (offlineDiscount != null) {
      if (discounttype == "percentage") {
        discount = (offlineDiscount / 100) * subtotal;
        log("discount=====>>>>>$discount");
      } else {
        discount = offlineDiscount;
      }
    }

    // 🧮 Final total price after discount
    double totalPrice = subtotal - discount;
    log("totalPrice====>>>>>>>$totalPrice");
    if (totalPrice < 0) totalPrice = 0;

    // 🧾 Update the totals in viewCartData
    setState(() {
      viewCartData!.totals = Totals(
        currencySymbol: viewCartData!.totals?.currencySymbol ?? "\$",
        totalItems: subtotal.round().toString(),
        totalTax: tax.round().toString(),
        totalShipping: shipping.round().toString(),
        customerDiscountValue: discount.round().toString(),
        totalPrice: totalPrice.round().toString(),
      );

      if (removeCoupon) viewCartData!.coupons = [];
    });
    setState(() {
      totalamount1 = totalPrice.toString();

      log(
        "totalamounttotalamounttotalamounttotalamounttotalamount$totalamount",
      );
    });

    // 🗃️ Save updated cart in Hive
    var box = HiveService().getViewCartBox();
    await box.put('cart_$customerId', json.encode(viewCartData!.toJson()));

    log(
      "✅ Cart updated → subtotal=$subtotal discount=$discount totalPrice=$totalPrice",
    );
  }

  String? totalamount;
  String? totalamount1;

  Future<void> _fetchCart() async {
    var box = HiveService().getViewCartBox();

    // Helper to safely set couponController
    void updateCouponText() {
      final coupons = viewCartData?.coupons;
      couponController.text =
          (coupons != null && coupons.isNotEmpty)
              ? (coupons[0].code ?? "")
              : "";
    }

    // ✅ Offline mode
    if (!await checkInternet()) {
      final cachedData = box.get('cart_$customerId');

      if (cachedData != null && cachedData.toString().isNotEmpty) {
        try {
          final data = json.decode(cachedData);
          viewCartData = ViewCartDataModal.fromJson(data);

          if (mounted) updateCouponText();
        } catch (e) {
          log("Error decoding cached cart: $e");
          viewCartData = null;
        }
      } else {
        viewCartData = null;
        if (mounted) {
          showCustomErrorSnackbar(
            title: 'No Internet',
            message: 'Your cart is empty or offline data not found.',
          );
        }
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
          setState(() {
            final rawTotalItems = viewCartData?.totals?.totalItems;
            final rawDiscount = viewCartData?.totals?.customerDiscountValue;

            final totalItems =
                ((rawTotalItems is num)
                    ? rawTotalItems
                    : num.tryParse(rawTotalItems?.toString() ?? '')) ??
                0;

            final discount =
                ((rawDiscount is num)
                    ? rawDiscount
                    : num.tryParse(rawDiscount?.toString() ?? '')) ??
                0;

            final total = (totalItems as num) - (discount); // ✅ type-safe
            totalamount = total.toString();
          });

          if (mounted) updateCouponText();
          await box.put('cart_$customerId', response.body); // save raw JSON
        }
      } else {
        // fallback to cache
        final cachedData = box.get('cart_$customerId');
        if (cachedData != null && cachedData.toString().isNotEmpty) {
          final data = json.decode(cachedData);
          viewCartData = ViewCartDataModal.fromJson(data);
          setState(() {
            final rawTotalItems = viewCartData?.totals?.totalItems;
            final rawDiscount = viewCartData?.totals?.customerDiscountValue;

            final totalItems =
                ((rawTotalItems is num)
                    ? rawTotalItems
                    : num.tryParse(rawTotalItems?.toString() ?? '')) ??
                0;

            final discount =
                ((rawDiscount is num)
                    ? rawDiscount
                    : num.tryParse(rawDiscount?.toString() ?? '')) ??
                0;

            final total = (totalItems as num) - (discount); // ✅ type-safe
            totalamount = total.toString();
          });
          if (mounted) updateCouponText();
        } else {
          viewCartData = null;
        }
        if (mounted) {
          showCustomErrorSnackbar(
            title: 'Server Error',
            message: 'Something went wrong. Please try again later.',
          );
        }
      }
    } catch (e, stackTrace) {
      log("Error fetching cart: $stackTrace");

      // fallback to cache
      final cachedData = box.get('cart_$customerId');
      if (cachedData != null && cachedData.toString().isNotEmpty) {
        try {
          final data = json.decode(cachedData);
          viewCartData = ViewCartDataModal.fromJson(data);
          setState(() {
            final rawTotalItems = viewCartData?.totals?.totalItems;
            final rawDiscount = viewCartData?.totals?.customerDiscountValue;

            final totalItems =
                ((rawTotalItems is num)
                    ? rawTotalItems
                    : num.tryParse(rawTotalItems?.toString() ?? '')) ??
                0;

            final discount =
                ((rawDiscount is num)
                    ? rawDiscount
                    : num.tryParse(rawDiscount?.toString() ?? '')) ??
                0;

            final total = (totalItems as num) - (discount); // ✅ type-safe
            totalamount = total.toString();
          });
          if (mounted) updateCouponText();
        } catch (_) {
          viewCartData = null;
        }
      } else {
        viewCartData = null;
      }

      if (mounted) {
        showCustomErrorSnackbar(
          title: 'Network Error',
          message:
              'Unable to connect. Please check your internet and try again.',
        );
      }
    }
  }

  List<CouponListModal> couponslist = [];

  Future<void> _fetchCoupons() async {
    var box = HiveService().getCouponListBox();

    if (!await checkInternet()) {
      final cachedData = box.get('coupons');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        couponslist = data.map((e) => CouponListModal.fromJson(e)).toList();
      } else {
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
      }
      return;
    }

    try {
      final response = await CartService().couponsListApi();
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        couponslist = data.map((e) => CouponListModal.fromJson(e)).toList();

        // Save coupons to Hive
        await box.put('coupons', response.body);
      } else {
        // Fallback: load cache if server fails
        final cachedData = box.get('coupons');
        if (cachedData != null) {
          final List data = json.decode(cachedData);
          couponslist = data.map((e) => CouponListModal.fromJson(e)).toList();
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      // Fallback: load cache on network error
      final cachedData = box.get('coupons');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        couponslist = data.map((e) => CouponListModal.fromJson(e)).toList();
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }

  // void _showCouponDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             title: Text(
  //               "Available Coupons",
  //               style: TextStyle(
  //                 fontSize: 18.sp,
  //                 fontFamily: FontFamily.semiBold,
  //               ),
  //             ),
  //             content: SizedBox(
  //               width: double.maxFinite,
  //               child:
  //                   couponslist.isEmpty
  //                       ? Center(
  //                         child: Text(
  //                           "No Coupons Available",
  //                           style: TextStyle(
  //                             fontSize: 14.sp,
  //                             color: Colors.grey,
  //                           ),
  //                         ),
  //                       )
  //                       : SingleChildScrollView(
  //                         child: Column(
  //                           children: [
  //                             for (var coupon in couponslist)
  //                               Card(
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(12),
  //                                 ),
  //                                 child: ListTile(
  //                                   title: Text(
  //                                     coupon.code ?? "",
  //                                     style: TextStyle(
  //                                       fontFamily: FontFamily.semiBold,
  //                                     ),
  //                                   ),
  //                                   subtitle: Text(
  //                                     coupon.description ?? "",
  //                                     style: TextStyle(
  //                                       fontFamily: FontFamily.semiBold,
  //                                     ),
  //                                   ),
  //                                   trailing: TextButton(
  //                                     onPressed: () async {
  //                                       // set selected coupon into textfield
  //                                       setState(() {
  //                                         couponController.text =
  //                                             coupon.code ?? "";
  //                                         discount1 = double.parse(
  //                                           coupon.amount ?? "",
  //                                         );
  //                                         updateCartTotalsLocally(
  //                                           offlineDiscount: discount1,
  //                                         );
  //                                       });
  //                                       log("discount1=====>>>>>$discount1");
  //
  //                                       final cartService = CartService();
  //
  //                                       await cartService.applyCoupon(
  //                                         couponCode: couponController.text,
  //                                         onSuccess: () {
  //                                           log("API call successful");
  //
  //                                           WidgetsBinding.instance
  //                                               .addPostFrameCallback((_) {
  //                                                 Get.offAll(
  //                                                   () => CartScreen(),
  //                                                 );
  //                                                 _fetchCart();
  //                                               });
  //                                         },
  //                                       );
  //
  //                                       Navigator.pop(context);
  //                                     },
  //                                     child: Text(
  //                                       "Apply",
  //                                       style: TextStyle(
  //                                         color: AppColors.mainColor,
  //                                         fontFamily: FontFamily.semiBold,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                           ],
  //                         ),
  //                       ),
  //             ),
  //             actions: [
  //               ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: AppColors.mainColor,
  //                   padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //                 child: Text(
  //                   "Cancel",
  //                   style: TextStyle(
  //                     color: AppColors.whiteColor,
  //                     fontSize: 16.sp,
  //                     fontFamily: FontFamily.semiBold,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  TextEditingController couponController = TextEditingController();
  bool credit = false;
  bool proforma = false;
}
