import 'package:bellissemo_ecom/utils/customButton.dart';
import 'package:bellissemo_ecom/utils/customMenuDrawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/colors.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/titlebarWidget.dart';

class CheckOutScreen extends StatefulWidget {
  String? CustomerName;

  CheckOutScreen({super.key, required this.CustomerName});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final List<Product> products = [
    Product(
      name: "Maybelline Lip Liner",
      imageUrl:
          "https://m.media-amazon.com/images/I/71Y+L4lMHWL._UF1000,1000_QL80_.jpg",
      quantity: 1,
      price: 19.99,
    ),
    Product(
      name: "Revlon Face Powder",
      imageUrl:
          "https://m.media-amazon.com/images/I/71JgzO1Pp5L._UF1000,1000_QL80_.jpg",
      quantity: 1,
      price: 79.99,
    ),
  ];

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
                            widget.CustomerName ?? '',
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

                              Icon(
                                Icons.edit_rounded,
                                size: 20.sp,
                                color: AppColors.mainColor,
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

                          for (var product in products) ...[
                            Row(
                              children: [
                                // Using CustomNetworkImage
                                CustomNetworkImage(
                                  imageUrl: product.imageUrl,
                                  width: 20.w,
                                  height: 10.h,
                                  radius: 8,
                                  isFit: true,
                                ),
                                SizedBox(width: 3.w),
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontFamily: FontFamily.semiBold,
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        "Qty: ${product.quantity}",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: FontFamily.regular,
                                          color: AppColors.gray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Product Price
                                Text(
                                  "\$${(product.price * product.quantity).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: FontFamily.semiBold,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Divider(),
                          ],
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
                                "\$150.00 ",
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
                                  color: AppColors.gray,
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                              Text(
                                "\$5.00 ",
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tax",
                                style: TextStyle(
                                  color: AppColors.gray,
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                              Text(
                                "\$0.00",
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 18.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                              Text(
                                "\$155.00",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 18.sp,
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
}

class Product {
  final String name;
  final String imageUrl;
  final int quantity;
  final double price;

  Product({
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });
}
