import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/colors.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/titlebarWidget.dart';

class CartScreen extends StatefulWidget {
  final String customerName;

  const CartScreen({super.key, required this.customerName});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();

  List<bool> selectedItems = List.generate(5, (_) => false);
  bool selectAll = false;

  List<Map<String, dynamic>> cartItems = [
    {
      "image":
          "https://m.media-amazon.com/images/I/71Y+L4lMHWL._UF1000,1000_QL80_.jpg",
      // replace with actual asset/network
      "title": "Maybelline Lip Liner",
      "price": 19.99,
      "qty": 1,
    },
    {
      "image":
          "https://m.media-amazon.com/images/I/71JgzO1Pp5L._UF1000,1000_QL80_.jpg",
      "title": "Revlon Face Powder",
      "price": 79.99,
      "qty": 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    double subtotal = 0;
    for (var item in cartItems) {
      subtotal += item["price"] * item["qty"];
    }
    double shipping = 5.0;
    double tax = subtotal * 0.1;
    return Scaffold(
      backgroundColor: AppColors.containerColor,
      body: Column(
        children: [
          TitleBar(
            title: 'Cart',
            isDrawerEnabled: true,
            isSearchEnabled: true,
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
                          Row(
                            children: [
                              Text(
                                "${widget.customerName}!",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 18.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                              Text(
                                " (2 items)",
                                style: TextStyle(
                                  color: AppColors.mainColor,
                                  fontSize: 18.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Column(
                            children: [
                              for (int i = 0; i < cartItems.length; i++)
                                Column(
                                  children: [
                                    Container(
                                      // margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor,
                                        borderRadius: BorderRadius.circular(15),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: CustomNetworkImage(
                                              imageUrl: cartItems[i]["image"],
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
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cartItems[i]["title"],
                                                  style: TextStyle(
                                                    fontFamily: FontFamily.bold,
                                                    fontSize: 15.sp,
                                                    color: AppColors.blackColor,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 0.5.h),

                                                IntrinsicWidth(
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 2.w,
                                                          vertical: 0.5.h,
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
                                                          onTap:
                                                              cartItems[i]["qty"] >
                                                                      1
                                                                  ? () {
                                                                    setState(() {
                                                                      cartItems[i]["qty"]--;
                                                                    });
                                                                  }
                                                                  : null,
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
                                                              Icons.remove,
                                                              size: 16.sp,
                                                              color:
                                                                  AppColors
                                                                      .blackColor,
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(width: 2.w),

                                                        // Quantity text
                                                        Text(
                                                          cartItems[i]["qty"]
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                            fontFamily:
                                                                FontFamily
                                                                    .semiBold,
                                                            color:
                                                                AppColors
                                                                    .blackColor,
                                                          ),
                                                        ),

                                                        SizedBox(width: 2.w),

                                                        // Increase
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              cartItems[i]["qty"]++;
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
                                                              size: 16.sp,
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
                                                    cartItems.removeAt(i);
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                    1.5.w,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.mainColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    color: AppColors.whiteColor,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 2.h),
                                              Text(
                                                "\$ ${cartItems[i]["price"].toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  color: AppColors.blackColor,
                                                  fontSize: 14.sp,
                                                  fontFamily:
                                                      FontFamily.semiBold,
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
                        Text(
                          "Summary Order",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 18.sp,
                            fontFamily: FontFamily.semiBold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Enter Discount Code",
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
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
                                  borderRadius: BorderRadius.circular(8),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Subtotal",
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16.sp,
                                fontFamily: FontFamily.semiBold,
                              ),
                            ),
                            Text(
                              "\$ ${subtotal.toStringAsFixed(2)}",
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Shipping",
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16.sp,
                                fontFamily: FontFamily.semiBold,
                              ),
                            ),
                            Text(
                              "\$ ${shipping.toStringAsFixed(2)}",
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tax",
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16.sp,
                                fontFamily: FontFamily.semiBold,
                              ),
                            ),
                            Text(
                              "\$ ${tax.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16.sp,
                                fontFamily: FontFamily.semiBold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16.sp,
                                fontFamily: FontFamily.semiBold,
                              ),
                            ),
                            Text(
                              "\$ ${(subtotal + shipping + tax).toStringAsFixed(2)}",
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16.sp,
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
                        fontSize: 15.sp,
                        fontFamily: FontFamily.semiBold,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "\$ ${(subtotal + shipping + tax).toStringAsFixed(2)}",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16.sp,
                        fontFamily: FontFamily.semiBold,
                      ),
                    ),
                  ],
                ),

                // Checkout Button
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: ElevatedButton(
                      onPressed: () {
                        // Add checkout logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Checkout",
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 16.sp,
                          fontFamily: FontFamily.semiBold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h, child: CustomBar(selected: 1)),
        ],
      ),
    );
  }
}
