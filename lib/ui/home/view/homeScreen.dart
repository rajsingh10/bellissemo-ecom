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
import '../../products/view/productCatalogScreen.dart';
import '../../products/view/productDetailsScreen.dart';

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
      name: "Apple iPhone 15 Pro",
      imageUrl:
          'https://m.media-amazon.com/images/I/81SigpJN1KL._UF1000,1000_QL80_.jpg',
      packSize: "128GB",
      pricePerUnit: 699.0,
      inStock: true,
    ),
    Product(
      name: "Samsung Galaxy Pro",
      imageUrl: 'https://m.media-amazon.com/images/I/61KVX-MbIUL.jpg',
      packSize: "1 Pair",
      pricePerUnit: 69.0,
      inStock: true,
    ),
    Product(
      name: "Apple iPad Air",
      imageUrl:
          'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/ipad-air-storage-select-202405-13inch-space-gray-wifi_FMT_WHH?wid=1280&hei=720&fmt=p-jpg&qlt=80&.v=TENLTVRoeFdHUUI5ZE1ZZmxpQUlNMm5pQUoxb0NIVEJFSjRVRzZ4dzV5VE52YTlHWkltOWpNQVF4Y3VwTzdmWGl1WEttbFlFejZ0L0VqVlhGc0pKT3BmbTBuZmdjbmVyUEN6U1pnb2VjUDh3Qjhvd1BnZkhnUFFYU1JJMGh5alFTUzBLNXZ0QTA0SmlDNU1IU2czNjMzNXFNVzc5YkZmK2I4YzJ4ZndkZUdj&traceId=1',
      packSize: "256GB",
      pricePerUnit: 599.0,
      inStock: true,
    ),
    Product(
      name: "Sony WH-1000XM5",
      imageUrl:
          'https://computermania.co.za/cdn/shop/files/wh1000xm53.jpg?v=1694697686',
      packSize: "1 Unit",
      pricePerUnit: 329.0,
      inStock: true,
    ),
    Product(
      name: "Google Pixel 8",
      imageUrl:
          'https://media.tatacroma.com/Croma%20Assets/Communication/Mobiles/Images/309134_0_cv9vxa.png',
      packSize: "128GB",
      pricePerUnit: 649.0,
      inStock: true,
    ),
    Product(
      name: "Dell XPS Laptop",
      imageUrl:
          'https://dellstatic.luroconnect.com/media/catalog/product/cache/74ae05ef3745aec30d7f5a287debd7f5/i/n/indhs-xps-9530-co_2.jpg',
      packSize: "512GB SSD",
      pricePerUnit: 1099.0,
      inStock: true,
    ),
    Product(
      name: "Apple Watch Series 9",
      imageUrl:
          'https://m.media-amazon.com/images/I/81mHRsWENaL._UF1000,1000_QL80_.jpg',
      packSize: "45mm",
      pricePerUnit: 399.0,
      inStock: false,
    ),
    Product(
      name: "Logitech MX Master 3S",
      imageUrl: 'https://m.media-amazon.com/images/I/61ni3t1ryQL.jpg',
      packSize: "1 Unit",
      pricePerUnit: 99.0,
      inStock: true,
    ),
    Product(
      name: "Samsung 4K Monitor",
      imageUrl:
          'https://computerspace.in/cdn/shop/products/NewProject-2021-06-10T163019.378.jpg?v=1629056157',
      packSize: "32 inch",
      pricePerUnit: 299.0,
      inStock: true,
    ),
    Product(
      name: "Bose QuietComfort Earbuds II",
      imageUrl:
          'https://m.media-amazon.com/images/I/51DOzlkiBTL._UF1000,1000_QL80_.jpg',
      packSize: "1 Pair",
      pricePerUnit: 249.0,
      inStock: true,
    ),
    Product(
      name: "Nintendo Switch OLED",
      imageUrl:
          'https://www.designinfo.in/wp-content/uploads/2023/05/Nintendo-Switch-OLED-Model-The-Legend-of-Zelda.webp',
      packSize: "64GB",
      pricePerUnit: 349.0,
      inStock: false,
    ),
    Product(
      name: "HP Envy Printer",
      imageUrl:
          'https://5.imimg.com/data5/SELLER/Default/2022/11/PX/RJ/PP/65193524/hp-envy-wifi-printer-4500.jpg',
      packSize: "1 Unit",
      pricePerUnit: 149.0,
      inStock: true,
    ),
    Product(
      name: "Apple AirPods Pro 2",
      imageUrl:
          'https://idestiny.in/wp-content/uploads/2024/10/Airpods-pro2-6.jpg',
      packSize: "1 Pair",
      pricePerUnit: 249.0,
      inStock: true,
    ),
    Product(
      name: "Samsung Galaxy Tab S9",
      imageUrl:
          'https://m.media-amazon.com/images/I/618Acjb5AhL._UF1000,1000_QL80_.jpg',
      packSize: "256GB",
      pricePerUnit: 799.0,
      inStock: true,
    ),
  ];
  final List<Map<String, dynamic>> recentOrders = [
    {
      "orderNumber": "#1001",
      "name": "Nike Air",
      "image":
          "https://d2v5dzhdg4zhx3.cloudfront.net/web-assets/images/storypages/primary/ProductShowcasesampleimages/JPEG/Product+Showcase-1.jpg",
      "price": 120.0,
      "quantity": 1,
      "date": "2025-09-01",
    },
    {
      "orderNumber": "#1002",
      "name": "Sony",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkn0TdZw5jr0EOj9fdbG3RwmoSzJtpoN8g_Q&s",
      "price": 75.5,
      "quantity": 2,
      "date": "2025-08-28",
    },
    {
      "orderNumber": "#1003",
      "name": "Nike Air",
      "image":
          "https://d2v5dzhdg4zhx3.cloudfront.net/web-assets/images/storypages/primary/ProductShowcasesampleimages/JPEG/Product+Showcase-1.jpg",
      "price": 120.0,
      "quantity": 3,
      "date": "2025-08-20",
    },
    {
      "orderNumber": "#1004",
      "name": "Sony",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkn0TdZw5jr0EOj9fdbG3RwmoSzJtpoN8g_Q&s",
      "price": 80.0,
      "quantity": 1,
      "date": "2025-08-15",
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
                                padding: const EdgeInsets.only(
                                  top: 40,
                                  left: 6,
                                  right: 6,
                                  bottom: 12,
                                ),
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
                                        padding: EdgeInsets.only(
                                          top: 25,
                                          left: 12,
                                          right: 12,
                                          bottom: 12,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              style: TextStyle(
                                                color: AppColors.blackColor,
                                                fontFamily: FontFamily.semiBold,
                                                fontSize: 16.sp,
                                              ),
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
                                              style: TextStyle(
                                                color: AppColors.gray,
                                                fontSize: 16.sp,
                                                fontFamily: FontFamily.semiBold,
                                              ),
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
                                              color: Colors.grey.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              recentOrders[i]["image"],
                                            ),
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
                      SizedBox(height: 1.h),
                      InkWell(
                        onTap: () {
                          Get.offAll(
                            () => ProductCatalogScreen(),
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
        height: 12.h,
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
                            color: AppColors.bgColor,
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
                                child: Icon(
                                  Icons.remove_circle,
                                  size: 22.sp,
                                  color: AppColors.mainColor,
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
                                child: Icon(
                                  Icons.add_circle,
                                  size: 22.sp,
                                  color: AppColors.mainColor,
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
                              color:
                                  product.inStock
                                      ? AppColors.mainColor
                                      : Colors.grey,
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
