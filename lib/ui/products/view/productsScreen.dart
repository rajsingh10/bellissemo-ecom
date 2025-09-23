import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/ui/products/modal/categoryWiseProductsModal.dart';
import 'package:bellissemo_ecom/ui/products/view/productDetailsScreen.dart';
import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/customBottombar.dart';
import 'package:bellissemo_ecom/utils/emptyWidget.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:bellissemo_ecom/utils/searchFields.dart';
import 'package:bellissemo_ecom/utils/snackBars.dart';
import 'package:bellissemo_ecom/utils/titlebarWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../cart/service/cartServices.dart';
import '../provider/productsProvider.dart';

class ProductsScreen extends StatefulWidget {
  String? cate;
  String? id;

  ProductsScreen({super.key, required this.cate, required this.id});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int itemsPerPage = 4;
  int currentPage = 0;

  int _getCrossAxisCount(BuildContext context) {
    if (100.w >= 800) {
      return 4;
    } else {
      return 2;
    }
  }

  final List<int> itemsPerPageOptions = [4, 8, 12, 16];
  List<CategoryWiseProductsModal> filteredProducts = [];
  List<CategoryWiseProductsModal> categoryWiseProductsList = [];

  String selectedSort = "Low to High";
  final List<String> sortOptions = ["Low to High", "High to Low", "Latest"];

  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();
  bool isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    itemsPerPage = isIpad ? 8 : 4;
    loadInitialData(); // instead of dummy products
    searchController.addListener(() {
      _filterProducts(searchController.text);
    });
  }

  bool isLoading = true;

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);

    // Load cached data first for immediate display
    _loadCachedData();

    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([_fetchProducts().then((_) => setState(() {}))]);
    } catch (e) {
      log("Error loading initial data: $e");
    } finally {
      stopwatch.stop();
      log("All API calls completed in ${stopwatch.elapsed.inMilliseconds} ms");
      setState(() => isLoading = false);
    }
  }

  void _loadCachedData() {
    var productsBox = HiveService().getCategoryProductsBox();
    final cachedProducts = productsBox.get('products');
    if (cachedProducts != null) {
      final List data = json.decode(cachedProducts);
      categoryWiseProductsList =
          data.map((e) => CategoryWiseProductsModal.fromJson(e)).toList();

      _filterProducts(); // 👈 refresh filtered list
    }

    setState(() {});
  }

  void _filterProducts([String query = ""]) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List.from(categoryWiseProductsList);
      } else {
        filteredProducts =
            categoryWiseProductsList.where((p) {
              final name = p.name?.toLowerCase() ?? "";
              final packSize = p.packSize?.toLowerCase() ?? "";
              return name.contains(query.toLowerCase()) ||
                  packSize.contains(query.toLowerCase());
            }).toList();
      }

      if (selectedSort == "Low to High") {
        filteredProducts.sort((a, b) => a.price!.compareTo(b.price!));
      } else if (selectedSort == "High to Low") {
        filteredProducts.sort((a, b) => b.price!.compareTo(a.price!));
      }
      currentPage = 0;
    });
  }

  Map<int, int> quantities = {};

  @override
  Widget build(BuildContext context) {
    int startIndex = currentPage * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage).clamp(
      0,
      filteredProducts.length,
    );
    List<CategoryWiseProductsModal> currentPageProducts = filteredProducts
        .sublist(startIndex, endIndex);
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body:
          isLoading
              ? Loader()
              : Stack(
                children: [
                  Column(
                    children: [
                      TitleBar(
                        title:
                            widget.cate == null
                                ? 'Products'
                                : widget.cate.toString(),
                        isDrawerEnabled: true,
                        isSearchEnabled: true,
                        isBackEnabled: true,
                        onSearch: () {
                          setState(() {
                            isSearchEnabled = !isSearchEnabled;
                          });
                        },
                      ),
                      isSearchEnabled
                          ? SearchField(controller: searchController)
                          : SizedBox.shrink(),
                      SizedBox(height: 1.h),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: ClampingScrollPhysics(),
                          child: Column(
                            children: [
                              if (filteredProducts.isNotEmpty)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Sort by",
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontFamily: FontFamily.semiBold,
                                              color: AppColors.blackColor,
                                            ),
                                          ),
                                          SizedBox(width: 3.w),
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: selectedSort,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              dropdownColor: Colors.white,
                                              icon: Icon(
                                                Icons.sort,
                                                color: AppColors.mainColor,
                                              ),
                                              items:
                                                  sortOptions.map((e) {
                                                    return DropdownMenuItem(
                                                      value: e,
                                                      child: Text(
                                                        e,
                                                        style: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontFamily:
                                                              FontFamily
                                                                  .semiBold,
                                                          color:
                                                              AppColors
                                                                  .mainColor,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    selectedSort = value;
                                                    _filterProducts();
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Items per page",
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontFamily: FontFamily.semiBold,
                                              color: AppColors.blackColor,
                                            ),
                                          ),
                                          SizedBox(width: 3.w),

                                          // Modern Dropdown
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton<int>(
                                              value: itemsPerPage,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              dropdownColor: Colors.white,
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontFamily: FontFamily.regular,
                                                color: AppColors.blackColor,
                                              ),
                                              icon: Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color: AppColors.mainColor,
                                              ),
                                              items:
                                                  itemsPerPageOptions.map((e) {
                                                    return DropdownMenuItem(
                                                      value: e,
                                                      child: Text(
                                                        e.toString(),
                                                        style: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontFamily:
                                                              FontFamily
                                                                  .semiBold,
                                                          color:
                                                              AppColors
                                                                  .mainColor,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    itemsPerPage = value;
                                                    currentPage = 0;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 1.h),
                              filteredProducts.isEmpty
                                  ? Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15.h,
                                    ),
                                    child: emptyWidget(
                                      icon: Icons.production_quantity_limits,
                                      text: 'Products',
                                    ),
                                  )
                                  : Column(
                                    children: [
                                      GridView.count(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics: ClampingScrollPhysics(),
                                        crossAxisCount: _getCrossAxisCount(
                                          context,
                                        ),
                                        childAspectRatio: 0.75,
                                        mainAxisSpacing: 1.h,
                                        crossAxisSpacing: 2.w,
                                        children:
                                            currentPageProducts
                                                .map((p) => _buildGridItem(p))
                                                .toList(),
                                      ),
                                      SizedBox(height: 2.h),
                                      // Pagination Section
                                      if (filteredProducts.length >
                                          itemsPerPage)
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 2.h),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Previous Button
                                              InkWell(
                                                onTap:
                                                    currentPage > 0
                                                        ? () {
                                                          setState(
                                                            () => currentPage--,
                                                          );
                                                          scrollController
                                                              .animateTo(
                                                                0,
                                                                duration: Duration(
                                                                  milliseconds:
                                                                      300,
                                                                ),
                                                                curve:
                                                                    Curves
                                                                        .easeOut,
                                                              );
                                                        }
                                                        : null,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                    isIpad ? 1.2.w : 1.5.w,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        currentPage > 0
                                                            ? AppColors
                                                                .mainColor
                                                            : Colors
                                                                .grey
                                                                .shade300,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.arrow_back_ios_new,
                                                    size:
                                                        isIpad ? 15.sp : 18.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(width: 4.w),

                                              // Page Indicator
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 4.w,
                                                  vertical: 0.8.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Text(
                                                  "Page ${currentPage + 1}",
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontFamily:
                                                        FontFamily.semiBold,
                                                    color: AppColors.blackColor,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(width: 4.w),

                                              // Next Button
                                              InkWell(
                                                onTap:
                                                    endIndex <
                                                            filteredProducts
                                                                .length
                                                        ? () {
                                                          setState(
                                                            () => currentPage++,
                                                          );
                                                          scrollController
                                                              .animateTo(
                                                                0,
                                                                duration: Duration(
                                                                  milliseconds:
                                                                      300,
                                                                ),
                                                                curve:
                                                                    Curves
                                                                        .easeOut,
                                                              );
                                                        }
                                                        : null,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                    isIpad ? 1.2.w : 1.5.w,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        endIndex <
                                                                filteredProducts
                                                                    .length
                                                            ? AppColors
                                                                .mainColor
                                                            : Colors
                                                                .grey
                                                                .shade300,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    size:
                                                        isIpad ? 15.sp : 18.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
                  if (isAddingToCart)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: Loader(),
                    ),
                ],
              ),
      bottomNavigationBar: SizedBox(
        height: isIpad ? 14.h : 10.h,
        child: CustomBar(selected: 8),
      ),
    );
  }

  bool isIpad = 100.w >= 800;

  Widget _buildGridItem(CategoryWiseProductsModal product) {
    return InkWell(
      onTap:
          product.stockStatus == 'instock'
              ? () {
                Get.to(
                  () => ProductDetailsScreen(productId: product.id.toString()),
                  transition: Transition.leftToRightWithFade,
                  duration: const Duration(milliseconds: 450),
                );
              }
              : () {
                showCustomErrorSnackbar(
                  title: "Out of Stock",
                  message: "${product.name} is not available right now!",
                );
              },
      child: Opacity(
        opacity: product.stockStatus == 'instock' ? 1.0 : 0.4,
        child: Card(
          color: AppColors.cardBgColor2,
          elevation: 3,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.border),
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
                        imageUrl:
                            (product.images?.length == 0)
                                ? ''
                                : product.images?[0].src ?? '',
                        height: double.infinity,
                        width: double.infinity,
                        isFit: true,
                        radius: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap:
                                    (product.stockStatus == 'instock')
                                        ? () {
                                          _removeProductFromCart(
                                            product.id ?? 0,
                                          );
                                        }
                                        : null,
                                child: Container(
                                  padding:
                                      isIpad
                                          ? EdgeInsets.all(1.w)
                                          : EdgeInsets.all(1.5.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: isIpad ? 15.sp : 20.sp,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    (product.stockStatus == 'instock')
                                        ? () {
                                          product.variations?.length == 0
                                              ? _addSimpleProductsToCart(
                                                product.id,
                                              )
                                              : _addVariationProductsToCart(
                                                product.id,
                                                product.firstVariation?.id,
                                                product
                                                    .firstVariation
                                                    ?.varAttributes
                                                    ?.getKey(),
                                                product
                                                    .firstVariation
                                                    ?.varAttributes
                                                    ?.getValue(),
                                              );
                                        }
                                        : null,
                                child: Container(
                                  padding:
                                      isIpad
                                          ? EdgeInsets.all(1.w)
                                          : EdgeInsets.all(1.5.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: isIpad ? 15.sp : 20.sp,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ),
                            ],
                          ).paddingSymmetric(horizontal: 1.w),
                          SizedBox(height: 0.5.h),
                        ],
                      ),
                      if (!(product.stockStatus == 'instock'))
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.4),
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
                      product.name ?? '',
                      style: TextStyle(
                        fontFamily: FontFamily.bold,
                        fontSize: 15.sp,
                        color: AppColors.blackColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),

                    // Pack Size + Price Row
                    product.variations?.length == 0 ||
                            product.variations == null
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            isIpad
                                ? Text(
                                  product.packSize == ""
                                      ? 'Pack : 1 Item'
                                      : 'Pack : ${product.packSize} Items',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: FontFamily.regular,
                                    color: AppColors.gray,
                                  ),
                                )
                                : Text(
                                  product.packSize == ""
                                      ? 'Pack size : 1 Item'
                                      : 'Pack size : ${product.packSize} Items',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: FontFamily.regular,
                                    color: AppColors.gray,
                                  ),
                                ),
                            Text(
                              "${product.currencySymbol} ${product.price}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: FontFamily.semiBold,
                                color: AppColors.mainColor,
                              ),
                            ),
                          ],
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pack size : ${product.firstVariation?.packSize} Items',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: FontFamily.regular,
                                color: AppColors.gray,
                              ),
                            ),
                            Text(
                              "£${product.firstVariation?.price}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: FontFamily.semiBold,
                                color: AppColors.mainColor,
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

  Future<void> _fetchProducts() async {
    var box = HiveService().getCategoryProductsBox();

    if (!await checkInternet()) {
      final cachedData = box.get('categoryProducts_${widget.id}');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        categoryWiseProductsList =
            data
                .map<CategoryWiseProductsModal>(
                  (e) => CategoryWiseProductsModal.fromJson(e),
                )
                .toList();

        _filterProducts(); // 👈 refresh filtered list
      } else {
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
      }
      return;
    }

    try {
      final response = await ProductsProvider().categoryWiseProductsApi(
        widget.id,
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        categoryWiseProductsList =
            data
                .map<CategoryWiseProductsModal>(
                  (e) => CategoryWiseProductsModal.fromJson(e),
                )
                .toList();

        await box.put('categoryProducts_${widget.id}', response.body);

        _filterProducts(); // 👈 refresh filtered list after fetch
      } else {
        final cachedData = box.get('categoryProducts_${widget.id}');
        if (cachedData != null) {
          final List data = json.decode(cachedData);
          categoryWiseProductsList =
              data
                  .map<CategoryWiseProductsModal>(
                    (e) => CategoryWiseProductsModal.fromJson(e),
                  )
                  .toList();
          _filterProducts(); // 👈 refresh here also
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      final cachedData = box.get('categoryProducts_${widget.id}');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        categoryWiseProductsList =
            data
                .map<CategoryWiseProductsModal>(
                  (e) => CategoryWiseProductsModal.fromJson(e),
                )
                .toList();
        _filterProducts(); // 👈 refresh here too
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }

  Future<void> _addVariationProductsToCart(
    id,
    variationId,
    variationKey,
    variationValue,
  ) async {
    setState(() {
      isAddingToCart = true;
    });
    final cartService = CartService();

    try {
      final response = await cartService.addToCart(
        productId: int.parse(id.toString()),
        variationId: variationId,
        variation: {"attribute_${variationKey ?? ''}": variationValue ?? ''},
        quantity: 1,
        itemNote: '',
      );

      if (response != null && response.statusCode == 200) {
        showCustomSuccessSnackbar(
          title: "Added to Cart",
          message: "This product has been successfully added to your cart.",
        );
        setState(() {
          isAddingToCart = false;
        });
      } else {
        showCustomSuccessSnackbar(
          title: "Offline Mode",
          message: "Product added offline. It will sync once internet is back.",
        );
        setState(() {
          isAddingToCart = false;
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

  Future<void> _addSimpleProductsToCart(id) async {
    setState(() {
      isAddingToCart = true;
    });
    final cartService = CartService();

    try {
      final response = await cartService.addToCart(
        productId: int.parse(id.toString()),
        quantity: 1,
        itemNote: '',
      );

      if (response != null && response.statusCode == 200) {
        showCustomSuccessSnackbar(
          title: "Added to Cart",
          message: "This product has been successfully added to your cart.",
        );
        setState(() {
          isAddingToCart = false;
        });
      } else {
        showCustomSuccessSnackbar(
          title: "Offline Mode",
          message: "Product added offline. It will sync once internet is back.",
        );
        setState(() {
          isAddingToCart = false;
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

  Future<void> _removeProductFromCart(int productId) async {
    setState(() => isAddingToCart = true);

    final cartService = CartService();

    try {
      final response = await cartService.decreaseCartItem(productId: productId);

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        final message = data["message"] ?? "Product quantity removed.";
        showCustomSuccessSnackbar(title: "Cart", message: "$message");
      } else if (response != null && response.statusCode == 204) {
        showCustomErrorSnackbar(
          title: "Cart Empty",
          message: "No items in cart to remove.",
        );
      } else {
        showCustomSuccessSnackbar(
          title: "Offline Mode",
          message:
              "Cart update saved offline. It will sync once internet is back.",
        );
      }
    } catch (e) {
      showCustomErrorSnackbar(
        title: "Error",
        message: "Something went wrong while updating cart.\n$e",
      );
      log('Error : $e');
    } finally {
      setState(() => isAddingToCart = false);
    }
  }
}
