import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/searchFields.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyHome = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();

  bool searchBar = false;

  int currentIndex = 0;
  final List<String> carouselImages = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
    'assets/images/banner4.png',
    'assets/images/banner5.jpg',
  ];

  final List<Map<String, String>> users = [
    {"name": "Alice", "image": "https://i.pravatar.cc/150?img=1"},
    {"name": "Bob", "image": "https://i.pravatar.cc/150?img=2"},
    {"name": "Charlie", "image": "https://i.pravatar.cc/150?img=3"},
    {"name": "David", "image": "https://i.pravatar.cc/150?img=4"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyHome,
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
                padding: EdgeInsets.only(top: 6.5.h, right: 2.w, left: 2.w),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.mainColor,
                          child: Icon(
                            Icons.settings,
                            color: AppColors.blackColor,
                            size: 20,
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
                                radius: 18,
                                backgroundColor: AppColors.containerColor,
                                child: Icon(
                                  Icons.search,
                                  color: AppColors.blackColor,
                                  size: 22,
                                ),
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.containerColor,
                                  child: Icon(
                                    Icons.notifications_none,
                                    color: AppColors.blackColor,
                                    size: 22,
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: CircleAvatar(
                                    radius: 4,
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

                    SizedBox(
                      height: 20.h,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          PageView(
                            onPageChanged: (index) {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                            children: [
                              for (int i = 0; i < carouselImages.length; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ), // space between images
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      carouselImages[i],
                                      height: 20.h,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Indicators
                          Positioned(
                            bottom: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int i = 0; i < carouselImages.length; i++)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: currentIndex == i ? 12 : 8,
                                    height: currentIndex == i ? 12 : 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          currentIndex == i
                                              ? AppColors.mainColor
                                              : Colors.grey[400],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 1.h),
                  ],
                ),
              ),
            ),

            SizedBox(height: 2.h),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
                color: AppColors.bgColor,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.only(top: 6.5.h, right: 2.w, left: 2.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Recent Orders",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: FontFamily.bold,
                              color: AppColors.blackColor,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "View All",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.bold,
                                  color: AppColors.gray,
                                ),
                              ),
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.mainColor,
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: AppColors.blackColor,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Reverse for loop
                          for (int i = users.length - 1; i >= 0; i--)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Column(
                                children: [
                                  // Circular image
                                  CustomNetworkImage(
                                    imageUrl: users[i]["image"]!,
                                    width: 70,
                                    height: 70,
                                    radius: 35,
                                    isProfile: true,
                                  ),
                                  SizedBox(height: 8),
                                  // Name below image
                                  Text(users[i]["name"]!),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
