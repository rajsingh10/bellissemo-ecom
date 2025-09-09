import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/colors.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/titlebarWidget.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final List<Product> products = [
    Product(
      name: "Maybelline Lip Liner",
      imageUrl: "https://m.media-amazon.com/images/I/71Y+L4lMHWL._UF1000,1000_QL80_.jpg",
      quantity: 1,
      price:19.99,
    ),
    Product(
      name: "Revlon Face Powder",
      imageUrl: "https://m.media-amazon.com/images/I/71JgzO1Pp5L._UF1000,1000_QL80_.jpg",
      quantity: 1,
      price:  79.99,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerColor,
      body: Column(
        children: [
          TitleBar(title: 'Chekout', isDrawerEnabled: false,
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
                          Text(
                            "Products",
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 18.sp,
                              fontFamily: FontFamily.semiBold,
                            ),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          ]
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
                          Text(
                            "Order Summary",
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 18.sp,
                              fontFamily: FontFamily.semiBold,
                            ),
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
                                  color: AppColors.blackColor,
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                              Text(
                                "\$5.00 ",
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
                                "\$0.00",
                                style: TextStyle(
                                  color: AppColors.blackColor,
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
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                              Text(
                                "\$155.00",
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
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Please confirm and submit your order",
                    style: TextStyle(
                      fontFamily: FontFamily.bold,
                      fontSize: 16.sp,
                      color: AppColors.blackColor,
                    ),
                  ),

                  Text(
                    "By clicking submit order,you agree to Terms of Use and Privacy Poilicy",
                    style: TextStyle(
                      fontFamily: FontFamily.regular,
                      fontSize: 16.sp,
                      color: AppColors.gray,

                    ),
                  ),
                  SizedBox(height: 1.h,),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Shipping Address",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 18.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),

                              Container(
                                width: 15.w,
                                height: 3.h,
                                // padding: EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(
                                      color: AppColors.whiteColor,
                                      fontSize: 14.sp,
                                      fontFamily: FontFamily.semiBold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "117 Albany Gardens,\nCO28HQ\nColchester\nEssex\nUnited Kingdom",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),

                            ],
                          ),
                          SizedBox(height: 1.h),
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
        height: 7.h,
        child: InkWell(
          onTap: () {
            Get.offAll(
                  () => CheckOutScreen(),
              transition: Transition.fade,
              duration: const Duration(milliseconds: 450),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.mainColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "Submit Order",
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 18.sp,
                  fontFamily: FontFamily.semiBold,
                ),
              ),
            ),
          ),
        ),
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

