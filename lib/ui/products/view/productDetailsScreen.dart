import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/customButton.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/multipleImagesSlider.dart';
import '../../../utils/titlebarWidget.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  List<String> images = [
    'https://9to5mac.com/wp-content/uploads/sites/6/2023/09/iphone-15-pro-wallpaper-2.webp',
    'https://www.apple.com/newsroom/images/2023/09/apple-unveils-iphone-15-pro-and-iphone-15-pro-max/tile/Apple-iPhone-15-Pro-lineup-hero-230912.jpg.landing-big_2x.jpg',
    'https://fdn.gsmarena.com/imgroot/news/23/09/iphone-15-pro-announcement/-1200/gsmarena_002.jpg',
  ];

  // Map color -> list of images and price
  final Map<String, Map<String, dynamic>> productVariants = {
    "Blue Titanium": {
      "images": [
        'https://9to5mac.com/wp-content/uploads/sites/6/2023/09/iphone-15-pro-wallpaper-2.webp',
        'https://www.apple.com/newsroom/images/2023/09/apple-unveils-iphone-15-pro-and-iphone-15-pro-max/tile/Apple-iPhone-15-Pro-lineup-hero-230912.jpg.landing-big_2x.jpg',
      ],
      "price": 169.0,
    },
    "Black Titanium": {
      "images": [
        'https://fdn.gsmarena.com/imgroot/news/23/09/iphone-15-pro-announcement/-1200/gsmarena_002.jpg',
        'https://www.apple.com/newsroom/images/2023/09/apple-unveils-iphone-15-pro-and-iphone-15-pro-max/tile/Apple-iPhone-15-Pro-lineup-hero-230912.jpg.landing-big_2x.jpg',
      ],
      "price": 175.0,
    },
    "Natural Titanium": {
      "images": [
        'https://9to5mac.com/wp-content/uploads/sites/6/2023/09/iphone-15-pro-wallpaper-2.webp',
        'https://fdn.gsmarena.com/imgroot/news/23/09/iphone-15-pro-announcement/-1200/gsmarena_002.jpg',
      ],
      "price": 172.0,
    },
    "White Titanium": {
      "images": [
        'https://www.apple.com/newsroom/images/2023/09/apple-unveils-iphone-15-pro-and-iphone-15-pro-max/tile/Apple-iPhone-15-Pro-lineup-hero-230912.jpg.landing-big_2x.jpg',
        'https://fdn.gsmarena.com/imgroot/news/23/09/iphone-15-pro-announcement/-1200/gsmarena_002.jpg',
      ],
      "price": 180.0,
    },
  };

  String? selectedColor;
  List<String> currentImages = [];
  double currentPrice = 0.0;

  final Map<String, Color> availableColors = {
    "Blue Titanium": Color(0xff4f5b70),
    "Black Titanium": Color(0xff7B7B7B),
    "Natural Titanium": Color(0xffc3bf9e),
    "White Titanium": Color(0xffF1F1EF),
  };

  final List<String> availableSizes = ['512 GB', '1 TB', '2 TB'];
  String? selectedSize;

  Map<String, int> colorQuantities = {};
  bool isIpad = 100.w >= 800;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedColor = productVariants.keys.first;
    currentImages = productVariants[selectedColor]!['images'];
    currentPrice = productVariants[selectedColor]!['price'];
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleBar(
                title: 'Product Details',
                isDrawerEnabled: true,
                isBackEnabled: true,
              ),
              SizedBox(height: 2.h),

              ImageSlider(
                imageUrls: currentImages,
                height: isIpad ? 50.h : 25.h,
                autoScroll: false,
              ),
              SizedBox(height: 2.h),

              Text(
                "Iphone 15 pro max",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: FontFamily.bold,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(height: 1.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 20.sp),
                      SizedBox(width: 1.w),
                      Text(
                        "4.8",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: FontFamily.semiBold,
                          color: AppColors.blackColor,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        "117 reviews",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: FontFamily.regular,
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "94%",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: FontFamily.semiBold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(Icons.thumb_up, size: 17.sp, color: Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                "Color Variants :",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.gray,
                  fontFamily: FontFamily.regular,
                ),
              ),
              SizedBox(height: 1.h),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      productVariants.entries.map((entry) {
                        final colorName = entry.key;
                        final colorValue =
                            availableColors[colorName] ?? Colors.grey;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = colorName;
                              currentImages = entry.value['images'];
                              currentPrice = entry.value['price'];
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            // spacing between items
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  selectedColor == colorName
                                      ? AppColors.mainColor.withValues(
                                        alpha: 0.2,
                                      )
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    selectedColor == colorName
                                        ? AppColors.mainColor
                                        : Colors.grey.shade400,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: colorValue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  colorName,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: FontFamily.regular,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              SizedBox(height: 1.h),

              Text(
                "Size Variants :",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.gray,
                  fontFamily: FontFamily.regular,
                ),
              ),
              SizedBox(height: 1.h),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      availableSizes.map((size) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSize = size;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            // spacing between items
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  selectedSize == size
                                      ? AppColors.mainColor.withValues(
                                        alpha: 0.2,
                                      )
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    selectedSize == size
                                        ? AppColors.mainColor
                                        : Colors.grey.shade400,
                              ),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: FontFamily.regular,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              SizedBox(height: 1.h),

              Text(
                "£${currentPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontFamily: FontFamily.bold,
                  color: AppColors.mainColor,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                "from £14 per month",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: FontFamily.regular,
                  color: AppColors.gray,
                ),
              ),

              SizedBox(height: 1.h),

              ReadMoreText(
                "The iPhone 15 Pro Max features a premium titanium design, a large 6.7-inch ProMotion Super Retina XDR OLED display, and the powerful A17 Pro chip. It stands out with a versatile camera system, including a 48MP main sensor and a 5x optical zoom telephoto lens, a customizable Action button, and a USB-C port for charging and connectivity.\nKey Features & Specifications\nDesign: Aerospace-grade titanium with a textured, matte glass back and contoured edges for a comfortable grip.\nDisplay: A large, bright 6.7-inch Super Retina XDR OLED display with ProMotion for smooth scrolling and a 120Hz refresh rate. It also features the Dynamic Island, a pill-shaped cutout for alerts and activities.\nProcessor: Powered by the A17 Pro chip, a hexa-core processor known for fast multitasking and extensive gaming capabilities.\nCamera System:A high-resolution 48MP main camera.A 12MP ultrawide camera.A 12MP telephoto camera with 5x optical zoom, offering significant reach for photos.",
                trimLines: 4,

                style: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: FontFamily.regular,
                  color: AppColors.gray,
                  height: 1.4,
                ),
                colorClickableText: AppColors.mainColor,
                // Color of "Read more/less"
                trimMode: TrimMode.Line,
                trimCollapsedText: ' Read more',
                trimExpandedText: ' Read less',
                moreStyle: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: FontFamily.regular,
                  color: AppColors.mainColor,
                ),
                lessStyle: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: FontFamily.regular,
                  color: AppColors.mainColor,
                ),
              ),
              SizedBox(height: 3.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 0.8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (quantity > 1) {
                              setState(() => quantity--);
                            }
                          },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.cardBgColor,
                            child: Icon(
                              Icons.remove,
                              size: 18.sp,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          quantity.toString(),
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: FontFamily.semiBold,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        GestureDetector(
                          onTap: () => setState(() => quantity++),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.cardBgColor,
                            child: Icon(
                              Icons.add,
                              size: 18.sp,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: CustomButton(
                      title: 'Add to cart',
                      route: () {},
                      color: AppColors.mainColor,
                      fontcolor: AppColors.whiteColor,
                      radius: isIpad ? 1.w : 3.w,
                      height: isIpad ? 7.h : 5.h,
                      fontsize: 16.sp,
                      iconData: Icons.shopping_cart_outlined,
                      iconsize: 16.sp,
                    ),
                  ),

                  SizedBox(width: 4.w),
                ],
              ),
              SizedBox(height: 5.h),
            ],
          ),
        ),
      ),
    );
  }
}
