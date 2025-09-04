import 'dart:async';
import 'dart:ui';

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
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  bool searchBar = false;


  final List<String> carouselImages = [
    'https://static.vecteezy.com/system/resources/thumbnails/004/707/493/small_2x/online-shopping-on-phone-buy-sell-business-digital-web-banner-application-money-advertising-payment-ecommerce-illustration-search-vector.jpg',
    'https://static.vecteezy.com/system/resources/previews/017/764/762/non_2x/banner-for-sale-people-rush-to-shop-with-bags-the-girl-runs-to-the-supermarket-young-people-with-bags-vector.jpg',
    'https://static.vecteezy.com/system/resources/thumbnails/004/707/493/small_2x/online-shopping-on-phone-buy-sell-business-digital-web-banner-application-money-advertising-payment-ecommerce-illustration-search-vector.jpg',
    'https://static.vecteezy.com/system/resources/previews/017/764/762/non_2x/banner-for-sale-people-rush-to-shop-with-bags-the-girl-runs-to-the-supermarket-young-people-with-bags-vector.jpg',
  ];

  final List<Map<String, dynamic>> orders = [
    {
      "name": "Wireless Earbuds",
      "desc": "Bluetooth 5.0, Noise Cancelling",
      "price": 49.99,
      "rating": 4.6,
      "image":
      "https://images.unsplash.com/photo-1585386959984-a4155223f8d6?w=500",
    },
    {
      "name": "Smart Watch",
      "desc": "Fitness Tracker, Heart Rate Monitor",
      "price": 89.50,
      "rating": 4.3,
      "image":
      "https://images.unsplash.com/photo-1511732351157-1865efcb7b7b?w=500",
    },
    {
      "name": "Gaming Mouse",
      "desc": "RGB Lighting, Ergonomic Design",
      "price": 39.99,
      "rating": 4.7,
      "image":
      "https://images.unsplash.com/photo-1587202372775-9897e2c75c3a?w=500",
    },
    {
      "name": "Running Shoes",
      "desc": "Lightweight, Breathable",
      "price": 65.00,
      "rating": 4.4,
      "image":
      "https://images.unsplash.com/photo-1606813902794-99d7c92f22f3?w=500",
    },
    {
      "name": "Laptop Backpack",
      "desc": "Waterproof, USB Charging Port",
      "price": 55.75,
      "rating": 4.5,
      "image":
      "https://images.unsplash.com/photo-1598032895661-2d6a14e1e1e6?w=500",
    },
  ];
  final List<Map<String, dynamic>> recentOrders = [
    { "orderNumber": "#1001",
      "name": "Nike Air",
      "image":
      "https://d2v5dzhdg4zhx3.cloudfront.net/web-assets/images/storypages/primary/ProductShowcasesampleimages/JPEG/Product+Showcase-1.jpg",
      "price": 120.0,
      "quantity": 1,
      "date": "2025-09-01",
    },
    {"orderNumber": "#1002",
      "name": "Sony",
      "image":
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkn0TdZw5jr0EOj9fdbG3RwmoSzJtpoN8g_Q&s",
      "price": 75.5,
      "quantity": 2,
      "date": "2025-08-28",
    },
    {"orderNumber": "#1003",
      "name": "Nike Air",
      "image":
      "https://d2v5dzhdg4zhx3.cloudfront.net/web-assets/images/storypages/primary/ProductShowcasesampleimages/JPEG/Product+Showcase-1.jpg",
      "price": 120.0,
      "quantity": 3,
      "date": "2025-08-20",
    },
    {"orderNumber": "#1004",
      "name": "Sony",
      "image":
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkn0TdZw5jr0EOj9fdbG3RwmoSzJtpoN8g_Q&s",
      "price": 80.0,
      "quantity": 1,
      "date": "2025-08-15",
    },
  ];
  final List<Map<String, String>> items = [
    {"title": "Laporan Meter Rusak"},
    {"title": "Tagihan Belum Bayar"},
    {"title": "Pengajuan Baru"},
    {"title": "Riwayat Penggunaan"},
  ];



  final List<Map<String, String>> users = [
    {"name": "Nike Air", "image": "https://d2v5dzhdg4zhx3.cloudfront.net/web-assets/images/storypages/primary/ProductShowcasesampleimages/JPEG/Product+Showcase-1.jpg"},
    {"name": "Sony", "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkn0TdZw5jr0EOj9fdbG3RwmoSzJtpoN8g_Q&s"},
    {"name": "Nike Air", "image": "https://d2v5dzhdg4zhx3.cloudfront.net/web-assets/images/storypages/primary/ProductShowcasesampleimages/JPEG/Product+Showcase-1.jpg"},
    {"name": "Sony", "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkn0TdZw5jr0EOj9fdbG3RwmoSzJtpoN8g_Q&s"},
    {"name": "Nike Air", "image": "https://d2v5dzhdg4zhx3.cloudfront.net/web-assets/images/storypages/primary/ProductShowcasesampleimages/JPEG/Product+Showcase-1.jpg"},
    {"name": "Sony", "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkn0TdZw5jr0EOj9fdbG3RwmoSzJtpoN8g_Q&s"},
    {"name": "Nike Air", "image": "https://d2v5dzhdg4zhx3.cloudfront.net/web-assets/images/storypages/primary/ProductShowcasesampleimages/JPEG/Product+Showcase-1.jpg"},
    {"name": "Sony", "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkn0TdZw5jr0EOj9fdbG3RwmoSzJtpoN8g_Q&s"},
  ];

  final List<Map<String, String>> products = [];
  final int itemsPerPage = 12;
  int currentPage = 0;

  void initProducts() {
    for (int i = 0; i < 24; i++) {
      products.add({
        "image": "https://picsum.photos/200?random=$i",
        "name": "Product ${i + 1}",
        "price": "\$${(i + 1) * 10}",
        "cancelPrice": "\$${(i + 1) * 12}",
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initProducts();
    _pageController = PageController();

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentIndex < carouselImages.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }



  List<Map<String, String>> get currentProducts {
    int startIndex = currentPage * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > products.length) endIndex = products.length;
    return products.sublist(startIndex, endIndex);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKeyHome,
      backgroundColor: AppColors.containerColor,
      body: SingleChildScrollView(
       physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
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
                              color: AppColors.whiteColor,
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
                              SizedBox(width: 3.5.w),
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
                            PageView.builder(
                              controller: _pageController,
                              itemCount: carouselImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      carouselImages[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // // Indicators
                            // Positioned(
                            //   bottom: 8,
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       for (int i = 0; i < carouselImages.length; i++)
                            //         Container(
                            //           margin: const EdgeInsets.symmetric(
                            //             horizontal: 3,
                            //           ),
                            //           width: currentIndex == i ? 12 : 8,
                            //           height: currentIndex == i ? 12 : 8,
                            //           decoration: BoxDecoration(
                            //             shape: BoxShape.circle,
                            //             color:
                            //                 currentIndex == i
                            //                     ? AppColors.mainColor
                            //                     : Colors.grey[400],
                            //           ),
                            //         ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),

                      SizedBox(height: 2.h),
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
                child: Padding(
                  padding: EdgeInsets.only(top: 2.5.h, right: 4.w, left: 4.w),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              SizedBox(width: 1.w,),
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: AppColors.mainColor,
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.whiteColor,
                                  size: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h,),

                       SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child:  Row(
                            children: [
                              for (int i = 0; i < recentOrders.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(top: 40,left:6,right:6,bottom:12),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [


                                      // Main Card
                                      Container(
                                        width: 35.w,
                                        height: 22.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: AppColors.whiteColor,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.containerColor,
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 25, left: 12, right: 12, bottom: 12),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                recentOrders[i]["name"],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontFamily: FontFamily.bold,
                                                  color: AppColors.mainColor,
                                                ),
                                              ),
                                              Text(
                                                recentOrders[i]["orderNumber"],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontFamily: FontFamily.bold,
                                                  color: AppColors.mainColor,
                                                ),
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                "Qty: ${recentOrders[i]["quantity"]}",
                                                style: TextStyle(color: AppColors.blackColor,fontFamily: FontFamily.semiBold,fontSize: 16.sp),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "\$${recentOrders[i]["price"].toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  fontFamily: FontFamily.semiBold,
                                                  fontSize: 16.sp,
                                                  color: AppColors.blackColor,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                recentOrders[i]["date"],
                                                style: TextStyle(color: AppColors.gray,fontSize: 16.sp,fontFamily: FontFamily.semiBold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Circle Image Positioned Above
                                      Positioned(
                                        top: -40, // Half outside card
                                        left: 25,
                                        child: Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.whiteColor,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                            image: DecorationImage(
                                              image: NetworkImage(recentOrders[i]["image"]),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      SizedBox(height: 1.h,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Catalog",
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
                              SizedBox(width: 1.w,),
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: AppColors.mainColor,
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.whiteColor,
                                  size: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h,),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: currentProducts.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.80,
                        ),
                        itemBuilder: (context, index) {
                          final product = currentProducts[index];
                          int quantity = 1;

                          return Container(
                            width: 30.w,
                            height: 10.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.whiteColor,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.containerColor,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Image with overlay icon
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          child: CustomNetworkImage(
                                            imageUrl: product["image"]!,
                                            height: 100,
                                            width: double.infinity,
                                            radius: 20,
                                          ),
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 1.h),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            product["name"]!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: FontFamily.bold,
                                              fontSize: 18.sp,
                                              color: AppColors.blackColor
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                    // SizedBox(height: 0.5.h),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            product["price"]!,
                                            style: TextStyle(
                                              color: AppColors.mainColor,
                                              fontFamily: FontFamily.bold,
                                              fontSize: 16.sp
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            product["cancelPrice"]!,
                                            style: TextStyle(
                                              color: AppColors.gray,
                                              decoration: TextDecoration.lineThrough,
                                              fontFamily: FontFamily.semiBold,fontSize: 15.sp

                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // SizedBox(height: 0.5.h,),
                                    // Counter + Add to Cart
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Counter
                                          Container(
                                            decoration: BoxDecoration(
                                              color:AppColors.mainColor,
                                              borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (quantity > 1) setState(() => quantity--);
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                    child: Icon(Icons.remove, size: 18,
                                                        color: AppColors.whiteColor),
                                                  ),
                                                ),
                                                Text(
                                                  quantity.toString(),
                                                  style: TextStyle(fontWeight: FontWeight.bold,
                                                  color: AppColors.whiteColor
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() => quantity++);
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                    child: Icon(Icons.add, size: 18,
                                                        color: AppColors.whiteColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Add to Cart Button
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              // gradient: LinearGradient(
                                              //   colors: [Colors.orangeAccent, Colors.deepOrange],
                                              // ),

                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(20),
                                                bottomRight: Radius.circular(40),
                                              ),
                                              color: AppColors.mainColor
                                            ),
                                            child: Icon(Icons.shopping_cart_outlined, color: AppColors.whiteColor, size: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // Optional: discount badge
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(40),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      "-10%",
                                      style: TextStyle(color: AppColors.whiteColor, fontSize: 15.sp),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 1.h,),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
