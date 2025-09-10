import 'package:bellissemo_ecom/ui/cart/View/cartScreen.dart';
import 'package:bellissemo_ecom/ui/customers/view/customersScreen.dart';
import 'package:bellissemo_ecom/ui/home/view/homeScreen.dart';
import 'package:bellissemo_ecom/ui/orderhistory/view/orderHistoryScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/colors.dart';
import '../../../utils/fontFamily.dart';
import '../ui/category/view/categoryScreen.dart';
import 'cachedNetworkImage.dart';
import 'customButton.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7, // 70% width
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            color: AppColors.mainColor.withOpacity(0.1),
            child: Row(
              children: [
                CustomNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1633332755192-727a05c4013d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlcnxlbnwwfHwwfHx8MA%3D%3D',
                  height: 60,
                  width: 60,
                  isCircle: true,
                  isProfile: true,
                ),
                SizedBox(width: 3.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: FontFamily.bold,
                          color: AppColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'johndoe@example.com',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: FontFamily.light,
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                ),
                // Spacer(),
                // // Close button
                // IconButton(
                //   onPressed: widget.onClose,
                //   icon: Icon(Icons.close, size: 28, color: AppColors.blackColor),
                // ),
              ],
            ),
          ),
          SizedBox(height: 0.5.h),
          _drawerItem(Icons.home_outlined, "Home", () {
            Get.to(() => Homescreen());
          }),
          _drawerItem(Icons.shopping_bag_outlined, "Orders", () {
            Get.to(() => OrderHistoryScreen());
          }),
          _drawerItem(Icons.menu_book_outlined, "Catalog", () {
            Get.to(() => CategoriesScreen());
          }),
          _drawerItem(Icons.people_alt_outlined, "Customers", () {
            Get.to(() => CustomersScreen());
          }),
          _drawerItem(Icons.shopping_cart_outlined, "Cart", () {
            Get.to(() => CartScreen(customerName: ''));
          }),
          _drawerItem(Icons.person_outline, "Account", () {
            // navigate to Account screen if exists
          }),
          _drawerItem(Icons.settings_outlined, "Settings", () {
            // navigate to Settings screen if exists
          }),

          Spacer(),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: CustomButton(
              title: "Log Out",
              route: () {
                debugPrint("Log Out clicked");
              },
              color: AppColors.mainColor,
              fontcolor: AppColors.whiteColor,
              height: 6.h,
              width: double.infinity,
              fontsize: 18.sp,
              fontWeight: FontWeight.w400,
              radius: 3.w,
              iconData: Icons.logout,
              iconsize: 20.sp,
              shadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 1.w),
      child: ListTile(
        leading: Icon(icon, color: AppColors.mainColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: FontFamily.bold,
            color: AppColors.blackColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
