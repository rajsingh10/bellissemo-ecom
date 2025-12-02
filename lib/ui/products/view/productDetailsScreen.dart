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

import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/multipleImagesSlider.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/textFields.dart';
import '../../../utils/titlebarWidget.dart';
import '../../cart/service/cartServices.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String? productId;
  final bool? isVariation;
  final String? cate;
  final String? id;
  final String? slug;

  const ProductDetailsScreen({
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
  // 🟢 1. Defined locally to prevent showing old data from other screens
  ProductDetailsModal? productDetails;

  TextEditingController notesController = TextEditingController();
  List<String> currentImages = [];
  double currentPrice = 0.0;
  AllVariations? selectedVariant;
  int? selectedVariationId;
  String? selectedAttributeKey;
  String? selectedAttributeValue;
  bool isAddingToCart = false;
  num currentqty = 0;
  final ScrollController _detailsScrollCtrl = ScrollController();

  // Quantities for variants
  Map<int, int> variantQuantities = {};

  // Cart Logic
  List<Map<String, dynamic>> cartItems = [];
  int? originalPackSize;

  bool isIpad = 100.w >= 800;
  bool isLoading = true;

  int? customerId;
  String? customerName;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  @override
  void dispose() {
    _detailsScrollCtrl.dispose();
    notesController.dispose();
    super.dispose();
  }

  // 🟢 2. Clear old data and start loading
  Future<void> loadInitialData() async {
    setState(() {
      isLoading = true;
      productDetails = null; // Important: Clear previous data
      cartItems.clear();
      variantQuantities.clear();
    });

    try {
      await _fetchProductDetails();

      // If data loaded successfully, set defaults
      if (productDetails != null) {
        setState(() {
          _setDefaultVariant();
        });
      }
    } catch (e, stackTrace) {
      log("Error loading initial data: $stackTrace");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _loadCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customerId = prefs.getInt("customerId");
      customerName = prefs.getString("customerName");
    });
    loadInitialData();
  }

  // 🟢 3. Smart Fetch: Cache First -> Then Network
  Future<void> _fetchProductDetails() async {
    var box = HiveService().getProductDetailsBox();

    // Step A: Try to load from Cache FIRST
    final cachedData = box.get('productDetails${widget.productId}');

    if (cachedData != null) {
      log("Loading from Cache for Product: ${widget.productId}");
      try {
        final data = json.decode(cachedData);
        productDetails = ProductDetailsModal.fromJson(data);
        currentImages =
            productDetails?.images?.map((e) => e.src.toString()).toList() ?? [];
        // Optimistic UI update
        setState(() {});
      } catch (e) {
        log("Error parsing cache: $e");
      }
    }

    // Step B: Check Internet
    bool hasInternet = await checkInternet();

    if (!hasInternet) {
      if (productDetails == null) {
        // Offline AND No Cache -> This triggers the Error Widget in build()
        print("❌ No internet and no cached data found");
        showCustomErrorSnackbar(
          title: 'No Connection',
          message: 'Connect to the internet to view this product.',
        );
      } else {
        // Offline BUT Cache Exists -> User sees cached data
        showCustomErrorSnackbar(
          title: 'Offline Mode',
          message: 'Showing offline data.',
        );
      }
      return;
    }

    // Step C: If Online, Fetch Fresh Data from API
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

        // Update Cache
        await box.put('productDetails${widget.productId}', response.body);
      } else {
        // If API fails but we haven't loaded cache yet
        if (productDetails == null) {
          showCustomErrorSnackbar(
            title: 'Server Error',
            message: 'Something went wrong. Please try again later.',
          );
        }
      }
    } catch (e) {
      print("❌ Exception: $e");
      if (productDetails == null) {
        showCustomErrorSnackbar(
          title: 'Network Error',
          message: 'Unable to connect. Please check your internet.',
        );
      }
    }
  }

  void _setDefaultVariant() {
    if (productDetails != null &&
        productDetails!.allVariations != null &&
        productDetails!.allVariations!.isNotEmpty) {
      selectedVariant = productDetails!.allVariations?.first;
      currentPrice = double.tryParse(selectedVariant?.price ?? '0') ?? 0.0;
      currentqty = num.parse(selectedVariant?.packSize ?? '0');
      selectedVariationId = selectedVariant?.id;
      selectedAttributeKey = selectedVariant?.attributes?.getKey();
      selectedAttributeValue = selectedVariant?.attributes?.getValue();
    } else if (productDetails != null) {
      // Simple product default
      currentPrice = double.tryParse(productDetails!.price ?? '0') ?? 0.0;
      currentqty = num.parse(productDetails!.packsize ?? '0');
    }
  }

  String htmlToPlainText(String html) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    String text = html.replaceAll(regex, '');
    text = text.replaceAllMapped(RegExp(r'[^\S\r\n]+'), (match) => ' ');
    text = text.split('\n').map((line) => line.trim()).join('\n');
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body:
          isLoading
              ? Loader()
              : productDetails == null
              ? _buildNoDataWidget() // 🟢 4. Show this if loading done but no data
              : Stack(
                children: [
                  Scrollbar(
                    controller: _detailsScrollCtrl,
                    thumbVisibility: true,
                    trackVisibility: isIpad,
                    interactive: true,
                    thickness: isIpad ? 8 : 6,
                    radius: const Radius.circular(12),
                    child: SingleChildScrollView(
                      controller: _detailsScrollCtrl,
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

                            Stack(
                              children: [
                                ImageSlider(
                                  imageUrls: currentImages,
                                  height: isIpad ? 50.h : 25.h,
                                  autoScroll: false,
                                  onImageTap: (index) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (context) {
                                        return Dialog(
                                          backgroundColor: AppColors.blackColor
                                              .withValues(alpha: 0.0),
                                          insetPadding: EdgeInsets.zero,
                                          child: FullScreenImageDialog(
                                            images: currentImages,
                                            initialIndex: index,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
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

                            // Variation Logic
                            if (productDetails?.variations?.isNotEmpty ??
                                false) ...[
                              SizedBox(height: 1.h),
                              Text(
                                "Product Variants :",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.gray,
                                  fontFamily: FontFamily.regular,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              _buildVariationList(),
                            ],

                            SizedBox(height: 1.h),

                            // Price Edit Section
                            _buildPriceSection(),

                            SizedBox(height: 1.h),

                            ReadMoreText(
                              htmlToPlainText(
                                productDetails?.description ?? '',
                              ),
                              trimLines: 10,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontFamily: FontFamily.regular,
                                color: AppColors.gray,
                                height: 1.4,
                              ),
                              colorClickableText: AppColors.mainColor,
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

                            // Add Note Button
                            Container(
                              alignment: Alignment.center,
                              child: CustomButton(
                                title: 'Add Note',
                                route: () {
                                  showItemNotesDialog(context);
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

                            // Bottom Row (Qty & Add to Cart)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Simple Product Qty
                                if (widget.isVariation == false)
                                  _buildSimpleProductQtyControl()
                                // Variation Product Qty (Usually handled inside variation list, but keeping structure)
                                else if ((productDetails?.variations?.length ??
                                        0) ==
                                    0)
                                  _buildSimpleProductQtyControl(),

                                // Fallback for data mismatch
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: CustomButton(
                                    title: 'Add to cart',
                                    route: () {
                                      if (productDetails?.variations?.length ==
                                          0) {
                                        _addSimpleProductsToCart();
                                      } else {
                                        _addVariationProductsToCart();
                                      }
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

  // 🟢 5. New Widget for "Offline & No Data"
  Widget _buildNoDataWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        children: [
          SizedBox(height: 5.h), // Top padding
          TitleBar(
            title: 'Product Details',
            isDrawerEnabled: true,
            isBackEnabled: true,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, size: 15.w, color: AppColors.gray),
                SizedBox(height: 2.h),
                Text(
                  "No Product Data Available",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: FontFamily.bold,
                    color: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  "You are offline and this product hasn't been cached. Please check your internet connection.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.regular,
                    color: AppColors.gray,
                  ),
                ),
                SizedBox(height: 3.h),
                CustomButton(
                  title: 'Retry',
                  route: () {
                    loadInitialData();
                  },
                  color: AppColors.mainColor,
                  fontcolor: AppColors.whiteColor,
                  radius: 12.0,
                  height: 5.h,
                  width: 40.w,
                  fontsize: 16.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            productDetails!.allVariations!.map((variant) {
              final isSelected = selectedVariant?.id == variant.id;
              final variantImage =
                  variant.images!.isNotEmpty ? variant.images!.first.src : '';
              final variantName = variant.attributes?.getValue();
              final int variantQty =
                  (variantQuantities[variant.id] ?? 0).toInt();

              // Responsive sizing
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              final cardWidth = screenWidth * (isIpad ? 0.25 : 0.35);
              final borderRadius = screenWidth * 0.035;
              final fontSize = screenWidth * 0.035;
              final iconSize = screenWidth * (isIpad ? 0.025 : 0.045);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedVariant = variant;
                    selectedVariationId = variant.id;
                    selectedAttributeKey = variant.attributes?.getKey();
                    selectedAttributeValue = variant.attributes?.getValue();

                    currentImages =
                        variant.images != null && variant.images!.isNotEmpty
                            ? variant.images!
                                .map((img) => img.src ?? '')
                                .where((e) => e.isNotEmpty)
                                .toList()
                            : [];

                    currentPrice = double.tryParse(variant.price ?? '0') ?? 0.0;
                    variantQuantities.putIfAbsent(variant.id!, () => 0);
                  });
                },
                child: Container(
                  width: cardWidth,
                  margin: EdgeInsets.only(right: screenWidth * 0.025),
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(borderRadius),
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
                        blurRadius: screenWidth * 0.02,
                        offset: Offset(0, screenHeight * 0.002),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              size: iconSize,
                              color: Colors.grey,
                            ),
                          ),
                      SizedBox(height: 0.5.h),
                      Text(
                        variantName ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: FontFamily.bold,
                          color: AppColors.blackColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 0.5.h),

                      // Qty Control
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(90),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _updateVariantQty(variant, -1),
                              child: Icon(
                                Icons.remove,
                                size: iconSize,
                                color:
                                    variantQty == 0
                                        ? Colors.grey
                                        : AppColors.blackColor,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              variantQty.toString(),
                              style: TextStyle(
                                fontSize: fontSize * (isIpad ? 0.5 : 0.75),
                                fontFamily: FontFamily.semiBold,
                                color: AppColors.blackColor,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            GestureDetector(
                              onTap: () => _updateVariantQty(variant, 1),
                              child: Icon(
                                Icons.add,
                                size: iconSize,
                                color: AppColors.blackColor,
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
    );
  }

  void _updateVariantQty(AllVariations variant, int multiplier) {
    setState(() {
      int currentPackSize = variantQuantities[variant.id!] ?? 0;
      final int originalPackSize = int.tryParse(variant.packSize ?? '0') ?? 0;

      // Logic: add or subtract the packsize
      if (multiplier > 0) {
        currentPackSize += originalPackSize;
      } else {
        currentPackSize -= originalPackSize;
        if (currentPackSize < 0) currentPackSize = 0;
      }

      variantQuantities[variant.id!] = currentPackSize;

      addOrUpdateCartItem(
        productId: productDetails!.id!,
        variationId: variant.id!,
        attributeKey: variant.attributes?.getKey() ?? "attribute_pa_color",
        attributeValue: variant.attributes?.getValue() ?? "",
        quantity: currentPackSize,
        overridePrice: double.tryParse(variant.price ?? '0') ?? 0.0,
        itemNote:
            notesController.text.isEmpty ? "" : notesController.text.trim(),
      );
    });
  }

  Widget _buildSimpleProductQtyControl() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                int currentPackSize = currentqty.toInt();
                originalPackSize ??= currentPackSize;

                currentPackSize -= originalPackSize!;
                if (currentPackSize < originalPackSize!) {
                  currentPackSize = originalPackSize!;
                }
                currentqty = currentPackSize;
                productDetails?.packsize = currentPackSize.toString();
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
            style: TextStyle(fontSize: 17.sp, fontFamily: FontFamily.semiBold),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () {
              setState(() {
                int currentPackSize = currentqty.toInt();
                originalPackSize ??= currentPackSize;

                currentPackSize += originalPackSize!;
                currentqty = currentPackSize;
                productDetails?.packsize = currentPackSize.toString();
              });
            },
            child: CircleAvatar(
              radius: isIpad ? 15.sp : 16,
              backgroundColor: Colors.transparent,
              child: Icon(Icons.add, size: 18.sp, color: AppColors.blackColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return InkWell(
      onTap: () => _showEditPriceDialog(),
      child: Container(
        child: Row(
          children: [
            Icon(Icons.edit, color: AppColors.mainColor),
            Text(
              "${productDetails?.currencySymbol ?? ''}${(selectedVariant != null ? selectedVariant!.price : productDetails?.price) ?? ''}",
              style: TextStyle(
                fontSize: 20.sp,
                fontFamily: FontFamily.bold,
                color: AppColors.mainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditPriceDialog() async {
    final formKey = GlobalKey<FormState>();
    TextEditingController dialogController = TextEditingController();

    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: IntrinsicWidth(
          stepWidth: 300,
          child: IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Edit Price",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: FontFamily.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Form(
                    key: formKey,
                    child: AppTextField(
                      controller: dialogController,
                      hintText: "Enter New Price",
                      text: "New Price",
                      isTextavailable: true,
                      textInputType: TextInputType.number,
                      maxline: 1,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            double.tryParse(value) == null) {
                          return "Enter a valid number";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        title: "Cancel",
                        route: () => Get.back(),
                        color: AppColors.containerColor,
                        fontcolor: AppColors.blackColor,
                        height: 5.h,
                        width: 27.w,
                        fontsize: 15.sp,
                        radius: 12.0,
                      ),
                      CustomButton(
                        title: "Update",
                        route: () async {
                          if (dialogController.text.trim().isEmpty) return;

                          final enteredPrice = double.tryParse(
                            dialogController.text.trim(),
                          );
                          if (enteredPrice == null) return;

                          setState(() {
                            if (selectedVariant != null) {
                              selectedVariant!.price = enteredPrice.toString();
                            } else {
                              productDetails?.price = enteredPrice.toString();
                            }
                          });

                          // Update Backend
                          await CartService().updateProductPrice(
                            price: enteredPrice,
                            productId:
                                selectedVariationId ??
                                int.parse(widget.productId!),
                            userId: customerId ?? 0,
                          );

                          Get.back(); // close dialog
                        },
                        color: AppColors.mainColor,
                        fontcolor: AppColors.whiteColor,
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
        ),
      ),
      barrierDismissible: true,
    );
  }

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
      if (quantity <= 0) {
        cartItems.removeAt(existingIndex);
      } else {
        cartItems[existingIndex]['quantity'] = quantity;
        cartItems[existingIndex]['override_price'] = overridePrice;
        cartItems[existingIndex]['item_note'] = itemNote ?? "Default price";
      }
    } else if (quantity > 0) {
      cartItems.add({
        "product_id": productId,
        "variation_id": variationId,
        "variation": {attributeKey: attributeValue},
        "quantity": quantity,
        "item_note": itemNote ?? "Default price",
        "override_price": overridePrice,
      });
    }
    log("🛒 Updated Cart => ${jsonEncode({"items": cartItems})}");
  }

  Future<void> _addVariationProductsToCart() async {
    if (!mounted) return;
    setState(() => isAddingToCart = true);

    try {
      final response = await CartService().addToCart(items: cartItems);

      if (response != null && response.statusCode == 200) {
        if (!mounted) return;
        setState(() => isAddingToCart = false);
        Get.back();
        Get.back();
        Get.to(
          ProductsScreen(id: widget.id, cate: widget.cate, slug: widget.slug),
        );
      } else {
        if (!mounted) return;
        setState(() => isAddingToCart = false);
      }
    } catch (e) {
      showCustomErrorSnackbar(
        title: "Error",
        message: "Something went wrong while adding product.\n$e",
      );
      if (!mounted) return;
      setState(() => isAddingToCart = false);
    }
  }

  Future<void> _addSimpleProductsToCart() async {
    if (!mounted) return;
    setState(() => isAddingToCart = true);

    try {
      final response = await CartService().addToCart1(
        productId: int.parse(widget.productId ?? ''),
        quantity: int.parse((productDetails?.packsize).toString()),
        itemNote: notesController.text.trim().toString(),
      );

      if (response != null && response.statusCode == 200) {
        if (!mounted) return;
        setState(() => isAddingToCart = false);
        Get.back();
        Get.back();
        Get.to(
          ProductsScreen(id: widget.id, cate: widget.cate, slug: widget.slug),
        );
      } else {
        if (!mounted) return;
        setState(() => isAddingToCart = false);
      }
    } catch (e) {
      showCustomErrorSnackbar(
        title: "Error",
        message: "Something went wrong while adding product.\n$e",
      );
      if (!mounted) return;
      setState(() => isAddingToCart = false);
    }
  }

  Future<void> showItemNotesDialog(BuildContext context) async {
    TextEditingController tempNotesController = TextEditingController(
      text: notesController.text,
    );
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
                    controller: tempNotesController,
                    hintText: "Enter Item notes here...",
                    text: "Notes",
                    isTextavailable: true,
                    textInputType: TextInputType.multiline,
                    maxline: 4,
                  ),
                ],
              ),
              actions: [
                CustomButton(
                  title: "Cancel",
                  route: () => Get.back(),
                  color: AppColors.containerColor,
                  fontcolor: AppColors.blackColor,
                  height: 5.h,
                  width: 30.w,
                  fontsize: 15.sp,
                  radius: 12.0,
                ),
                CustomButton(
                  title: "Save",
                  route: () {
                    // Save to main controller
                    notesController.text = tempNotesController.text;
                    Get.back();
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
}
