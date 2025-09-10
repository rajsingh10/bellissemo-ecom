import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/colors.dart';
import '../../../utils/titlebarWidget.dart';

class OrderhistoryDetailsScreen extends StatefulWidget {
  const OrderhistoryDetailsScreen({super.key});

  @override
  State<OrderhistoryDetailsScreen> createState() =>
      _OrderhistoryDetailsScreenState();
}

class _OrderhistoryDetailsScreenState extends State<OrderhistoryDetailsScreen> {
  final List<Product> products = [
    Product(
      name: "L'Oreal Paris Lipstick",
      imageUrl:
          'https://static.beautytocare.com/media/catalog/product/l/-/l-oreal-paris-color-riche-intense-volume-matte-lipstick-480.jpg',
      packSize: "Pack of 3",
      pricePerUnit: 29.0,
      inStock: true,
    ),
    Product(
      name: "Maybelline Foundation",
      imageUrl:
          'https://m.media-amazon.com/images/I/51uTj0beKCL._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 2",
      pricePerUnit: 35.0,
      inStock: true,
    ),
    Product(
      name: "Revlon Nail Polish",
      imageUrl: 'https://m.media-amazon.com/images/I/41qteOLxDHL.jpg',
      packSize: "Pack of 5",
      pricePerUnit: 25.0,
      inStock: true,
    ),
    Product(
      name: "Nykaa Kajal",
      imageUrl:
          'https://m.media-amazon.com/images/I/719eSwDuU7L._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 4",
      pricePerUnit: 15.0,
      inStock: true,
    ),
    Product(
      name: "Lakme Blush",
      imageUrl:
          'https://m.media-amazon.com/images/I/71+yE3132GL._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 4",
      pricePerUnit: 35.0,
      inStock: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          TitleBar(
            title: 'Order Detail',
            isDrawerEnabled: true,
            isSearchEnabled: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order ID: #123456",
                          style: TextStyle(
                            fontFamily: FontFamily.bold,

                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "Order Date: 08-09-2025",
                          style: TextStyle(
                            fontFamily: FontFamily.regular,
                            fontSize: 16.sp,
                            color: AppColors.gray,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Status: Delivered",
                          style: TextStyle(
                            fontFamily: FontFamily.bold,
                            fontSize: 16.sp,
                            color: AppColors.greenColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Shipping Address",
                          style: TextStyle(
                            fontFamily: FontFamily.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "John Doe\n123, Main Street\nSurat, Gujarat\nIndia - 395001",
                          style: TextStyle(
                            fontFamily: FontFamily.regular,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Order Items
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "5 Item(s)",
                          style: TextStyle(
                            fontFamily: FontFamily.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        for (
                          int index = 0;
                          index < products.length;
                          index++
                        ) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomNetworkImage(
                                imageUrl: products[index].imageUrl,
                                height: 8.h,
                                width: 8.h,
                                radius: 8,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      products[index].name,
                                      style: TextStyle(
                                        fontFamily: FontFamily.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "${products[index].packSize} | ₹${products[index].pricePerUnit.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontFamily: FontFamily.regular,
                                        fontSize: 16.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (!products[index].inStock)
                                      Text(
                                        "Out of Stock",
                                        style: TextStyle(
                                          fontFamily: FontFamily.regular,
                                          fontSize: 16.sp,
                                          color: Colors.red,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (index != products.length - 1) Divider(),
                          // Divider except last
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Price Summary
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Price Summary",
                          style: TextStyle(
                            fontFamily: FontFamily.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Subtotal",
                              style: TextStyle(
                                fontFamily: FontFamily.regular,
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              "₹139",
                              style: TextStyle(
                                fontFamily: FontFamily.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Shipping",
                              style: TextStyle(
                                fontFamily: FontFamily.regular,
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              "₹50",
                              style: TextStyle(
                                fontFamily: FontFamily.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 20, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(
                                fontFamily: FontFamily.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              "₹189",
                              style: TextStyle(
                                fontFamily: FontFamily.bold,
                                fontSize: 16.sp,
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
      ),
    );
  }
}

class Product {
  final String name;
  final String imageUrl;
  final String packSize;
  var pricePerUnit;
  bool inStock;
  int quantity;

  Product({
    required this.name,
    required this.imageUrl,
    required this.packSize,
    required this.pricePerUnit,
    this.inStock = true,
    this.quantity = 0,
  });
}
