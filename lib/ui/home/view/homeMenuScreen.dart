import 'package:bellissemo_ecom/ui/cart/View/cartScreen.dart';
import 'package:bellissemo_ecom/ui/category/view/categoryScreen.dart';
import 'package:bellissemo_ecom/ui/customers/view/customersScreen.dart';
import 'package:bellissemo_ecom/ui/orderhistory/view/orderHistoryScreen.dart';
import 'package:bellissemo_ecom/ui/profile/view/profileScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/colors.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/customMenuDrawer.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/multipleImagesSlider.dart';
import '../../../utils/searchFields.dart';
import '../../reports/view/reportsScreen.dart';

class HomeMenuScreen extends StatefulWidget {
  const HomeMenuScreen({super.key});

  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyHome2 = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();
  final List<String> carouselImages = [
    'https://static.vecteezy.com/system/resources/thumbnails/004/707/493/small_2x/online-shopping-on-phone-buy-sell-business-digital-web-banner-application-money-advertising-payment-ecommerce-illustration-search-vector.jpg',
    'https://static.vecteezy.com/system/resources/previews/017/764/762/non_2x/banner-for-sale-people-rush-to-shop-with-bags-the-girl-runs-to-the-supermarket-young-people-with-bags-vector.jpg',
    'https://static.vecteezy.com/system/resources/thumbnails/004/707/493/small_2x/online-shopping-on-phone-buy-sell-business-digital-web-banner-application-money-advertising-payment-ecommerce-illustration-search-vector.jpg',
    'https://static.vecteezy.com/system/resources/previews/017/764/762/non_2x/banner-for-sale-people-rush-to-shop-with-bags-the-girl-runs-to-the-supermarket-young-people-with-bags-vector.jpg',
  ];

  bool searchBar = false;
  bool isDrawerOpen = false;
  bool isIpad = 100.w >= 800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyHome2,
      drawer: CustomDrawer(),
      backgroundColor: AppColors.containerColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
                color: AppColors.bgColor,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 6.5.h, right: 3.w, left: 3.w),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            _scaffoldKeyHome2.currentState?.openDrawer();
                          },
                          child: CircleAvatar(
                            radius: isIpad ? 40 : 20,
                            backgroundColor: AppColors.containerColor,
                            child: Icon(
                              CupertinoIcons.bars,
                              color: AppColors.blackColor,
                              size: isIpad ? 40 : 25,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Delivery address",
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: AppColors.gray,
                                fontFamily: FontFamily.light,
                              ),
                            ),
                            Text(
                              "92 High Street, London",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: FontFamily.bold,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  searchBar = !searchBar; // toggle visibility
                                });
                              },
                              child: CircleAvatar(
                                radius: isIpad ? 40 : 20,
                                backgroundColor: AppColors.containerColor,
                                child: Icon(
                                  Icons.search,
                                  color: AppColors.blackColor,
                                  size: isIpad ? 35 : 25,
                                ),
                              ),
                            ),
                            SizedBox(width: isIpad ? 2.w : 3.5.w),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  Get.offAll(
                                    CartScreen(),
                                    transition: Transition.fade,
                                    duration: const Duration(milliseconds: 450),
                                  );
                                });
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: isIpad ? 40 : 20,
                                    backgroundColor: AppColors.containerColor,
                                    child: Icon(
                                      Icons.shopping_cart_outlined,
                                      color: AppColors.blackColor,
                                      size: isIpad ? 35 : 25,
                                    ),
                                  ),
                                  // Positioned badge
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Container(
                                      padding: EdgeInsets.all(4.sp),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 14.sp,
                                        minHeight: 14.sp,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '2',
                                          // Replace with your cart count dynamically if needed
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: isIpad ? 2.w : 3.5.w),
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: isIpad ? 40 : 20,
                                  backgroundColor: AppColors.containerColor,
                                  child: Icon(
                                    Icons.notifications_none,
                                    color: AppColors.blackColor,
                                    size: isIpad ? 35 : 25,
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: CircleAvatar(
                                    radius: isIpad ? 10 : 6,
                                    backgroundColor: AppColors.counterColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    if (searchBar)
                      SearchField(
                        controller: searchController,
                        hintText: "Search the entire shop",
                      ),
                    SizedBox(height: 1.h),

                    ImageSlider(imageUrls: carouselImages, height: 18.h),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),

            SizedBox(height: 2.h),

            Expanded(
              child: Container(
                height: Device.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                  ),
                  color: AppColors.bgColor,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: isIpad ? 0.h : 2.5.h,
                    right: 4.w,
                    left: 4.w,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: Device.width,
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40),
                            topLeft: Radius.circular(40),
                          ),
                          color: AppColors.bgColor,
                        ),
                        child: Wrap(
                          spacing: 0.w,
                          runSpacing: 3.h,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildMenuItem(
                              Icons.shopping_bag_outlined,
                              "Order",
                              Colors.orange,
                              Colors.deepOrangeAccent,
                            ),
                            _buildMenuItem(
                              Icons.menu_book_outlined,
                              "Catalog",
                              Colors.blue,
                              Colors.indigo,
                            ),
                            _buildMenuItem(
                              Icons.people_alt_outlined,
                              "Customer",
                              Colors.green,
                              Colors.teal,
                            ),
                            _buildMenuItem(
                              Icons.shopping_cart_outlined,
                              "Cart",
                              Colors.pink,
                              Colors.purple,
                            ),
                            _buildMenuItem(
                              Icons.area_chart_rounded,
                              "Report",
                              Colors.pink,
                              Colors.purple,
                            ),
                            _buildMenuItem(
                              Icons.person_outline,
                              "Account",
                              Colors.amber,
                              Colors.redAccent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: isIpad ? 14.h : 10.h,
        child: CustomBar(selected: 3),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Color startColor,
    Color endColor,
  ) {
    // Calculate total horizontal spacing and divide by 3
    double totalSpacing = 2 * 4.w; // Two gaps between three items
    double itemWidth = (100.w - totalSpacing) / 3;

    return SizedBox(
      width: itemWidth,
      child: GestureDetector(
        onTap: () {
          switch (title) {
            case "Order":
              Get.to(() => OrderHistoryScreen());
              break;
            case "Catalog":
              Get.to(() => CategoriesScreen());
              break;
            case "Customer":
              Get.to(() => CustomersScreen());
              break;
            case "Cart":
              Get.to(() => CartScreen());
              break;
            case "Report":
              Get.to(() => ReportScreen());
              break;
            case "Account":
              Get.to(() => ProfileScreen());
              break;
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(15.sp),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                border: Border.all(color: AppColors.mainColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainColor.withOpacity(0.15),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 20.sp, color: AppColors.mainColor),
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: FontFamily.semiBold,
                color: AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
