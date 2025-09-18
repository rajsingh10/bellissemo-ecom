import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/ui/products/modal/productDetailsModal.dart';
import 'package:bellissemo_ecom/ui/products/provider/productsProvider.dart';
import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/customButton.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';

import '../../../ApiCalling/apiConfigs.dart';
import '../../../apiCalling/Check Internet Module.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/multipleImagesSlider.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/titlebarWidget.dart';

class ProductDetailsScreen extends StatefulWidget {
  String? productId;

  ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  String? selectedColor;
  List<String> currentImages = [];
  double currentPrice = 0.0;
  AllVariations? selectedVariant;

  String htmlToPlainText(String html) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    // Remove HTML tags
    String text = html.replaceAll(regex, '');
    // Replace multiple spaces in a line with a single space
    text = text.replaceAllMapped(RegExp(r'[^\S\r\n]+'), (match) => ' ');
    // Trim spaces at start/end of each line
    text = text.split('\n').map((line) => line.trim()).join('\n');
    return text;
  }

  void _setDefaultVariant() {
    if (productDetails != null) {
      selectedVariant = productDetails!.allVariations!.first;
      currentPrice = double.tryParse(selectedVariant!.price ?? '0') ?? 0.0;
    }
  }

  final List<String> availableSizes = ['512 GB', '1 TB', '2 TB'];
  String? selectedSize;

  Map<String, int> colorQuantities = {};
  bool isIpad = 100.w >= 800;
  bool isLoading = true;

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);

    // Load cached data first for immediate display
    _loadCachedData();

    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([
        _fetchProductDetails().then(
          (_) => setState(() {
            _setDefaultVariant();
          }),
        ),
      ]);
    } catch (e) {
      log("Error loading initial data: $e");
    } finally {
      stopwatch.stop();
      log("All API calls completed in ${stopwatch.elapsed.inMilliseconds} ms");

      setState(() => isLoading = false);
    }
  }

  void _loadCachedData() {
    var productDetailsBox = HiveService().getProductDetailsBox();

    final cachedProfile = productDetailsBox.get(
      'productDetails${widget.productId}',
    );
    if (cachedProfile != null) {
      productDetails = ProductDetailsModal.fromJson(json.decode(cachedProfile));
      currentImages =
          productDetails?.images?.map((e) => e.src.toString()).toList() ?? [];
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body:
          isLoading
              ? Loader()
              : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.5.h,
                  ),
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
                        productDetails?.name ?? '',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: FontFamily.bold,
                          color: AppColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 1.h),

                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 20.sp),
                          SizedBox(width: 1.w),
                          Text(
                            '${productDetails?.ratingCount} Ratings',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: FontFamily.semiBold,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ],
                      ),
                      productDetails?.variations?.length == 0
                          ? Container()
                          : SizedBox(height: 1.h),
                      productDetails?.variations?.length == 0
                          ? Container()
                          : Text(
                            "Color Variants :",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.gray,
                              fontFamily: FontFamily.regular,
                            ),
                          ),
                      productDetails?.variations?.length == 0
                          ? Container()
                          : SizedBox(height: 1.h),

                      productDetails?.variations?.length == 0
                          ? Container()
                          : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  productDetails!.allVariations!.map((variant) {
                                    final isSelected =
                                        selectedVariant?.id == variant.id;
                                    final variantImage =
                                        variant.images!.isNotEmpty
                                            ? variant.images!.first.src
                                            : '';
                                    final variantName =
                                        variant.attributes?.paColour ?? '';

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedVariant = variant;
                                          currentPrice =
                                              double.tryParse(
                                                variant.price ?? '0',
                                              ) ??
                                              0.0;
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 8),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? AppColors.mainColor
                                                    : Colors.grey.shade400,
                                            width: isSelected ? 2 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            variantImage!.isNotEmpty
                                                ? CustomNetworkImage(
                                                  imageUrl: variantImage,
                                                  height: isIpad ? 16.sp : 20,
                                                  width: isIpad ? 16.sp : 20,
                                                  isCircle: true,
                                                  isProfile: false,
                                                  isFit: true,
                                                )
                                                : Container(
                                                  width: isIpad ? 16.sp : 20,
                                                  height: isIpad ? 16.sp : 20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 14,
                                                  ),
                                                ),
                                            SizedBox(width: 5),
                                            Flexible(
                                              child: Text(
                                                variantName,
                                                style: TextStyle(
                                                  fontSize: isIpad ? 16.sp : 14,
                                                  fontFamily:
                                                      FontFamily.regular,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
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

                      //
                      // Text(
                      //   "Size Variants :",
                      //   style: TextStyle(
                      //     fontSize: 16.sp,
                      //     color: AppColors.gray,
                      //     fontFamily: FontFamily.regular,
                      //   ),
                      // ),
                      // SizedBox(height: 1.h),
                      //
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Row(
                      //     children:
                      //         availableSizes.map((size) {
                      //           return GestureDetector(
                      //             onTap: () {
                      //               setState(() {
                      //                 selectedSize = size;
                      //               });
                      //             },
                      //             child: Container(
                      //               margin: EdgeInsets.only(right: 8),
                      //               // spacing between items
                      //               padding: EdgeInsets.symmetric(
                      //                 horizontal: 4.w,
                      //                 vertical: 1.h,
                      //               ),
                      //               decoration: BoxDecoration(
                      //                 color:
                      //                     selectedSize == size
                      //                         ? AppColors.mainColor.withValues(
                      //                           alpha: 0.2,
                      //                         )
                      //                         : Colors.transparent,
                      //                 borderRadius: BorderRadius.circular(20),
                      //                 border: Border.all(
                      //                   color:
                      //                       selectedSize == size
                      //                           ? AppColors.mainColor
                      //                           : Colors.grey.shade400,
                      //                 ),
                      //               ),
                      //               child: Text(
                      //                 size,
                      //                 style: TextStyle(
                      //                   fontSize: 14.sp,
                      //                   fontFamily: FontFamily.regular,
                      //                 ),
                      //               ),
                      //             ),
                      //           );
                      //         }).toList(),
                      //   ),
                      // ),
                      // SizedBox(height: 1.h),
                      productDetails?.variations?.length == 0
                          ? Text(
                            "£${productDetails?.price ?? ''}",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontFamily: FontFamily.bold,
                              color: AppColors.mainColor,
                            ),
                          )
                          : Text(
                            "£${currentPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontFamily: FontFamily.bold,
                              color: AppColors.mainColor,
                            ),
                          ),
                      SizedBox(height: 1.h),

                      ReadMoreText(
                        htmlToPlainText(productDetails?.description ?? ''),
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
                                    radius: isIpad ? 15.sp : 16,
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
                                    radius: isIpad ? 15.sp : 16,
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

  Future<void> _fetchProductDetails() async {
    var box = HiveService().getProductDetailsBox();

    if (!await checkInternet()) {
      final cachedData = box.get('productDetails${widget.productId}');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        productDetails = ProductDetailsModal.fromJson(data);
        currentImages =
            productDetails?.images?.map((e) => e.src.toString()).toList() ?? [];
      } else {
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
      }
      return;
    }

    try {
      final response = await ProductsProvider().productDetailsApi(
        widget.productId,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        productDetails = ProductDetailsModal.fromJson(data);
        currentImages =
            productDetails?.images?.map((e) => e.src.toString()).toList() ?? [];
        await box.put('productDetails${widget.productId}', response.body);
      } else {
        final cachedData = box.get('productDetails${widget.productId}');
        if (cachedData != null) {
          final data = json.decode(cachedData);
          productDetails = ProductDetailsModal.fromJson(data);
          currentImages =
              productDetails?.images?.map((e) => e.src.toString()).toList() ??
              [];
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      final cachedData = box.get('productDetails${widget.productId}');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        productDetails = ProductDetailsModal.fromJson(data);
        currentImages =
            productDetails?.images?.map((e) => e.src.toString()).toList() ?? [];
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }
}
