import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/ui/products/modal/productDetailsModal.dart';
import 'package:bellissemo_ecom/ui/products/provider/productsProvider.dart';
import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/customButton.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../ApiCalling/apiConfigs.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/emptyWidget.dart';
import '../../../utils/multipleImagesSlider.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/textFields.dart';
import '../../../utils/titlebarWidget.dart';
import '../../cart/service/cartServices.dart';

class ProductDetailsScreen extends StatefulWidget {
  String? productId;

  ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // int quantity = 1;
  TextEditingController notesController = TextEditingController();
  String? selectedColor;
  List<String> currentImages = [];
  double currentPrice = 0.0;
  AllVariations? selectedVariant;
  int? selectedVariationId;
  String? selectedAttributeKey;
  String? selectedAttributeValue;
  bool isAddingToCart = false;

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
      selectedVariant = productDetails!.allVariations?.first;
      currentPrice = double.tryParse(selectedVariant?.price ?? '0') ?? 0.0;
      selectedVariationId = selectedVariant?.id;
      selectedAttributeKey = selectedVariant?.attributes?.getKey();
      selectedAttributeValue = selectedVariant?.attributes?.getValue();
    }
    log('Attributes: {$selectedAttributeKey: $selectedAttributeValue}');
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
    } catch (e, stackTrace) {
      log("Error loading initial data: $stackTrace");
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
  int? customerId;
  String? customerName;
  Future<void> _loadCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customerId = prefs.getInt("customerId");
      customerName = prefs.getString("customerName");
    });
    loadInitialData();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _loadCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body:
          isLoading
              ? Loader()
              : productDetails == null
              ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                child: Column(
                  children: [
                    TitleBar(
                      title: 'Product Details',
                      isDrawerEnabled: true,
                      isBackEnabled: true,
                    ),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isIpad ? 2.h : 15.h,
                      ),
                      child: emptyWidget(
                        icon: Icons.shopping_cart_outlined,
                        text: 'Product Details',
                      ),
                    ),
                  ],
                ),
              )
              : Stack(
                children: [
                  SingleChildScrollView(
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
                              Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 20.sp,
                              ),
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
                                "Product Variants :",
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
                                      productDetails!.allVariations!.map((
                                        variant,
                                      ) {
                                        final isSelected =
                                            selectedVariant?.id == variant.id;
                                        final variantImage =
                                            variant.images!.isNotEmpty
                                                ? variant.images!.first.src
                                                : '';

                                        final variantName =
                                            variant.attributes?.getValue();

                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedVariant = variant;
                                              selectedVariationId = variant.id;
                                              selectedAttributeKey =
                                                  variant.attributes?.getKey();
                                              selectedAttributeValue =
                                                  variant.attributes
                                                      ?.getValue();
                                              currentPrice =
                                                  double.tryParse(
                                                    variant.price ?? '0',
                                                  ) ??
                                                  0.0;

                                              log(
                                                'selectedVariationId :: $selectedVariationId  ',
                                              );
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            padding: const EdgeInsets.symmetric(
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                variantImage!.isNotEmpty
                                                    ? CustomNetworkImage(
                                                      imageUrl: variantImage,
                                                      height:
                                                          isIpad ? 16.sp : 20,
                                                      width:
                                                          isIpad ? 16.sp : 20,
                                                      isCircle: true,
                                                      isProfile: false,
                                                      isFit: true,
                                                    )
                                                    : Container(
                                                      width:
                                                          isIpad ? 16.sp : 20,
                                                      height:
                                                          isIpad ? 16.sp : 20,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade200,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade400,
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 14,
                                                      ),
                                                    ),
                                                const SizedBox(width: 5),
                                                Flexible(
                                                  child: Text(
                                                    variantName ?? '',
                                                    style: TextStyle(
                                                      fontSize:
                                                          isIpad ? 16.sp : 14,
                                                      fontFamily:
                                                          FontFamily.regular,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                              ? InkWell(
                            onTap: () async {
                              final discountResult = await Get.dialog<
                                  Map<
                                      String,
                                      String
                                  >
                              >(
                                Dialog(
                                  backgroundColor:
                                  Colors
                                      .transparent,
                                  child: StatefulBuilder(
                                    builder: (
                                        context,
                                        setState,
                                        ) {
                                      final formKey =
                                      GlobalKey<
                                          FormState
                                      >();
                                      TextEditingController
                                      dialogController =
                                      TextEditingController();
                                      String
                                      selectedType =
                                          "Amount"; // 👈 default dropdown value

                                      return IntrinsicWidth(
                                        stepWidth:
                                        300,
                                        child: IntrinsicHeight(
                                          child: Container(
                                            padding: EdgeInsets.all(
                                              16,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                              AppColors.whiteColor,
                                              borderRadius: BorderRadius.circular(
                                                15,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                Form(
                                                  key:
                                                  formKey,
                                                  child: AppTextField(
                                                    key: ValueKey(
                                                      selectedType,
                                                    ),
                                                    controller:
                                                    dialogController,
                                                    hintText:
                                                    "Increase",
                                                    text:
                                                    "Increase",
                                                    isTextavailable:
                                                    true,
                                                    textInputType:
                                                    TextInputType.number,
                                                    maxline:
                                                    1,
                                                    validator: (
                                                        value,
                                                        ) {
                                                      if (value !=
                                                          null &&
                                                          value.isNotEmpty &&
                                                          double.tryParse(
                                                            value,
                                                          ) ==
                                                              null) {
                                                        return "Enter a valid number";
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),

                                                SizedBox(
                                                  height:
                                                  24,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    CustomButton(
                                                      title:
                                                      "Cancel",
                                                      route:
                                                          () =>
                                                          Get.back(),
                                                      color:
                                                      AppColors.containerColor,
                                                      fontcolor:
                                                      AppColors.blackColor,
                                                      height:
                                                      5.h,
                                                      width:
                                                      27.w,
                                                      fontsize:
                                                      15.sp,
                                                      radius:
                                                      12.0,
                                                    ),
                                                    CustomButton(
                                                      title:
                                                      "Increase Price",
                                                      route: () async {
                                                        bool increseprice =
                                                        true;


                                                        // update server if online
                                                        // if (await checkInternet()) {
                                                        //   try {
                                                        //     await CartService().updateProductPrice(
                                                        //       price:int.parse(dialogController.text.trim()) ,
                                                        //       productId:int.parse(widget.productId.toString()) ,
                                                        //       userId:int.parse(customerId.toString()) ,
                                                        //
                                                        //     );
                                                        //
                                                        //     Get.back();
                                                        //     Get.back();
                                                        //
                                                        //     Get.offAll(() =>
                                                        //     ProductDetailsScreen(productId: widget.productId,),
                                                        //     );
                                                        //     _fetchProductDetails();
                                                        //   } catch (
                                                        //   e,
                                                        //   trackTrace
                                                        //   ) {
                                                        //     showCustomErrorSnackbar(
                                                        //       title:
                                                        //       "Error",
                                                        //       message:
                                                        //       "Failed to update cart\n$e",
                                                        //     );
                                                        //     log(
                                                        //       "shu errro ave che =====>>>>$trackTrace",
                                                        //     );
                                                        //   }
                                                        // }
                                                        await CartService().updateProductPrice(
                                                          price:int.parse(dialogController.text.trim()) ,
                                                          productId:int.parse(widget.productId.toString()) ,
                                                          userId:int.parse(customerId.toString()) ,

                                                        );

                                                        Get.back();
                                                        Get.back();

                                                        Get.offAll(() =>
                                                            ProductDetailsScreen(productId: widget.productId,),
                                                        );
                                                        _fetchProductDetails();
                                                      },
                                                      color:
                                                      AppColors.mainColor,
                                                      fontcolor:
                                                      AppColors.whiteColor,
                                                      height:
                                                      5.h,
                                                      width:
                                                      40.w,
                                                      fontsize:
                                                      15.sp,
                                                      radius:
                                                      12.0,
                                                      iconData:
                                                      Icons.check,
                                                      iconsize:
                                                      17.sp,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                barrierDismissible:
                                true,
                              );
                            },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit,color: AppColors.mainColor),
                                      Text(
                                        "${productDetails?.currencySymbol ?? ''}${productDetails?.price ?? ''}",
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontFamily: FontFamily.bold,
                                          color: AppColors.mainColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              : InkWell(
                            onTap: () async {
                              final discountResult = await Get.dialog<
                                  Map<
                                      String,
                                      String
                                  >
                              >(
                                Dialog(
                                  backgroundColor:
                                  Colors
                                      .transparent,
                                  child: StatefulBuilder(
                                    builder: (
                                        context,
                                        setState,
                                        ) {
                                      final formKey =
                                      GlobalKey<
                                          FormState
                                      >();
                                      TextEditingController
                                      dialogController =
                                      TextEditingController();
                                      String
                                      selectedType =
                                          "Amount"; // 👈 default dropdown value

                                      return IntrinsicWidth(
                                        stepWidth:
                                        300,
                                        child: IntrinsicHeight(
                                          child: Container(
                                            padding: EdgeInsets.all(
                                              16,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                              AppColors.whiteColor,
                                              borderRadius: BorderRadius.circular(
                                                15,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                Form(
                                                  key:
                                                  formKey,
                                                  child: AppTextField(
                                                    key: ValueKey(
                                                      selectedType,
                                                    ),
                                                    controller:
                                                    dialogController,
                                                    hintText:
                                                    "Increase",
                                                    text:
                                                    "Increase",
                                                    isTextavailable:
                                                    true,
                                                    textInputType:
                                                    TextInputType.number,
                                                    maxline:
                                                    1,
                                                    validator: (
                                                        value,
                                                        ) {
                                                      if (value !=
                                                          null &&
                                                          value.isNotEmpty &&
                                                          double.tryParse(
                                                            value,
                                                          ) ==
                                                              null) {
                                                        return "Enter a valid number";
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),

                                                SizedBox(
                                                  height:
                                                  24,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    CustomButton(
                                                      title:
                                                      "Cancel",
                                                      route:
                                                          () =>
                                                          Get.back(),
                                                      color:
                                                      AppColors.containerColor,
                                                      fontcolor:
                                                      AppColors.blackColor,
                                                      height:
                                                      5.h,
                                                      width:
                                                      27.w,
                                                      fontsize:
                                                      15.sp,
                                                      radius:
                                                      12.0,
                                                    ),
                                                    CustomButton(
                                                      title:
                                                      "Increase Price",
                                                      route: () async {
                                                        bool increseprice =
                                                        true;


                                                        // update server if online
                                                        // if (await checkInternet()) {
                                                        //   try {
                                                        //     await CartService().updateProductPrice(
                                                        //       price:int.parse(dialogController.text.trim()) ,
                                                        //       productId:selectedVariationId ,
                                                        //       userId:int.parse(customerId.toString()) ,
                                                        //
                                                        //     );
                                                        //
                                                        //     Get.back();
                                                        //     Get.back();
                                                        //
                                                        //     Get.offAll(() =>
                                                        //         ProductDetailsScreen(productId: widget.productId,),
                                                        //     );
                                                        //     _fetchProductDetails();
                                                        //   } catch (
                                                        //   e,
                                                        //   trackTrace
                                                        //   ) {
                                                        //     showCustomErrorSnackbar(
                                                        //       title:
                                                        //       "Error",
                                                        //       message:
                                                        //       "Failed to update cart\n$e",
                                                        //     );
                                                        //     log(
                                                        //       "shu errro ave che =====>>>>$trackTrace",
                                                        //     );
                                                        //   }
                                                        // }
                                                        await CartService().updateProductPrice(
                                                          price:int.parse(dialogController.text.trim()) ,
                                                          productId:selectedVariationId ,
                                                          userId:int.parse(customerId.toString()) ,

                                                        );

                                                        Get.back();
                                                        Get.back();

                                                        Get.offAll(() =>
                                                            ProductDetailsScreen(productId: widget.productId,),
                                                        );
                                                        _fetchProductDetails();
                                                      },
                                                      color:
                                                      AppColors.mainColor,
                                                      fontcolor:
                                                      AppColors.whiteColor,
                                                      height:
                                                      5.h,
                                                      width:
                                                      40.w,
                                                      fontsize:
                                                      15.sp,
                                                      radius:
                                                      12.0,
                                                      iconData:
                                                      Icons.check,
                                                      iconsize:
                                                      17.sp,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                barrierDismissible:
                                true,
                              );
                            },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit,color: AppColors.mainColor),
                                      Text(
                                        "${productDetails?.currencySymbol ?? ''}${currentPrice.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontFamily: FontFamily.bold,
                                          color: AppColors.mainColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          SizedBox(height: 1.h),

                          ReadMoreText(
                            htmlToPlainText(productDetails?.description ?? ''),
                            trimLines: 10,

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
                              fontSize: 16.sp,
                              fontFamily: FontFamily.regular,
                              color: AppColors.mainColor,
                            ),
                            lessStyle: TextStyle(
                              fontSize: 16.sp,
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
                                        setState(() {
                                          int currentPackSize = int.tryParse(productDetails?.packsize ?? '0') ?? 0;

                                          // If first time, set the original pack size
                                          originalPackSize ??= currentPackSize;

                                          // Subtract the original pack size (e.g., 6 → 4 → 2)
                                          currentPackSize -= originalPackSize!;

                                          // Prevent going below 0
                                          if (currentPackSize < originalPackSize!) {
                                            currentPackSize = originalPackSize!;
                                          }

                                          // Update productDetails
                                          productDetails?.packsize = currentPackSize.toString();

                                          print("Decrement → currentPackSize = $currentPackSize");
                                        });
                                      },
                                      child: CircleAvatar(
                                        radius: isIpad ? 15.sp : 16,
                                        backgroundColor: Colors.transparent,
                                        child: Icon(
                                          Icons.remove,
                                          size: 18.sp,
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      productDetails?.packsize ?? '',
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontFamily: FontFamily.semiBold,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          print("Before: productDetails?.packsize = ${productDetails?.packsize}");

                                          // Convert current pack size
                                          int currentPackSize = int.tryParse(productDetails?.packsize ?? '0') ?? 0;

                                          // If first time, save original pack size
                                          originalPackSize ??= currentPackSize;

                                          // Add only the original pack size (e.g., 2 + 2 = 4, then 4 + 2 = 6)
                                          currentPackSize += originalPackSize!;

                                          // Update
                                          productDetails?.packsize = currentPackSize.toString();

                                          print("After: currentPackSize = $currentPackSize");
                                        });
                                      },

                                      child: CircleAvatar(
                                        radius: isIpad ? 15.sp : 16,
                                        backgroundColor: Colors.transparent,
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
                                  route: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        String? errorText;

                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              backgroundColor:
                                                  AppColors.whiteColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              title: Text(
                                                "Item Notes",
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontFamily: FontFamily.bold,
                                                  color: AppColors.blackColor,
                                                ),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  AppTextField(
                                                    controller: notesController,
                                                    hintText:
                                                        "Enter Item notes here...",
                                                    text: "Notes",
                                                    isTextavailable: true,
                                                    textInputType:
                                                        TextInputType.multiline,
                                                    maxline: 4,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Please enter Item notes";
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  if (errorText != null) ...[
                                                    SizedBox(height: 8),
                                                    Text(
                                                      errorText!,
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 14.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              actions: [
                                                CustomButton(
                                                  title: "Cancel",
                                                  route: () {
                                                    Get.back();
                                                  },
                                                  color:
                                                      AppColors.containerColor,
                                                  fontcolor:
                                                      AppColors.blackColor,
                                                  height: 5.h,
                                                  width: 30.w,
                                                  fontsize: 15.sp,
                                                  radius: 12.0,
                                                ),
                                                CustomButton(
                                                  title: "Confirm",
                                                  route: () async {
                                                    productDetails
                                                        ?.variations
                                                        ?.length ==
                                                        0
                                                        ? _addSimpleProductsToCart()
                                                        : _addVariationProductsToCart();
                                                    Get.back();
                                                  },
                                                  color: AppColors.mainColor,
                                                  fontcolor:
                                                      AppColors.whiteColor,
                                                  height: 5.h,
                                                  width: 30.w,
                                                  fontsize: 15.sp,
                                                  radius: 12.0,
                                                  iconData: Icons.check,
                                                  iconsize: 17.sp,
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );

                                    log(
                                      'selectedVariationId :: $selectedVariationId',
                                    );
                                  },
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
                  if (isAddingToCart)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: Loader(),
                    ),
                ],
              ),
    );
  }

  // Future<void> _fetchProductDetails() async {
  //   var box = HiveService().getProductDetailsBox();
  //
  //   if (!await checkInternet()) {
  //     final cachedData = box.get('productDetails${widget.productId}');
  //     if (cachedData != null) {
  //       final data = json.decode(cachedData);
  //       productDetails = ProductDetailsModal.fromJson(data);
  //       currentImages =
  //           productDetails?.images?.map((e) => e.src.toString()).toList() ?? [];
  //     } else {
  //       showCustomErrorSnackbar(
  //         title: 'No Internet',
  //         message: 'Please check your connection and try again.',
  //       );
  //     }
  //     return;
  //   }
  //
  //   try {
  //     final response = await ProductsProvider().productDetailsApi(
  //       widget.productId,
  //     );
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       productDetails = ProductDetailsModal.fromJson(data);
  //       currentImages =
  //           productDetails?.images?.map((e) => e.src.toString()).toList() ?? [];
  //       await box.put('productDetails${widget.productId}', response.body);
  //     } else {
  //       final cachedData = box.get('productDetails${widget.productId}');
  //       if (cachedData != null) {
  //         final data = json.decode(cachedData);
  //         productDetails = ProductDetailsModal.fromJson(data);
  //         currentImages =
  //             productDetails?.images?.map((e) => e.src.toString()).toList() ??
  //             [];
  //       }
  //       showCustomErrorSnackbar(
  //         title: 'Server Error',
  //         message: 'Something went wrong. Please try again later.',
  //       );
  //     }
  //   } catch (_) {
  //     final cachedData = box.get('productDetails${widget.productId}');
  //     if (cachedData != null) {
  //       final data = json.decode(cachedData);
  //       productDetails = ProductDetailsModal.fromJson(data);
  //       currentImages =
  //           productDetails?.images?.map((e) => e.src.toString()).toList() ?? [];
  //     }
  //     showCustomErrorSnackbar(
  //       title: 'Network Error',
  //       message: 'Unable to connect. Please check your internet and try again.',
  //     );
  //   }
  // }
  int? originalPackSize;
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
        print("❌ No internet and no cached data found");
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
          customerId,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        productDetails = ProductDetailsModal.fromJson(data);
        currentImages =
            productDetails?.images?.map((e) => e.src.toString()).toList() ?? [];
        await box.put('productDetails${widget.productId}', response.body);
      } else {
        print(
          "❌ Server Error → statusCode: ${response.statusCode}, body: ${response.body}",
        );
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
    } catch (e, stack) {
      print("❌ Exception in _fetchProductDetails: $e");
      print("📌 Stacktrace:\n$stack");

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

  Future<void> _addVariationProductsToCart() async {
    setState(() {
      isAddingToCart = true;
    });
    final cartService = CartService();

    try {
      final response = await cartService.addToCart(
        productId: int.parse(widget.productId ?? ''),
        variationId: selectedVariationId,
        variation: {
          "attribute_${selectedAttributeKey ?? ''}":
              selectedAttributeValue ?? '',
        },
        quantity: int.parse((productDetails?.packsize).toString()),
        itemNote: notesController.text.trim().toString(),
      );

      if (response != null && response.statusCode == 200) {
        // showCustomSuccessSnackbar(
        //   title: "Added to Cart",
        //   message: "This product has been successfully added to your cart.",
        // );
        setState(() {
          isAddingToCart = false;
          // quantity = 1;
        });
      } else {
        // showCustomSuccessSnackbar(
        //   title: "Offline Mode",
        //   message: "Product added offline. It will sync once internet is back.",
        // );
        setState(() {
          isAddingToCart = false;
          // quantity = 1;
        });
      }
    } catch (e) {
      showCustomErrorSnackbar(
        title: "Error",
        message: "Something went wrong while adding product.\n$e",
      );
      setState(() {
        isAddingToCart = false;
      });
    }
  }

  Future<void> _addSimpleProductsToCart() async {
    setState(() {
      isAddingToCart = true;
    });
    final cartService = CartService();

    try {
      final response = await cartService.addToCart(
        productId: int.parse(widget.productId ?? ''),
        quantity: int.parse((productDetails?.packsize).toString()),
        itemNote: notesController.text.trim().toString(),
      );

      if (response != null && response.statusCode == 200) {
        // showCustomSuccessSnackbar(
        //   title: "Added to Cart",
        //   message: "This product has been successfully added to your cart.",
        // );
        setState(() {
          isAddingToCart = false;
          // quantity = 1;
        });
      } else {
        // showCustomSuccessSnackbar(
        //   title: "Offline Mode",
        //   message: "Product added offline. It will sync once internet is back.",
        // );
        setState(() {
          isAddingToCart = false;
          // quantity = 1;
        });
      }
    } catch (e) {
      showCustomErrorSnackbar(
        title: "Error",
        message: "Something went wrong while adding product.\n$e",
      );
      log('Error : $e');
      setState(() {
        isAddingToCart = false;
      });
    }
  }
}
