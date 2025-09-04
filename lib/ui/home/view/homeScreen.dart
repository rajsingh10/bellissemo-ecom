import 'dart:async';

import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/multipleImagesSlider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/searchFields.dart';
import '../../products/view/productDetailsScreen.dart';
import '../../products/view/productsScreen.dart';

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
    Product(
      name: "Huda Beauty Eyeshadow Palette",
      imageUrl:
          'https://cdn.fynd.com/v2/falling-surf-7c8bb8/fyprod/wrkr/products/pictures/item/free/original/000000000493860578/gAgZSjYsd2-000000000493860578_1.png',
      packSize: "Pack of 1",
      pricePerUnit: 49.0,
      inStock: true,
    ),
    Product(
      name: "MAC Lip Gloss",
      imageUrl:
          'https://m.media-amazon.com/images/I/418ynFWAe4L._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 2",
      pricePerUnit: 32.0,
      inStock: false,
    ),
    Product(
      name: "Nykaa Matte Lipstick",
      imageUrl:
          'https://m.media-amazon.com/images/I/71hUeZd546L._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 3",
      pricePerUnit: 27.0,
      inStock: true,
    ),
    Product(
      name: "Lakme Eyeliner",
      imageUrl:
          'https://www.lakmeindia.com/cdn/shop/files/24894_S1-8901030979552_1000x.jpg?v=1709807079',
      packSize: "Pack of 2",
      pricePerUnit: 18.0,
      inStock: true,
    ),
    Product(
      name: "Maybelline Lip Liner",
      imageUrl:
          'https://m.media-amazon.com/images/I/71Y+L4lMHWL._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 3",
      pricePerUnit: 22.0,
      inStock: true,
    ),
    Product(
      name: "Revlon Face Powder",
      imageUrl:
          'https://m.media-amazon.com/images/I/71JgzO1Pp5L._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 2",
      pricePerUnit: 30.0,
      inStock: false,
    ),
    Product(
      name: "L'Oreal Mascara",
      imageUrl:
          'https://m.media-amazon.com/images/I/61vuiK6d7RL._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 1",
      pricePerUnit: 28.0,
      inStock: true,
    ),
    Product(
      name: "Himalaya Lip Balm",
      imageUrl:
          'https://www.jiomart.com/images/product/original/491061263/himalaya-lip-care-balm-strawberry-shine-4-5-g-product-images-o491061263-p590087371-0-202203150923.jpg',
      packSize: "Pack of 3",
      pricePerUnit: 10.0,
      inStock: true,
    ),
    Product(
      name: "Nykaa Compact Powder",
      imageUrl:
          'https://m.media-amazon.com/images/I/41B-IgO4X2L._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 1",
      pricePerUnit: 24.0,
      inStock: true,
    ),
    Product(
      name: "Colorbar Lipstick",
      imageUrl:
          'https://m.media-amazon.com/images/I/61btigSPLML._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 2",
      pricePerUnit: 26.0,
      inStock: true,
    ),
    Product(
      name: "Forest Essentials Face Cream",
      imageUrl:
          'https://m.media-amazon.com/images/I/61mNSEOhpuL._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 1",
      pricePerUnit: 40.0,
      inStock: true,
    ),
  ];

  final List<Map<String, dynamic>> recentOrders = [
    {
      "id": 1,
      "name": "Skincare",
      "image":
          "https://m.media-amazon.com/images/I/51KNHIFxMIL._UF1000,1000_QL80_.jpg",
    },
    {
      "id": 2,
      "name": "Makeup",
      "image":
          "https://m.media-amazon.com/images/I/71SSYkFV4rL._UF1000,1000_QL80_.jpg",
    },
    {
      "id": 3,
      "name": "Fragrances",
      "image":
          "https://5.imimg.com/data5/SELLER/Default/2023/9/339832626/UT/AZ/ZC/2364872/attar-fragrance-perfume.jpg",
    },
    {
      "id": 4,
      "name": "Hair Care",
      "image":
          "http://avimeeherbal.com/cdn/shop/files/1_2_a7db340e-21ea-483f-844e-22e51122e86a.png?v=1749107204&width=2048",
    },
    {
      "id": 5,
      "name": "Bath & Body",
      "image":
          "https://m.media-amazon.com/images/I/71VG77T7ojL._UF1000,1000_QL80_.jpg",
    },
    {
      "id": 6,
      "name": "Nails",
      "image":
          "https://m.media-amazon.com/images/I/71kOxc1n8mL._UF1000,1000_QL80_.jpg",
    },
    {
      "id": 7,
      "name": "Eyes",
      "image":
          "https://media.fashionnetwork.com/cdn-cgi/image/fit=contain,width=1000,height=1000,format=auto/m/34d7/f0ae/1bd9/e583/1c02/c946/a410/34ed/8ad9/7a8a/7a8a.jpg",
    },
    {
      "id": 8,
      "name": "Lips",
      "image":
          "https://m.media-amazon.com/images/I/61RFhvrGTkL._UF1000,1000_QL80_.jpg",
    },
    {
      "id": 9,
      "name": "Body Oils",
      "image":
          "https://m.media-amazon.com/images/I/51qyzkZRZ4L._UF1000,1000_QL80_.jpg",
    },
    {
      "id": 10,
      "name": "Hair Styling",
      "image":
          "https://m.media-amazon.com/images/I/71ASI7UtiXL._UF1000,1000_QL80_.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyHome,
      backgroundColor: AppColors.containerColor,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
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
                  padding: EdgeInsets.only(top: 6.5.h, right: 3.w, left: 3.w),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.containerColor,
                            child: Icon(
                              CupertinoIcons.bars,
                              color: AppColors.blackColor,
                              size: 30,
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
                                  radius: 25,
                                  backgroundColor: AppColors.containerColor,
                                  child: Icon(
                                    Icons.search,
                                    color: AppColors.blackColor,
                                    size: 30,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.5.w),
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: AppColors.containerColor,
                                    child: Icon(
                                      Icons.notifications_none,
                                      color: AppColors.blackColor,
                                      size: 30,
                                    ),
                                  ),
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: CircleAvatar(
                                      radius: 6,
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
                            "Categories",
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
                              SizedBox(width: 1.w),
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: AppColors.mainColor,
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.whiteColor,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i = 0; i < recentOrders.length; i++)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: i == 0 ? 0 : 10,
                                  right: 10,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Material(
                                      shape: CircleBorder(),
                                      elevation: 2,
                                      clipBehavior: Clip.hardEdge,
                                      child: InkWell(
                                        onTap: () {
                                          // handle tap
                                        },
                                        customBorder: CircleBorder(),
                                        child: ClipOval(
                                          child: CustomNetworkImage(
                                            imageUrl: recentOrders[i]["image"],
                                            width: 15.w,
                                            height: 15.w,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        recentOrders[i]["name"],
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: FontFamily.light,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.h),
                      InkWell(
                        onTap: () {
                          Get.offAll(
                            () => ProductsScreen(),
                            transition: Transition.fade,
                            duration: const Duration(milliseconds: 450),
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Product Catalog",
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
                                SizedBox(width: 1.w),
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: AppColors.mainColor,
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.whiteColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.h),
                      GridView.count(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: ClampingScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        mainAxisSpacing: 1.h,
                        crossAxisSpacing: 2.w,
                        children:
                            products
                                .take(6)
                                .map((p) => _buildGridItem(p))
                                .toList(),
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
      bottomNavigationBar: SizedBox(
        height: 10.h,
        child: CustomBar(selected: 3),
      ),
    );
  }

  Widget _buildGridItem(Product product) {
    return InkWell(
      onTap: () {
        Get.to(
          () => ProductDetailsScreen(),
          transition: Transition.leftToRightWithFade,
          duration: const Duration(milliseconds: 450),
        );
      },
      child: Opacity(
        opacity: product.inStock ? 1.0 : 0.4,
        child: Card(
          color: AppColors.cardBgColor2,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      CustomNetworkImage(
                        imageUrl: product.imageUrl,
                        height: double.infinity,
                        width: double.infinity,
                        isFit: true,
                        radius: 20,
                      ),
                      if (!product.inStock)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.4),
                            child: Center(
                              child: Text(
                                "Out of Stock",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: FontFamily.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Details
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.name,
                      style: TextStyle(
                        fontFamily: FontFamily.bold,
                        fontSize: 15.sp,
                        color: AppColors.blackColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),

                    // Pack Size
                    Text(
                      product.packSize,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: FontFamily.regular,
                        color: AppColors.gray,
                      ),
                    ),
                    SizedBox(height: 0.5.h),

                    // Price
                    Text(
                      "£${product.pricePerUnit.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: FontFamily.semiBold,
                        color: AppColors.mainColor,
                      ),
                    ),
                    SizedBox(height: 1.h),

                    // Quantity + Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Modern Quantity Selector
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.containerColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap:
                                    product.inStock && product.quantity > 0
                                        ? () =>
                                            setState(() => product.quantity--)
                                        : null,
                                child: Container(
                                  padding: EdgeInsets.all(1.5.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 16.sp,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                product.quantity.toString(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: FontFamily.semiBold,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              GestureDetector(
                                onTap:
                                    product.inStock
                                        ? () =>
                                            setState(() => product.quantity++)
                                        : null,
                                child: Container(
                                  padding: EdgeInsets.all(1.5.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 16.sp,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Add to Cart Button
                        InkWell(
                          onTap:
                              product.inStock
                                  ? () {
                                    // handle add to cart
                                  }
                                  : null,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: EdgeInsets.all(1.5.w),
                            decoration: BoxDecoration(
                              color: AppColors.mainColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 18.sp,
                            ),
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
    );
  }
}
