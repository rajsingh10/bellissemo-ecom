import 'package:bellissemo_ecom/ui/orderhistory/view/orderhistoryDetailsScreen.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/colors.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/customButton.dart';
import '../../../utils/searchFields.dart';
import '../../../utils/titlebarWidget.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();

  String selectedSort = "Newest First";

  final List<String> sortOptions = [
    "Newest First",
    "Oldest First",
    "Price: Low to High",
    "Price: High to Low",
  ];


  final List<Order> orders = [
    Order(
      id: "001",
      date: "May 07, 2025",
      status: "Delivered",
      price: 39.99,
      items: [
        OrderItem(
          name: "Green Controller",
          imageUrl: "https://m.media-amazon.com/images/I/71hUeZd546L._UF1000,1000_QL80_.jpg",
          price: 25.00,
          qty: 1,
        ),
        OrderItem(
          name: "Black Smartwatch",
          imageUrl: "https://m.media-amazon.com/images/I/51uTj0beKCL._UF1000,1000_QL80_.jpg",
          price: 14.99,
          qty: 2,
        ),
      ],
    ),
    Order(
      id: "002",
      date: "May 06, 2025",
      status: "Pending",
      price: 12.50,
      items: [
        OrderItem(
          name: "Lipstick Kit",
          imageUrl: "https://m.media-amazon.com/images/I/51uTj0beKCL._UF1000,1000_QL80_.jpg",
          price: 12.50,
          qty: 1,
        ),
      ],
    ),
  ];

  void sortOrders(String option) {
    setState(() {
      selectedSort = option;
      if (option == "Newest First") {
        orders.sort((a, b) => b.date.compareTo(a.date));
      } else if (option == "Oldest First") {
        orders.sort((a, b) => a.date.compareTo(b.date));
      } else if (option == "Price: Low to High") {
        orders.sort((a, b) => a.price.compareTo(b.price));
      } else if (option == "Price: High to Low") {
        orders.sort((a, b) => b.price.compareTo(a.price));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          TitleBar(
            title: 'Order History',
            isDrawerEnabled: true,
            isSearchEnabled: true,
            onSearch: () {
              setState(() {
                isSearchEnabled = !isSearchEnabled;
              });
            },
          ),
          if (isSearchEnabled) SearchField(controller: searchController),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
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
                      "${orders.length} Items", // Show total items dynamically
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
                      Text("Sort By ",  style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: FontFamily.semiBold,
                        color: AppColors.blackColor,
                      ),),
                      SizedBox(width: 3.w,),
                      DropdownButtonHideUnderline(  // <-- Wrap to remove underline
                        child: DropdownButton<String>(
                          value: selectedSort,
                          icon: Icon(
                            Icons.sort,
                            color: AppColors.mainColor,
                          ),
                          items: sortOptions
                              .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(option,style: TextStyle(
                              fontSize: 15.sp,
                              fontFamily: FontFamily.semiBold,
                              color: AppColors.mainColor,
                            ),),
                          ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) sortOrders(value);
                          },
                        ),
                      ),
                    ],
                  )),
            ],
          ),

          SizedBox(height: 1.h),
          Expanded(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                children: [
                  for (var order in orders)
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
                          tilePadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: AppColors.whiteColor,
                          // collapsedBackgroundColor: AppColors.whiteColor,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: order.status == "Delivered"
                                          ? AppColors.greenColor.withOpacity(0.1)
                                          : order.status == "Pending"
                                          ? AppColors.orangeColor.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      order.status,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontFamily.bold,
                                        color: order.status == "Delivered"
                                            ? AppColors.greenColor
                                            : order.status == "Pending"
                                            ? AppColors.orangeColor
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    order.date,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: AppColors.gray,
                                      fontFamily: FontFamily.bold
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            Column(
                              children: [
                                for (var item in order.items)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            item.imageUrl,
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontFamily: FontFamily.semiBold,
                                                  color: AppColors.blackColor,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              Text(
                                                "Qty: ${item.qty}  •  \$${item.price.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: AppColors.gray,
                                                  fontFamily: FontFamily.semiBold
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Divider(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Total:",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontFamily.bold,
                                          )),
                                      Text("\$${order.price.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontFamily.bold,
                                            color: AppColors.blackColor,
                                          )),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 0.5.h),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: CustomButton(
                                      title: "Get Invoice",
                                      route: () {
                                        print("Get Invoice tapped");
                                      },
                                      color: AppColors.mainColor,           // Transparent background
                                      fontcolor: AppColors.whiteColor,     // Text color
                                      height: 5.h,
                                      width: double.infinity,                         // Adjust width for spacing
                                      fontsize: 16.sp,
                                      radius: 12.0,
                                      // No border
                                    ),
                                  ),
                                ),
                                SizedBox(height: 1.5.h,)

                                // Padding(
                                //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       CustomButton(
                                //         title: "Get Invoice",
                                //         route: () {
                                //           print("Get Invoice tapped");
                                //         },
                                //         color: AppColors.mainColor,           // Transparent background
                                //         fontcolor: AppColors.whiteColor,     // Text color
                                //         height: 5.h,
                                //         width: 40.w,                         // Adjust width for spacing
                                //         fontsize: 16.sp,
                                //         radius: 12.0,
                                //             // No border
                                //       ),
                                //       CustomButton(
                                //         title: "Edit order",
                                //         route: () {
                                //           print("Edit order tapped");
                                //         },
                                //         color: AppColors.mainColor,
                                //         fontcolor: AppColors.whiteColor,
                                //         height: 5.h,
                                //         width: 40.w,
                                //         fontsize: 16.sp,
                                //         radius: 12.0,
                                //
                                //       ),
                                //     ],
                                //   ),
                                // ),



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
        height: 10.h,
        child: CustomBar(selected: 2),
      ),
    );
  }
}

class Order {
  final String id;
  final String date;
  final String status;
  final double price;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.date,
    required this.status,
    required this.price,
    required this.items,
  });
}

class OrderItem {
  final String name;
  final String imageUrl;
  final double price;
  final int qty;

  OrderItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.qty,
  });
}