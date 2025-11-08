import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/ui/products/modal/productDetailsModal.dart';
import 'package:bellissemo_ecom/ui/products/provider/productsProvider.dart';
import 'package:bellissemo_ecom/ui/products/view/productsScreen.dart';
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
  bool? isVariation;
  String? cate;
  String? id;
  String? slug;

  ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.isVariation,
    required this.cate,
    required this.id,
    required this.slug,
  });

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
  num currentqty = 0;

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
      currentqty = num.parse(selectedVariant?.packSize ?? '0');
      selectedVariationId = selectedVariant?.id;
      selectedAttributeKey = selectedVariant?.attributes?.getKey();
      selectedAttributeValue = selectedVariant?.attributes?.getValue();
    }
    log('Attributes: {$selectedAttributeKey: $selectedAttributeValue}');
  }

  final List<String> availableSizes = ['512 GB', '1 TB', '2 TB'];
  String? selectedSize;
  bool isIpad = 100.w >= 800;
  bool isLoading = true;
  Map<int, int> variantQuantities = {};

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
                              :

                              SingleChildScrollView(
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

                                        // ✅ Default quantity = 0
                                        final int variantQty =
                                            (variantQuantities[variant.id] ?? 0)
                                                .toInt();

                                        // ✅ Responsive sizing
                                        final screenWidth =
                                            MediaQuery.of(context).size.width;
                                        final screenHeight =
                                            MediaQuery.of(context).size.height;

                                        final cardWidth =
                                            screenWidth *
                                            (isIpad ? 0.25 : 0.35);
                                        final cardHeight =
                                            screenHeight *
                                            (isIpad ? 0.23 : 0.18);
                                        final imageSize = cardHeight * 0.45;
                                        final borderRadius =
                                            screenWidth * 0.035;
                                        final fontSize = screenWidth * 0.035;
                                        final iconSize = screenWidth * (isIpad ?0.025:0.045);
                                        final paddingValue = screenWidth * 0.02;
                                        final marginRight = screenWidth * 0.025;

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

                                              // ✅ Update current images for ImageSlider
                                              currentImages =
                                                  variant.images != null &&
                                                          variant
                                                              .images!
                                                              .isNotEmpty
                                                      ? variant.images!
                                                          .map(
                                                            (img) =>
                                                                img.src ?? '',
                                                          )
                                                          .where(
                                                            (e) => e.isNotEmpty,
                                                          )
                                                          .toList()
                                                      : [];

                                              currentPrice =
                                                  double.tryParse(
                                                    variant.price ?? '0',
                                                  ) ??
                                                  0.0;

                                              // Initialize qty if not already in map
                                              variantQuantities.putIfAbsent(
                                                variant.id!,
                                                () => 0,
                                              );
                                            });
                                          },
                                          child: Container(
                                            width: cardWidth,
                                            margin: EdgeInsets.only(
                                              right: marginRight,
                                            ),
                                            padding: EdgeInsets.all(
                                              paddingValue,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    borderRadius,
                                                  ),
                                              border: Border.all(
                                                color:
                                                    isSelected
                                                        ? AppColors.mainColor
                                                        : Colors.grey.shade300,
                                                width:
                                                    isSelected
                                                        ? screenWidth * 0.005
                                                        : screenWidth * 0.002,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius:
                                                      screenWidth * 0.02,
                                                  offset: Offset(
                                                    0,
                                                    screenHeight * 0.002,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // 🔹 Variant Image
                                                variantImage!.isNotEmpty
                                                    ? CustomNetworkImage(
                                                      imageUrl: variantImage,
                                                      height: 10.w,
                                                      width: 10.w,
                                                      isCircle: true,
                                                      isProfile: false,
                                                      isFit: true,
                                                    )
                                                    : Container(
                                                      width: imageSize,
                                                      height: imageSize,
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
                                                          width:
                                                              screenWidth *
                                                              0.002,
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: iconSize,
                                                        color: Colors.grey,
                                                      ),
                                                    ),

                                                SizedBox(height: 0.5.h),

                                                // 🔹 Variant Name
                                                Text(
                                                  variantName ?? '',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontFamily: FontFamily.bold,
                                                    color: AppColors.blackColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),

                                                SizedBox(height: 0.5.h),

                                                // 🔹 Quantity Section (+ / -)
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2.w,
                                                    vertical: 1.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          90,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 90,
                                                        offset: Offset(
                                                          0,
                                                          screenHeight * 0.002,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      // ➖ MINUS BUTTON
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            int
                                                            currentPackSize =
                                                                variantQuantities[variant
                                                                    .id!] ??
                                                                0;
                                                            final int
                                                            originalPackSize =
                                                                int.tryParse(
                                                                  variant.packSize ??
                                                                      '0',
                                                                ) ??
                                                                0;

                                                            currentPackSize -=
                                                                originalPackSize;
                                                            if (currentPackSize <
                                                                0)
                                                              currentPackSize =
                                                                  0;

                                                            variantQuantities[variant
                                                                    .id!] =
                                                                currentPackSize;

                                                            addOrUpdateCartItem(
                                                              productId:
                                                                  productDetails!
                                                                      .id!,
                                                              variationId:
                                                                  variant.id!,
                                                              attributeKey:
                                                                  variant
                                                                      .attributes
                                                                      ?.getKey() ??
                                                                  "attribute_pa_color",
                                                              attributeValue:
                                                                  variant
                                                                      .attributes
                                                                      ?.getValue() ??
                                                                  "",
                                                              quantity:
                                                                  currentPackSize,
                                                              overridePrice:
                                                                  double.tryParse(
                                                                    variant.price ??
                                                                        '0',
                                                                  ) ??
                                                                  0.0,
                                                              itemNote:
                                                                  notesController
                                                                          .text
                                                                          .isEmpty
                                                                      ? ""
                                                                      : notesController
                                                                          .text
                                                                          .trim(),
                                                            );
                                                          });
                                                        },
                                                        child: Icon(
                                                          Icons.remove,
                                                          size: iconSize,
                                                          color:
                                                              (variantQuantities[variant
                                                                              .id!] ??
                                                                          0) ==
                                                                      0
                                                                  ? Colors.grey
                                                                  : AppColors
                                                                      .blackColor,
                                                        ),
                                                      ),

                                                      SizedBox(width: 2.w),

                                                      // 🟢 Quantity Text
                                                      Text(
                                                        (variantQuantities[variant
                                                                    .id!] ??
                                                                0)
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize:
                                                              fontSize * (isIpad?0.5:0.75),
                                                          fontFamily:
                                                              FontFamily
                                                                  .semiBold,
                                                          color:
                                                              AppColors
                                                                  .blackColor,
                                                        ),
                                                      ),

                                                      SizedBox(width: 2.w),

                                                      // ➕ PLUS BUTTON
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            int
                                                            currentPackSize =
                                                                variantQuantities[variant
                                                                    .id!] ??
                                                                0;
                                                            final int
                                                            originalPackSize =
                                                                int.tryParse(
                                                                  variant.packSize ??
                                                                      '0',
                                                                ) ??
                                                                0;

                                                            currentPackSize +=
                                                                originalPackSize;

                                                            variantQuantities[variant
                                                                    .id!] =
                                                                currentPackSize;

                                                            addOrUpdateCartItem(
                                                              productId:
                                                                  productDetails!
                                                                      .id!,
                                                              variationId:
                                                                  variant.id!,
                                                              attributeKey:
                                                                  variant
                                                                      .attributes
                                                                      ?.getKey() ??
                                                                  "attribute_pa_color",
                                                              attributeValue:
                                                                  variant
                                                                      .attributes
                                                                      ?.getValue() ??
                                                                  "",
                                                              quantity:
                                                                  currentPackSize,
                                                              overridePrice:
                                                                  double.tryParse(
                                                                    variant.price ??
                                                                        '0',
                                                                  ) ??
                                                                  0.0,
                                                              itemNote:
                                                                  notesController
                                                                          .text
                                                                          .isEmpty
                                                                      ? ""
                                                                      : notesController
                                                                          .text
                                                                          .trim(),
                                                            );
                                                          });
                                                        },
                                                        child: Icon(
                                                          Icons.add,
                                                          size: iconSize,
                                                          color:
                                                              AppColors
                                                                  .blackColor,
                                                        ),
                                                      ),
                                                    ],
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

                          productDetails?.variations?.length == 0
                              ? InkWell(
                                onTap: () async {
                                  final discountResult = await Get.dialog<
                                    Map<String, String>
                                  >(
                                    Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: StatefulBuilder(
                                        builder: (context, setState) {
                                          final formKey =
                                              GlobalKey<FormState>();
                                          TextEditingController
                                          dialogController =
                                              TextEditingController();
                                          String selectedType =
                                              "Amount"; // 👈 default dropdown value

                                          return IntrinsicWidth(
                                            stepWidth: 300,
                                            child: IntrinsicHeight(
                                              child: Container(
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: AppColors.whiteColor,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Form(
                                                      key: formKey,
                                                      child: AppTextField(
                                                        key: ValueKey(
                                                          selectedType,
                                                        ),
                                                        controller:
                                                            dialogController,
                                                        hintText: "Edit Price",
                                                        text: "Edit Price",
                                                        isTextavailable: true,
                                                        textInputType:
                                                            TextInputType
                                                                .number,
                                                        maxline: 1,
                                                        validator: (value) {
                                                          if (value != null &&
                                                              value
                                                                  .isNotEmpty &&
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

                                                    SizedBox(height: 24),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        CustomButton(
                                                          title: "Cancel",
                                                          route:
                                                              () => Get.back(),
                                                          color:
                                                              AppColors
                                                                  .containerColor,
                                                          fontcolor:
                                                              AppColors
                                                                  .blackColor,
                                                          height: 5.h,
                                                          width: 27.w,
                                                          fontsize: 15.sp,
                                                          radius: 12.0,
                                                        ),

                                                        CustomButton(
                                                          title: "Edit Price",
                                                          route: () async {
                                                            if (dialogController
                                                                .text
                                                                .trim()
                                                                .isEmpty)
                                                              return;

                                                            final enteredPrice =
                                                                int.parse(
                                                                  dialogController
                                                                      .text
                                                                      .trim(),
                                                                );

                                                            // Immediately update locally so UI reflects new price
                                                            setState(() {
                                                              productDetails
                                                                      ?.price =
                                                                  enteredPrice
                                                                      .toString();
                                                            });

                                                            // Save / Sync to backend or offline queue
                                                            await CartService().updateProductPrice(
                                                              price:
                                                                  enteredPrice,
                                                              productId: int.parse(
                                                                widget.productId
                                                                    .toString(),
                                                              ),
                                                              userId: int.parse(
                                                                customerId
                                                                    .toString(),
                                                              ),
                                                            );

                                                            // Cache updated product details (for offline view)
                                                            var box =
                                                                HiveService()
                                                                    .getProductDetailsBox();
                                                            final cachedData =
                                                                box.get(
                                                                  'productDetails${widget.productId}',
                                                                );
                                                            if (cachedData !=
                                                                null) {
                                                              final data = json
                                                                  .decode(
                                                                    cachedData,
                                                                  );
                                                              data['price'] =
                                                                  enteredPrice;
                                                              await box.put(
                                                                'productDetails${widget.productId}',
                                                                json.encode(
                                                                  data,
                                                                ),
                                                              );
                                                            }

                                                            // Close dialogs and refresh UI
                                                            Get.back();
                                                            Get.back();
                                                            Get.back();
                                                            Get.to(
                                                              () => ProductDetailsScreen(
                                                                productId:
                                                                    widget
                                                                        .productId,
                                                                isVariation:
                                                                    widget
                                                                        .isVariation,
                                                                id: widget.id,
                                                                cate:
                                                                    widget.cate,
                                                                slug:
                                                                    widget.slug,
                                                              ),
                                                            );
                                                            _fetchProductDetails(); // will use cached data if offline
                                                          },
                                                          color:
                                                              AppColors
                                                                  .mainColor,
                                                          fontcolor:
                                                              AppColors
                                                                  .whiteColor,
                                                          height: 5.h,
                                                          width: 40.w,
                                                          fontsize: 15.sp,
                                                          radius: 12.0,
                                                          iconData: Icons.check,
                                                          iconsize: 17.sp,
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
                                    barrierDismissible: true,
                                  );
                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: AppColors.mainColor,
                                      ),
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
                                    Map<String, String>
                                  >(
                                    Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: StatefulBuilder(
                                        builder: (context, setState) {
                                          final formKey =
                                              GlobalKey<FormState>();
                                          TextEditingController
                                          dialogController =
                                              TextEditingController();
                                          String selectedType =
                                              "Amount"; // 👈 default dropdown value

                                          return IntrinsicWidth(
                                            stepWidth: 300,
                                            child: IntrinsicHeight(
                                              child: Container(
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: AppColors.whiteColor,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Form(
                                                      key: formKey,
                                                      child: AppTextField(
                                                        key: ValueKey(
                                                          selectedType,
                                                        ),
                                                        controller:
                                                            dialogController,
                                                        hintText: "Edit Price",
                                                        text: "Edit Price",
                                                        isTextavailable: true,
                                                        textInputType:
                                                            TextInputType
                                                                .number,
                                                        maxline: 1,
                                                        validator: (value) {
                                                          if (value != null &&
                                                              value
                                                                  .isNotEmpty &&
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

                                                    SizedBox(height: 24),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        CustomButton(
                                                          title: "Cancel",
                                                          route:
                                                              () => Get.back(),
                                                          color:
                                                              AppColors
                                                                  .containerColor,
                                                          fontcolor:
                                                              AppColors
                                                                  .blackColor,
                                                          height: 5.h,
                                                          width: 27.w,
                                                          fontsize: 15.sp,
                                                          radius: 12.0,
                                                        ),

                                                        CustomButton(
                                                          title: "Edit Price",
                                                          route: () async {
                                                            if (dialogController
                                                                .text
                                                                .trim()
                                                                .isEmpty)
                                                              return;

                                                            final enteredPrice =
                                                                double.tryParse(
                                                                  dialogController
                                                                      .text
                                                                      .trim(),
                                                                );
                                                            if (enteredPrice ==
                                                                null) {
                                                              showCustomErrorSnackbar(
                                                                title:
                                                                    "Invalid Input",
                                                                message:
                                                                    "Please enter a valid price.",
                                                              );
                                                              return;
                                                            }

                                                            // ✅ Update local UI immediately
                                                            setState(() {
                                                              currentPrice =
                                                                  enteredPrice;
                                                              if (selectedVariant !=
                                                                  null) {
                                                                selectedVariant!
                                                                        .price =
                                                                    enteredPrice
                                                                        .toString();
                                                              } else {
                                                                productDetails
                                                                        ?.price =
                                                                    enteredPrice
                                                                        .toString();
                                                              }
                                                            });

                                                            // ✅ Save / Sync (handles both online and offline)
                                                            await CartService().updateProductPrice(
                                                              price:
                                                                  enteredPrice,
                                                              productId:
                                                                  selectedVariationId ??
                                                                  int.parse(
                                                                    widget
                                                                        .productId
                                                                        .toString(),
                                                                  ),
                                                              userId: int.parse(
                                                                customerId
                                                                    .toString(),
                                                              ),
                                                            );

                                                            // ✅ Update cached product details (for offline viewing)
                                                            var box =
                                                                HiveService()
                                                                    .getProductDetailsBox();
                                                            final cachedData =
                                                                box.get(
                                                                  'productDetails${widget.productId}',
                                                                );
                                                            if (cachedData !=
                                                                null) {
                                                              final data = json
                                                                  .decode(
                                                                    cachedData,
                                                                  );

                                                              // Update base price or variant price in cache
                                                              if (selectedVariationId !=
                                                                      null &&
                                                                  data['all_variations'] !=
                                                                      null) {
                                                                for (var variant
                                                                    in data['all_variations']) {
                                                                  if (variant['id'] ==
                                                                      selectedVariationId) {
                                                                    variant['price'] =
                                                                        enteredPrice
                                                                            .toString();
                                                                  }
                                                                }
                                                              } else {
                                                                data['price'] =
                                                                    enteredPrice
                                                                        .toString();
                                                              }

                                                              await box.put(
                                                                'productDetails${widget.productId}',
                                                                json.encode(
                                                                  data,
                                                                ),
                                                              );
                                                            }

                                                            // ✅ Close dialogs and refresh product data
                                                            Get.back();
                                                            Get.back();
                                                            Get.back();
                                                            Get.to(
                                                              () => ProductDetailsScreen(
                                                                productId:
                                                                    widget
                                                                        .productId,
                                                                isVariation:
                                                                    widget
                                                                        .isVariation,
                                                                id: widget.id,
                                                                cate:
                                                                    widget.cate,
                                                                slug:
                                                                    widget.slug,
                                                              ),
                                                            );

                                                            _fetchProductDetails();
                                                          },
                                                          color:
                                                              AppColors
                                                                  .mainColor,
                                                          fontcolor:
                                                              AppColors
                                                                  .whiteColor,
                                                          height: 5.h,
                                                          width: 40.w,
                                                          fontsize: 15.sp,
                                                          radius: 12.0,
                                                          iconData: Icons.check,
                                                          iconsize: 17.sp,
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
                                    barrierDismissible: true,
                                  );
                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: AppColors.mainColor,
                                      ),
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
                          Container(
                            alignment: Alignment.center,
                            child: CustomButton(
                              title: 'Add Note',
                              route: () {
                                showItemNotesDialog(context);

                                log(
                                  'selectedVariationId :: $selectedVariationId',
                                );
                              },
                              color: AppColors.mainColor,
                              fontcolor: AppColors.whiteColor,
                              radius: isIpad ? 1.w : 3.w,
                              height: isIpad ? 7.h : 5.h,
                              fontsize: 16.sp,
                              iconData: Icons.note,
                              iconsize: 16.sp,
                              width: 85.w,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              widget.isVariation == false
                                  ? Container(
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
                                              int currentPackSize =
                                                  int.tryParse(
                                                    productDetails?.packsize ??
                                                        '0',
                                                  ) ??
                                                  0;

                                              // If first time, set the original pack size
                                              originalPackSize ??=
                                                  currentPackSize;

                                              // Subtract the original pack size (e.g., 6 → 4 → 2)
                                              currentPackSize -=
                                                  originalPackSize!;

                                              // Prevent going below 0
                                              if (currentPackSize <
                                                  originalPackSize!) {
                                                currentPackSize =
                                                    originalPackSize!;
                                              }

                                              // Update productDetails
                                              productDetails?.packsize =
                                                  currentPackSize.toString();

                                              print(
                                                "Decrement → currentPackSize = $currentPackSize",
                                              );
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
                                              print(
                                                "Before: productDetails?.packsize = ${productDetails?.packsize}",
                                              );

                                              // Convert current pack size
                                              int currentPackSize =
                                                  int.tryParse(
                                                    productDetails?.packsize ??
                                                        '0',
                                                  ) ??
                                                  0;

                                              // If first time, save original pack size
                                              originalPackSize ??=
                                                  currentPackSize;

                                              // Add only the original pack size (e.g., 2 + 2 = 4, then 4 + 2 = 6)
                                              currentPackSize +=
                                                  originalPackSize!;

                                              // Update
                                              productDetails?.packsize =
                                                  currentPackSize.toString();

                                              print(
                                                "After: currentPackSize = $currentPackSize",
                                              );
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
                                  )
                                  : productDetails?.variations?.length != 0
                                  ? Container()
                                  : Container(
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
                                              int currentPackSize =
                                                  currentqty.toInt();

                                              // If first time, set the original pack size
                                              originalPackSize ??=
                                                  currentPackSize;

                                              // Subtract the original pack size (e.g., 6 → 4 → 2)
                                              currentPackSize -=
                                                  originalPackSize!;

                                              // Prevent going below 0
                                              if (currentPackSize <
                                                  originalPackSize!) {
                                                currentPackSize =
                                                    originalPackSize!;
                                              }

                                              // Update productDetails
                                              currentqty = currentPackSize;

                                              print(
                                                "Decrement → currentPackSize = $currentPackSize",
                                              );
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
                                          currentqty.toString(),
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontFamily: FontFamily.semiBold,
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              print(
                                                "Before: productDetails?.packsize = ${productDetails?.packsize}",
                                              );

                                              // Convert current pack size
                                              int currentPackSize =
                                                  currentqty.toInt();

                                              // If first time, save original pack size
                                              originalPackSize ??=
                                                  currentPackSize;

                                              // Add only the original pack size (e.g., 2 + 2 = 4, then 4 + 2 = 6)
                                              currentPackSize +=
                                                  originalPackSize!;

                                              // Update
                                              currentqty = currentPackSize;

                                              print(
                                                "After: currentPackSize = $currentPackSize",
                                              );
                                              addOrUpdateCartItem(
                                                productId: productDetails!.id!,
                                                variationId: "",
                                                attributeKey: "",
                                                attributeValue: "",
                                                // variant.attributes?.getValue() ?? "",
                                                quantity: currentPackSize,
                                                overridePrice:
                                                    double.tryParse(
                                                      currentPackSize
                                                          .toString(),
                                                    ) ??
                                                    0.0,
                                                itemNote:
                                                    notesController.text ==
                                                                "" ||
                                                            notesController
                                                                    .text ==
                                                                null
                                                        ? ""
                                                        : notesController.text
                                                            .trim()
                                                            .toString(),
                                              );
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
                                    productDetails?.variations?.length == 0
                                        ? _addSimpleProductsToCart()
                                        : _addVariationProductsToCart();
                                    // Get.back();

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

  // 🟢 Place these at the top of your class (State)

  List<Map<String, dynamic>> cartItems = [];

  /// 🟢 Master function: Add or Update Cart Items
  void addOrUpdateCartItem({
    required int productId,
    required var variationId,
    required String attributeKey,
    required String attributeValue,
    required num quantity,
    required double overridePrice,
    String? itemNote,
  }) {
    final existingIndex = cartItems.indexWhere(
      (item) => item['variation_id'] == variationId,
    );

    if (existingIndex != -1) {
      // 🔹 Update existing item or remove if qty = 0
      if (quantity <= 0) {
        cartItems.removeAt(existingIndex);
      } else {
        cartItems[existingIndex]['quantity'] = quantity;
        cartItems[existingIndex]['override_price'] = overridePrice;
        cartItems[existingIndex]['item_note'] = itemNote ?? "Default price";
      }
    } else if (quantity > 0) {
      // 🔹 Add new item
      cartItems.add({
        "product_id": productId,
        "variation_id": variationId,
        "variation": {attributeKey: attributeValue},
        "quantity": quantity,
        "item_note": itemNote ?? "Default price",
        "override_price": overridePrice,
      });
    }

    // 🟢 Print cart JSON for debugging
    log("🛒 Updated Cart => ${jsonEncode({"items": cartItems})}");
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
    if (!mounted) return;
    setState(() {
      isAddingToCart = true;
    });
    final cartService = CartService();

    try {
      final response = await cartService.addToCart(
        items: cartItems,
        // productId: int.parse(widget.productId ?? ''),
        // variationId: selectedVariationId,
        // variation: {
        //   "attribute_${selectedAttributeKey ?? ''}":
        //       selectedAttributeValue ?? '',
        // },
        // quantity: currentqty.toInt(),
        // itemNote: notesController.text.trim().toString(),
      );

      if (response != null && response.statusCode == 200) {
        // showCustomSuccessSnackbar(
        //   title: "Added to Cart",
        //   message: "This product has been successfully added to your cart.",
        // );
        if (!mounted) return;
        setState(() {
          isAddingToCart = false;
          // quantity = 1;
        });
        Get.back();
        Get.back();

        Get.to(
          ProductsScreen(id: widget.id, cate: widget.cate, slug: widget.slug),
        );
      } else {
        // showCustomSuccessSnackbar(
        //   title: "Offline Mode",
        //   message: "Product added offline. It will sync once internet is back.",
        // );
        if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        isAddingToCart = false;
      });
    }
  }

  Future<void> showItemNotesDialog(BuildContext context) async {
    TextEditingController notesController = TextEditingController();
    String? errorText;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
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
                    hintText: "Enter Item notes here...",
                    text: "Notes",
                    isTextavailable: true,
                    textInputType: TextInputType.multiline,
                    maxline: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter Item notes";
                      }
                      return null;
                    },
                  ),
                  if (errorText != null) ...[
                    SizedBox(height: 8),
                    Text(
                      errorText!,
                      style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    ),
                  ],
                ],
              ),
              actions: [
                CustomButton(
                  title: "Cancel",
                  route: () {
                    Get.back(); // closes dialog
                  },
                  color: AppColors.containerColor,
                  fontcolor: AppColors.blackColor,
                  height: 5.h,
                  width: 30.w,
                  fontsize: 15.sp,
                  radius: 12.0,
                ),
                CustomButton(
                  title: "Confirm",
                  route: () async {
                    if (notesController.text.trim().isEmpty) {
                      setState(() {
                        errorText = "Please enter Item notes";
                      });
                      return;
                    }

                    // 🟢 Add logic for product add
                    if (productDetails?.variations?.length == 0) {
                      _addSimpleProductsToCart();
                    } else {
                      _addVariationProductsToCart();
                    }

                    Get.back(); // close dialog
                  },
                  color: AppColors.mainColor,
                  fontcolor: AppColors.whiteColor,
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
  }

  Future<void> _addSimpleProductsToCart() async {
    if (!mounted) return;
    setState(() {
      isAddingToCart = true;
    });
    final cartService = CartService();

    try {
      final response = await cartService.addToCart1(
        // items: cartItems
        productId: int.parse(widget.productId ?? ''),
        quantity: int.parse((productDetails?.packsize).toString()),
        itemNote: notesController.text.trim().toString(),
      );

      if (response != null && response.statusCode == 200) {
        // showCustomSuccessSnackbar(
        //   title: "Added to Cart",
        //   message: "This product has been successfully added to your cart.",
        // );
        if (!mounted) return;
        setState(() {
          isAddingToCart = false;
          // quantity = 1;
        });
        Get.back();
        Get.back();
        Get.to(
          ProductsScreen(id: widget.id, cate: widget.cate, slug: widget.slug),
        );
      } else {
        // showCustomSuccessSnackbar(
        //   title: "Offline Mode",
        //   message: "Product added offline. It will sync once internet is back.",
        // );
        if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        isAddingToCart = false;
      });
    }
  }
}
