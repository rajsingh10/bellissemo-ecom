import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/ui/category/modal/fetchSubCategoriesModal.dart';
import 'package:bellissemo_ecom/ui/products/modal/categoryWiseProductsModal.dart';
import 'package:bellissemo_ecom/ui/products/view/productDetailsScreen.dart';
import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/customBottombar.dart';
import 'package:bellissemo_ecom/utils/emptyWidget.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:bellissemo_ecom/utils/searchFields.dart';
import 'package:bellissemo_ecom/utils/snackBars.dart';
import 'package:bellissemo_ecom/utils/titlebarWidget.dart';
import 'package:bellissemo_ecom/utils/verticleBar.dart'; // Make sure this import is correct
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../apiCalling/apiConfigs.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/customButton.dart';
import '../../../utils/downloader.dart';
import '../../cart/service/cartServices.dart';
import '../../category/provider/categoriesProvider.dart';
import '../modal/fetchPdfFileModal.dart';
import '../provider/productsProvider.dart';

class ProductsScreen extends StatefulWidget {
  String? cate;
  String? id;
  String? slug;

  ProductsScreen({
    super.key,
    required this.cate,
    required this.id,
    required this.slug,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int itemsPerPage = 3;
  List<int> itemsPerPageOptions = [3, 4, 5, 6];
  List<CategoryWiseProductsModal> filteredProducts = [];
  List<CategoryWiseProductsModal> categoryWiseProductsList = [];
  bool isFilter = false;
  List<FetchSubCategoriesModal> subCategoriesList = [];
  String selectedSort = "Low to High";
  final List<String> sortOptions = ["Low to High", "High to Low", "Latest"];
  List<String> selectedFilters = [];
  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();
  bool isAddingToCart = false;
  String? customerName;
  int? customerId;
  Orientation? _lastOrientation;
  int _currentImageIndex = 0;
  bool isIpad = 100.w >= 800; // Define isIpad property

  Future<void> _loadCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customerId = prefs.getInt("customerId");
      customerName = prefs.getString("customerName");
    });
    loadInitialData();
  }

  List<int> _optionsFor(Orientation orientation) {
    if (!isIpad) return [2, 3]; // phone
    return orientation != Orientation.portrait
        ? [3, 4, 5, 6] // iPad landscape
        : [3, 4, 5]; // iPad portrait
  }

  void _ensureValidItemsPerPage(Orientation orientation) {
    final newOptions = _optionsFor(orientation);
    if (!_listEquals(newOptions, itemsPerPageOptions)) {
      itemsPerPageOptions = newOptions;

      if (!itemsPerPageOptions.contains(itemsPerPage)) {
        int closest = itemsPerPageOptions.first;
        int minDiff = (itemsPerPage - closest).abs();
        for (final v in itemsPerPageOptions) {
          final d = (itemsPerPage - v).abs();
          if (d < minDiff) {
            minDiff = d;
            closest = v;
          }
        }
        itemsPerPage = closest;
      }
    }
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    setState(() {
      itemsPerPage = isIpad ? 4 : 2;
    });
    _loadCustomer();
    searchController.addListener(() {
      _filterProducts(searchController.text);
    });
  }

  String pdfLink = '';
  bool isLoading = true;

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);
    _loadCachedData();
    final stopwatch = Stopwatch()..start();
    try {
      await Future.wait([
        _fetchProducts().then((_) => setState(() {})),
        _fetchSubCategories().then((_) => setState(() {})),
        _fetchPdfFile().then(
          (_) => setState(() {
            log('Pdf File : $pdfLink');
          }),
        ),
      ]);
    } catch (e) {
      log("Error loading initial data: $e");
    } finally {
      stopwatch.stop();
      setState(() => isLoading = false);
    }
  }

  // ... [Keep your existing _loadCachedData, _filterProducts, dispose methods] ...
  void _loadCachedData() {
    final productsBox = HiveService().getCategoryProductsBox();
    final subCategoriesBox = HiveService().getSubCategoriesBox();
    final pdfFileBox = HiveService().getPdfFileBox();

    final cachedProducts = productsBox.get('categoryProducts_${widget.id}');
    if (cachedProducts != null) {
      final List data = json.decode(cachedProducts);
      categoryWiseProductsList =
          data.map((e) => CategoryWiseProductsModal.fromJson(e)).toList();
      _filterProducts();
    }

    final cachedSubCategories = subCategoriesBox.get(
      'subCategories_${widget.id}',
    );
    if (cachedSubCategories != null) {
      final List data = json.decode(cachedSubCategories);
      subCategoriesList =
          data.map((e) => FetchSubCategoriesModal.fromJson(e)).toList();
    }

    final cachedPdfFile = pdfFileBox.get('pdf_${widget.slug}');
    if (cachedPdfFile != null) {
      fetchPdfFile = FetchPdfFileModal.fromJson(json.decode(cachedPdfFile));
    }

    setState(() {});
  }

  void _filterProducts([String query = ""]) {
    setState(() {
      filteredProducts =
          categoryWiseProductsList.where((product) {
            final name = product.name?.toLowerCase() ?? "";
            final packSize = product.packSize?.toLowerCase() ?? "";

            final matchesQuery =
                query.isEmpty ||
                name.contains(query.toLowerCase()) ||
                packSize.contains(query.toLowerCase());

            final matchesCategory =
                selectedFilters.isEmpty ||
                (product.categories != null &&
                    product.categories!.any(
                      (category) => selectedFilters.contains(category.name),
                    ));

            return matchesQuery && matchesCategory;
          }).toList();

      if (selectedSort == "Low to High") {
        filteredProducts.sort(
          (a, b) => double.parse(
            a.price ?? "0",
          ).compareTo(double.parse(b.price ?? "0")),
        );
      } else if (selectedSort == "High to Low") {
        filteredProducts.sort(
          (a, b) => double.parse(
            b.price ?? "0",
          ).compareTo(double.parse(a.price ?? "0")),
        );
      }
    });
  }

  Map<int, int> quantities = {};

  @override
  void dispose() {
    searchController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ==========================================
  // ============ UPDATED BUILD METHOD ========
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_lastOrientation != orientation) {
          _lastOrientation = orientation;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _ensureValidItemsPerPage(orientation);
            });
          });
        } else {
          _ensureValidItemsPerPage(orientation);
        }

        // --- RESPONSIVE LOGIC ---
        bool isWideDevice = 100.w >= 700;
        bool isLandscape = orientation == Orientation.landscape;
        bool showSideBar = isWideDevice && isLandscape;

        return Scaffold(
          backgroundColor: AppColors.bgColor,
          body:
              isLoading
                  ? Loader()
                  : showSideBar
                  // iPad Landscape: Row (Sidebar + Content)
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w, // Sidebar width
                        height: 100.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: VerticleBar(selected: 8),
                      ),
                      Expanded(
                        child: _buildMainContent(orientation, showSideBar),
                      ),
                    ],
                  )
                  // Mobile/Portrait: Content Only
                  : _buildMainContent(orientation, showSideBar),

          bottomNavigationBar:
              showSideBar
                  ? null
                  : SizedBox(
                    height: isIpad ? 14.h : 10.h,
                    child: CustomBar(selected: 8),
                  ),
        );
      },
    );
  }

  // Extracted Main Content to avoid duplication
  Widget _buildMainContent(Orientation orientation, bool showSideBar) {
    return Column(
      children: [
        // Title Bar Logic (Maintained from your original code)
        (isIpad && orientation == Orientation.portrait)
            ? TitleBarIpadPotrait(
              title: widget.cate == null ? 'Products' : widget.cate.toString(),
              isDrawerEnabled: true,
              isSearchEnabled: true,
              isBackEnabled: true,
              showDownloadButton: true,
              onDownload: _handleDownload,
              onSearch: () {
                setState(() {
                  isSearchEnabled = !isSearchEnabled;
                });
              },
            )
            : TitleBar(
              title: widget.cate == null ? 'Products' : widget.cate.toString(),
              isDrawerEnabled: true,
              isSearchEnabled: true,
              isBackEnabled: true,
              showDownloadButton: true,
              onDownload: _handleDownload,
              onSearch: () {
                setState(() {
                  isSearchEnabled = !isSearchEnabled;
                });
              },
            ),

        isSearchEnabled
            ? SearchField(controller: searchController)
            : const SizedBox.shrink(),
        SizedBox(height: 1.h),

        Expanded(
          child: Scrollbar(
            controller: _scrollCtrl,
            thumbVisibility: true,
            trackVisibility: isIpad,
            interactive: true,
            thickness: isIpad ? 8 : 6,
            radius: const Radius.circular(12),
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_buildSortButton(), _buildFilterButton()],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [_buildItemsPerRowDropdown()],
                  ),
                  if (filteredProducts.isNotEmpty) SizedBox(height: 1.h),
                  filteredProducts.isEmpty
                      ? Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isIpad ? 2.h : 15.h,
                        ),
                        child: emptyWidget(
                          icon: Icons.production_quantity_limits,
                          text: 'Products',
                        ),
                      )
                      : Column(
                        children: [
                          buildGroupedGrid(filteredProducts),
                          SizedBox(height: 2.h),
                        ],
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).paddingSymmetric(
      horizontal: showSideBar ? 1.w : 2.w, // Less padding if sidebar is present
      vertical: isIpad ? 0 : 0.5.h,
    );
  }

  // Extracted Helper Widgets for Cleanliness
  Widget _buildSortButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
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
              borderRadius: BorderRadius.circular(12),
              dropdownColor: Colors.white,
              icon: Icon(Icons.sort, color: AppColors.mainColor),
              items:
                  sortOptions.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: FontFamily.semiBold,
                          color: AppColors.mainColor,
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
    );
  }

  Widget _buildFilterButton() {
    return InkWell(
      onTap: () async {
        List<FetchSubCategoriesModal> tempSelectedFilters =
            subCategoriesList
                .where((subCat) => selectedFilters.contains(subCat.name))
                .toList();
        String? errorText;

        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: AppColors.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Filters",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: FontFamily.bold,
                          color: AppColors.blackColor,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            tempSelectedFilters.clear();
                            selectedFilters.clear();
                            _filterProducts();
                            Get.back();
                          });
                        },
                        child: Text(
                          "Clear Filters",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: FontFamily.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content:
                      subCategoriesList.isEmpty
                          ? SizedBox(
                            height: 15.h,
                            child: Center(
                              child: Text(
                                "No filters available",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.regular,
                                  color: AppColors.gray,
                                ),
                              ),
                            ),
                          )
                          : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children:
                                  subCategoriesList.map((subCategory) {
                                    bool isSelected = tempSelectedFilters
                                        .contains(subCategory);
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            tempSelectedFilters.remove(
                                              subCategory,
                                            );
                                          } else {
                                            tempSelectedFilters.add(
                                              subCategory,
                                            );
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 10,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 19.sp,
                                              height: 19.sp,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      isSelected
                                                          ? AppColors.mainColor
                                                          : AppColors.gray,
                                                  width: 2,
                                                ),
                                              ),
                                              child:
                                                  isSelected
                                                      ? Center(
                                                        child: Container(
                                                          width: 13.sp,
                                                          height: 13.sp,
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    AppColors
                                                                        .mainColor,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                        ),
                                                      )
                                                      : const SizedBox.shrink(),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                subCategory.name ?? '',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontFamily:
                                                      FontFamily.regular,
                                                  color: AppColors.blackColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
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
                      title: "Confirm",
                      route:
                          subCategoriesList.isEmpty
                              ? () {}
                              : () {
                                if (tempSelectedFilters.isEmpty) {
                                  setState(() {
                                    errorText =
                                        "Please select at least one filter!";
                                  });
                                } else {
                                  setState(() {
                                    selectedFilters =
                                        tempSelectedFilters
                                            .map((e) => e.name ?? '')
                                            .toList();
                                    _filterProducts();
                                  });
                                  Get.back();
                                }
                              },
                      color:
                          subCategoriesList.isEmpty
                              ? AppColors.gray
                              : AppColors.mainColor,
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
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedSort,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.filter_vintage_outlined,
              color: AppColors.mainColor,
            ),
            items:
                sortOptions.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(
                      'Filter ',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: FontFamily.semiBold,
                        color: AppColors.blackColor,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: null,
          ),
        ),
      ),
    );
  }

  Widget _buildItemsPerRowDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Text(
            "Items per row",
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: FontFamily.semiBold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(width: 3.w),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: itemsPerPage,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: Colors.white,
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: FontFamily.regular,
                color: AppColors.blackColor,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
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
                          fontFamily: FontFamily.semiBold,
                          color: AppColors.mainColor,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    itemsPerPage = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Extracted Download Handler
  Future<void> _handleDownload() async {
    var box = HiveService().getPdfFileBox();

    final cachedBytes = box.get('pdf_bytes_${widget.slug}');
    if (cachedBytes != null) {
      await downloadFile(
        null,
        context,
        "${widget.cate} - Catalog",
        'pdf',
        fileBytes: Uint8List.fromList(cachedBytes),
      );
      return;
    }

    if (pdfLink.isEmpty) {
      showCustomErrorSnackbar(
        title: "PDF Unavailable",
        message: "PDF is not available for download right now.",
      );
      return;
    }

    await downloadFile(
      pdfLink,
      context,
      "${widget.cate} - Catalog - ${pdfLink.split('/').last.split('.').first}",
      pdfLink.split('/').last.split('.').last,
    );
  }

  // ==========================================
  // ======== GRID & PRODUCT LOGIC ============
  // ==========================================

  Widget _buildGridItem(
    CategoryWiseProductsModal product, {
    double scale = 1.0,
  }) {
    final pid = (product.id ?? product.slug ?? product.name ?? '').toString();
    final bool hasVariations = (product.variations?.isNotEmpty ?? false);
    final int qty = int.tryParse(product.cartQuantity?.toString() ?? '0') ?? 0;
    // Unused variable removed for cleaner code
    double sp(double v) => v * scale;
    double px(double v) => v * scale;

    void onAdd() {
      if (product.stockStatus != "instock") return;
      if (!hasVariations) {
        _addSimpleProductsToCart(product);
      } else {
        _addVariationProductsToCart(
          product,
          product.firstVariation?.id,
          product.firstVariation?.varAttributes?.getKey(),
          product.firstVariation?.varAttributes?.getValue(),
        );
      }
    }

    void onRemove() {
      if (product.stockStatus != "instock") return;
      _removeProductFromCart(product);
    }

    return Opacity(
      opacity: product.stockStatus == 'instock' ? 1.0 : 0.45,
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(px(16)),
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.25)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(px(16)),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============== STACK: IMAGE + DOTS OVERLAY =================
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // 1. IMAGE SLIDER
                      InkWell(
                        onTap:
                            product.stockStatus == 'instock'
                                ? () {
                                  Get.to(
                                    () => ProductDetailsScreen(
                                      productId: product.id.toString(),
                                      isVariation: hasVariations,
                                      id: widget.id,
                                      cate: widget.cate,
                                      slug: widget.slug,
                                    ),
                                    transition: Transition.leftToRightWithFade,
                                    duration: const Duration(milliseconds: 450),
                                  );
                                }
                                : () {
                                  showCustomErrorSnackbar(
                                    title: "Out of Stock",
                                    message:
                                        "${product.name} is not available right now!",
                                  );
                                },
                        // FIX 1: Increased AspectRatio slightly (0.85 -> 0.92) to prevent overflow
                        child: AspectRatio(
                          aspectRatio: 0.92,
                          child: CarouselSlider.builder(
                            itemCount:
                                (product.images?.length ?? 0) > 0
                                    ? product.images!.length
                                    : 1,
                            options: CarouselOptions(
                              viewportFraction: 1,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: false,
                              autoPlay: false,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _setImgIndex(pid, index);
                                });
                              },
                            ),
                            itemBuilder: (_, i, __) {
                              final src =
                                  (product.images?.isNotEmpty ?? false)
                                      ? (product.images![i].src ?? '')
                                      : '';

                              return ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(px(16)),
                                ),
                                child: CustomNetworkImage(
                                  imageUrl: src,
                                  height: double.infinity,
                                  width: double.infinity,
                                  isFit: true,
                                  radius: 0,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // 2. DOTS (Overlay)
                      if ((product.images?.length ?? 0) > 1)
                        Positioned(
                          bottom: px(10),
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(product.images!.length, (
                                index,
                              ) {
                                final pid = product.id.toString();
                                final currentIndex = _getImgIndex(pid);

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: px(3),
                                  ),
                                  height: px(7),
                                  width: currentIndex == index ? px(14) : px(7),
                                  decoration: BoxDecoration(
                                    // Use semi-transparent white for inactive dots so they show on dark images
                                    color:
                                        currentIndex == index
                                            ? AppColors.mainColor
                                            : Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(px(4)),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ================= TITLE =================
                  Padding(
                    // FIX 2: Reduced top padding (10 -> 8)
                    padding: EdgeInsets.only(
                      left: px(10),
                      right: px(10),
                      top: px(8),
                    ),
                    child: Text(
                      product.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FontFamily.semiBold,
                        fontSize: sp(14),
                        color: AppColors.blackColor,
                      ),
                    ),
                  ),

                  // ============== MOQ + COUNTER =================
                  Padding(
                    // FIX 3: Reduced vertical padding (6/10 -> 4/8)
                    padding: EdgeInsets.fromLTRB(px(10), px(4), px(10), px(8)),
                    child: Row(
                      children: [
                        // LEFT: MOQ TEXT
                        Expanded(
                          child: Text(
                            hasVariations
                                ? 'MOQ : ${product.firstVariation?.packSize ?? "-"}'
                                : (product.packSize == ""
                                    ? 'MOQ : 1'
                                    : 'MOQ : ${product.packSize}'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: sp(14),
                              fontFamily: FontFamily.regular,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                        if (!hasVariations)
                          Row(
                            children: [
                              _circleBtn(
                                icon: Icons.remove,
                                onTap:
                                    product.stockStatus == 'instock'
                                        ? onRemove
                                        : null,
                                size: px(32),
                                iconSize: px(18),
                              ),
                              SizedBox(width: px(6)),
                              if (qty > 0)
                                Text(
                                  qty.toString(),
                                  style: TextStyle(
                                    fontFamily: FontFamily.semiBold,
                                    fontSize: sp(13.5),
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              if (qty > 0) SizedBox(width: px(6)),
                              _circleBtn(
                                icon: Icons.add,
                                onTap:
                                    product.stockStatus == 'instock'
                                        ? onAdd
                                        : null,
                                size: px(32),
                                iconSize: px(18),
                              ),
                            ],
                          ),
                        if (hasVariations && qty > 0)
                          Padding(
                            padding: const EdgeInsets.only(right: 1.0),
                            child: Text(
                              qty.toString(),
                              style: TextStyle(
                                fontFamily: FontFamily.semiBold,
                                fontSize: sp(13.5),
                                color: AppColors.blackColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // OUT OF STOCK veil
              if (product.stockStatus != 'instock')
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: Center(
                      child: Text(
                        "Out of Stock",
                        style: TextStyle(
                          fontSize: sp(16),
                          fontFamily: FontFamily.bold,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback? onTap,
    double size = 32,
    double iconSize = 18,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              onTap == null
                  ? AppColors.gray.withValues(alpha: 0.25)
                  : AppColors.mainColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: onTap == null ? AppColors.gray : Colors.white,
        ),
      ),
    );
  }

  final Map<String, int> _imageIndexByProductId = {};

  int _getImgIndex(String pid) => _imageIndexByProductId[pid] ?? 0;

  void _setImgIndex(String pid, int idx) => setState(() {
    _imageIndexByProductId[pid] = idx;
  });

  Widget buildGroupedGrid(List<CategoryWiseProductsModal> filteredProducts) {
    // group
    final Map<String, List<CategoryWiseProductsModal>> grouped = {};
    for (var p in filteredProducts) {
      final key =
          (p.subCategoryName ?? "").trim().isEmpty
              ? "Others"
              : p.subCategoryName!.trim();
      grouped.putIfAbsent(key, () => []).add(p);
    }
    final sortedGroups =
        grouped.entries.toList()
          ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 20.0;
        final cross = itemsPerPage;
        final totalSpacing = spacing * (cross - 1);
        final colWidth = (constraints.maxWidth - totalSpacing) / cross;

        // scale factor relative to your base card width 220
        final scale = (colWidth / 220.0).clamp(0.75, 1.15);

        // Base dynamic sizing (no overflow now)
        final double imageHeight = colWidth; // square image
        final double titleHeight = 20 * scale; // ~1 line title
        final double moqRowHeight = 40 * scale; // MOQ + counter row
        final double verticalPadding = 24 * scale; // total inner padding

        // ✅ dots add height only if needed
        final bool hasMultipleImages = filteredProducts.any(
          (p) => (p.images?.length ?? 0) > 1,
        );
        final double dotsHeight = hasMultipleImages ? (14 * scale) : 0;

        // FINAL dynamic height
        final double tileHeight =
            imageHeight +
            titleHeight +
            moqRowHeight +
            verticalPadding +
            dotsHeight;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedGroups.length,
          itemBuilder: (context, index) {
            final products = sortedGroups[index].value;

            return GridView.builder(
              itemCount: products.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                mainAxisExtent: tileHeight,
              ),
              itemBuilder: (_, i) => _buildGridItem(products[i], scale: scale),
            );
          },
        );
      },
    );
  }

  // ... [Keep your existing _fetchProducts, _addSimpleProductsToCart, _addVariationProductsToCart, _removeProductFromCart, _fetchSubCategories, _fetchPdfFile methods] ...
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

        _filterProducts();
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
        customerId,
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
        _filterProducts(); // refresh filtered list after fetch
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
          _filterProducts();
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
        _filterProducts();
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }

  Future<void> _addSimpleProductsToCart(
    CategoryWiseProductsModal product,
  ) async {
    setState(() {
      isAddingToCart = true;
      product.cartQuantity =
          (int.tryParse(product.cartQuantity?.toString() ?? '0') ?? 0) +
          (int.tryParse(product.packSize?.toString() ?? '0') ?? 0);
    });

    final cartService = CartService();

    try {
      final response = await cartService.increaseCartItem(
        productId: int.parse(product.id.toString()),
        itemNote: '',
        packsize: num.parse(product.packSize.toString()),
      );

      String message = "Added to Cart";
      if (response != null && response.statusCode == 200) {
        final serverMessage = response.data["message"];
        if (serverMessage != null && serverMessage.toString().isNotEmpty) {
          message = serverMessage.toString();
        }
      } else {
        message = "Product added offline. It will sync once internet is back.";
      }
    } catch (e) {
      showCustomErrorSnackbar(
        title: "Error",
        message: "Something went wrong while adding product.\n$e",
      );
      log('Error : $e');
    } finally {
      setState(() => isAddingToCart = false);
    }
  }

  Future<void> _addVariationProductsToCart(
    CategoryWiseProductsModal product,
    variationId,
    variationKey,
    variationValue,
  ) async {
    setState(() {
      isAddingToCart = true;
      product.cartQuantity =
          (int.tryParse(product.cartQuantity?.toString() ?? '0') ?? 0) +
          (int.tryParse(product.packSize?.toString() ?? '0') ?? 0);
    });

    final cartService = CartService();

    try {
      final response = await cartService.increaseCartItem(
        productId: int.parse(product.id.toString()),
        variationId: variationId,
        variation: {"attribute_${variationKey ?? ''}": variationValue ?? ''},
        itemNote: '',
        packsize: num.parse(product.packSize.toString()),
      );

      String message = "Added to Cart";
      if (response != null && response.statusCode == 200) {
        final serverMessage = response.data["message"];
        if (serverMessage != null && serverMessage.toString().isNotEmpty) {
          message = serverMessage.toString();
        }
      } else {
        message = "Product added offline. It will sync once internet is back.";
      }
    } catch (e) {
      showCustomErrorSnackbar(
        title: "Error",
        message: "Something went wrong while adding product.\n$e",
      );
    } finally {
      setState(() => isAddingToCart = false);
    }
  }

  Future<void> _removeProductFromCart(CategoryWiseProductsModal product) async {
    if (product.id == null) return;

    setState(() => isAddingToCart = true);
    final cartService = CartService();

    try {
      final cachedData = await cartService.getCachedProductCartDataSafe(
        product.id!,
      );
      int currentQty =
          cachedData["totalQuantity"]?.toInt() ?? (product.cartQuantity ?? 0);

      if (currentQty <= 0) {
        showCustomErrorSnackbar(
          title: "Cart Empty",
          message: "No items in cart to remove.",
        );
        return;
      }

      final response = await cartService.decreaseCartItem(
        productId: product.id!,
        packsize: num.parse(product.packSize.toString()),
      );

      final updatedData = await cartService.getCachedProductCartDataSafe(
        product.id!,
      );
      setState(() {
        product.cartQuantity = updatedData["totalQuantity"]?.toInt() ?? 0;
      });

      if (response != null) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final message =
              response.data?["message"] ?? "Product quantity removed.";
        } else if (response.statusCode == 204) {
          showCustomErrorSnackbar(
            title: "Cart Empty",
            message: "No items in cart to remove.",
          );
        }
      } else {
        showCustomSuccessSnackbar(
          title: "Offline Mode",
          message: "Cart updated offline. It will sync when internet is back.",
        );
      }
    } catch (e, stackTrace) {
      showCustomErrorSnackbar(
        title: "Error",
        message: "Something went wrong while updating cart.\n$e",
      );
      log('Error : $stackTrace');
    } finally {
      setState(() => isAddingToCart = false);
    }
  }

  Future<void> _fetchSubCategories() async {
    var box = HiveService().getSubCategoriesBox();

    if (!await checkInternet()) {
      final cachedData = box.get('subCategories_${widget.id}');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        subCategoriesList =
            data.map((e) => FetchSubCategoriesModal.fromJson(e)).toList();
      }
      return;
    }

    try {
      final response = await CategoriesProvider().fetchSubCategoriesApi(
        widget.id,
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        subCategoriesList =
            data.map((e) => FetchSubCategoriesModal.fromJson(e)).toList();

        await box.put('subCategories_${widget.id}', response.body);
      } else {
        final cachedData = box.get('subCategories_${widget.id}');
        if (cachedData != null) {
          final List data = json.decode(cachedData);
          subCategoriesList =
              data.map((e) => FetchSubCategoriesModal.fromJson(e)).toList();
        }
      }
    } catch (_) {
      final cachedData = box.get('subCategories_${widget.id}');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        subCategoriesList =
            data.map((e) => FetchSubCategoriesModal.fromJson(e)).toList();
      }

      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Loaded cached data (if available).',
      );
    }
  }

  Future<void> _fetchPdfFile() async {
    var box = HiveService().getPdfFileBox();

    if (!await checkInternet()) {
      final cachedData = box.get('pdf_${widget.slug}');
      final cachedBytes = box.get('pdf_bytes_${widget.slug}');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        fetchPdfFile = FetchPdfFileModal.fromJson(data);
        pdfLink = fetchPdfFile?.savedUrl ?? '';
      }
      if (cachedBytes != null) {
        log('✅ PDF bytes available offline');
      }
      return;
    }

    try {
      final response = await CategoriesProvider().fetchPdfFileApi(widget.slug);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        fetchPdfFile = FetchPdfFileModal.fromJson(data);

        await box.put('pdf_${widget.slug}', response.body);
        pdfLink = fetchPdfFile?.savedUrl ?? '';

        if (pdfLink.isNotEmpty) {
          try {
            Dio dio = Dio(
              BaseOptions(
                headers: {"User-Agent": "Mozilla/5.0", "Accept": "*/*"},
              ),
            );
            final pdfResponse = await dio.get<List<int>>(
              pdfLink,
              options: Options(responseType: ResponseType.bytes),
            );
            if (pdfResponse.data != null) {
              await box.put('pdf_bytes_${widget.slug}', pdfResponse.data);
              log('✅ PDF bytes saved for offline use');
            }
          } catch (e) {
            log('⚠️ Failed to fetch PDF bytes for offline: $e');
          }
        }
      } else {
        final cachedData = box.get('pdf_${widget.slug}');
        if (cachedData != null) {
          final data = json.decode(cachedData);
          fetchPdfFile = FetchPdfFileModal.fromJson(data);
          pdfLink = fetchPdfFile?.savedUrl ?? '';
        }
      }
    } catch (_) {
      final cachedData = box.get('pdf_${widget.slug}');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        fetchPdfFile = FetchPdfFileModal.fromJson(data);
        pdfLink = fetchPdfFile?.savedUrl ?? '';
      }
    }
  }
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;

  const DashedDivider({super.key, this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.constrainWidth();
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount = (width / (dashWidth + dashSpace)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
