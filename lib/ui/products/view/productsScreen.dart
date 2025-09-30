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
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  int itemsPerPage = 4;
  int currentPage = 0;
  bool isFilter = false;

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
  List<FetchSubCategoriesModal> subCategoriesList = [];
  String selectedSort = "Low to High";
  final List<String> sortOptions = ["Low to High", "High to Low", "Latest"];
  List<String> selectedFilters = []; // for multi-selection
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

  String pdfLink = '';
  bool isLoading = true;

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);

    // Load cached data first for immediate display
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
      log("All API calls completed in ${stopwatch.elapsed.inMilliseconds} ms");
      setState(() => isLoading = false);
    }
  }

  void _loadCachedData() {
    var productsBox = HiveService().getCategoryProductsBox();
    var subCategoriesBox = HiveService().getSubCategoriesBox();
    var pdfFileBox = HiveService().getPdfFileBox();
    final cachedProducts = productsBox.get('products');
    if (cachedProducts != null) {
      final List data = json.decode(cachedProducts);
      categoryWiseProductsList =
          data.map((e) => CategoryWiseProductsModal.fromJson(e)).toList();

      _filterProducts(); // 👈 refresh filtered list
    }

    final cachedSubCategories = subCategoriesBox.get(
      'subCategories_${widget.id}',
    );
    if (cachedProducts != null) {
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

            // Check if product matches the text query
            bool matchesQuery =
                query.isEmpty ||
                name.contains(query.toLowerCase()) ||
                packSize.contains(query.toLowerCase());

            // Check if product matches selected categories
            bool matchesCategory =
                selectedFilters.isEmpty ||
                (product.categories != null &&
                    product.categories!.any(
                      (category) => selectedFilters.contains(category.name),
                    ));

            return matchesQuery && matchesCategory;
          }).toList();

      // Sorting
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
                        showDownloadButton: true,
                        onDownload: () async {
                          var box = HiveService().getPdfFileBox();

                          // Check if we have cached PDF bytes for offline
                          final cachedBytes = box.get(
                            'pdf_bytes_${widget.slug}',
                          );

                          if (cachedBytes != null) {
                            // ✅ Offline or fallback download using cached bytes
                            await downloadFile(
                              null, // No URL needed
                              context,
                              "${widget.cate} - Catalog",
                              'pdf',
                              fileBytes: Uint8List.fromList(cachedBytes),
                            );
                            return;
                          }

                          // If cached bytes are not available, check if URL exists
                          if (pdfLink.isEmpty) {
                            showCustomErrorSnackbar(
                              title: "PDF Unavailable",
                              message:
                                  "PDF is not available for download right now.",
                            );
                            return;
                          }

                          // ✅ Online download
                          await downloadFile(
                            pdfLink,
                            context,
                            "${widget.cate} - Catalog - ${pdfLink.split('/').last.split('.').first}",
                            pdfLink.split('/').last.split('.').last,
                          );
                        },

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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isFilter = !isFilter;
                                      });
                                    },
                                    child: Container(
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
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedSort,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          dropdownColor: Colors.white,
                                          icon: Icon(
                                            Icons.filter_tilt_shift,
                                            color: AppColors.mainColor,
                                          ),
                                          items:
                                              sortOptions.map((e) {
                                                return DropdownMenuItem(
                                                  value: e,
                                                  child: Text(
                                                    'Filter Data   ',
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontFamily:
                                                          FontFamily.semiBold,
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                          onTap: () {
                                            setState(() {
                                              isFilter = !isFilter;
                                              log("isFilter : $isFilter");
                                            });
                                          },
                                          onChanged:
                                              null, // <-- disables selection
                                        ),
                                      ),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                                        fontFamily:
                                                            FontFamily.semiBold,
                                                        color:
                                                            AppColors.mainColor,
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

                              if (isFilter)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    InkWell(
                                      onTap: () async {
                                        // Initialize with previously selected filters
                                        List<FetchSubCategoriesModal>
                                        tempSelectedFilters =
                                            subCategoriesList
                                                .where(
                                                  (subCat) => selectedFilters
                                                      .contains(subCat.name),
                                                )
                                                .toList();

                                        String? errorText;

                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      AppColors.whiteColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                  title: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Select Filters",
                                                        style: TextStyle(
                                                          fontSize: 18.sp,
                                                          fontFamily:
                                                              FontFamily.bold,
                                                          color:
                                                              AppColors
                                                                  .blackColor,
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            tempSelectedFilters
                                                                .clear();
                                                            selectedFilters
                                                                .clear();
                                                            _filterProducts();
                                                            Get.back();
                                                          });
                                                        },
                                                        child: Text(
                                                          "Clear Filters",
                                                          style: TextStyle(
                                                            fontSize: 18.sp,
                                                            fontFamily:
                                                                FontFamily.bold,
                                                            color:
                                                                AppColors
                                                                    .mainColor,
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
                                                                  fontSize:
                                                                      16.sp,
                                                                  fontFamily:
                                                                      FontFamily
                                                                          .regular,
                                                                  color:
                                                                      AppColors
                                                                          .gray,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          : SingleChildScrollView(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children:
                                                                  subCategoriesList.map((
                                                                    subCategory,
                                                                  ) {
                                                                    bool
                                                                    isSelected =
                                                                        tempSelectedFilters.contains(
                                                                          subCategory,
                                                                        );
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
                                                                        padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              12,
                                                                          horizontal:
                                                                              10,
                                                                        ),
                                                                        margin: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              5,
                                                                        ),
                                                                        child: Row(
                                                                          children: [
                                                                            Container(
                                                                              width:
                                                                                  19.sp,
                                                                              height:
                                                                                  19.sp,
                                                                              decoration: BoxDecoration(
                                                                                shape:
                                                                                    BoxShape.circle,
                                                                                border: Border.all(
                                                                                  color:
                                                                                      isSelected
                                                                                          ? AppColors.mainColor
                                                                                          : AppColors.gray,
                                                                                  width:
                                                                                      2,
                                                                                ),
                                                                              ),
                                                                              child:
                                                                                  isSelected
                                                                                      ? Center(
                                                                                        child: Container(
                                                                                          width:
                                                                                              13.sp,
                                                                                          height:
                                                                                              13.sp,
                                                                                          decoration: BoxDecoration(
                                                                                            color:
                                                                                                AppColors.mainColor,
                                                                                            shape:
                                                                                                BoxShape.circle,
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                      : SizedBox.shrink(),
                                                                            ),
                                                                            SizedBox(
                                                                              width:
                                                                                  10,
                                                                            ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                subCategory.name ??
                                                                                    '',
                                                                                style: TextStyle(
                                                                                  fontSize:
                                                                                      16.sp,
                                                                                  fontFamily:
                                                                                      FontFamily.regular,
                                                                                  color:
                                                                                      AppColors.blackColor,
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
                                                      color:
                                                          AppColors
                                                              .containerColor,
                                                      fontcolor:
                                                          AppColors.blackColor,
                                                      height: 5.h,
                                                      width: 30.w,
                                                      fontsize: 15.sp,
                                                      radius: 12.0,
                                                    ),
                                                    CustomButton(
                                                      title: "Confirm",
                                                      route:
                                                          subCategoriesList
                                                                  .isEmpty
                                                              ? () {}
                                                              : () {
                                                                if (tempSelectedFilters
                                                                    .isEmpty) {
                                                                  setState(() {
                                                                    errorText =
                                                                        "Please select at least one filter!";
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    selectedFilters =
                                                                        tempSelectedFilters
                                                                            .map(
                                                                              (
                                                                                e,
                                                                              ) =>
                                                                                  e.name ??
                                                                                  '',
                                                                            )
                                                                            .toList();
                                                                    _filterProducts(); // Apply filter immediately
                                                                  });
                                                                  Get.back();
                                                                }
                                                              },
                                                      color:
                                                          subCategoriesList
                                                                  .isEmpty
                                                              ? AppColors.gray
                                                              : AppColors
                                                                  .mainColor,
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
                                      },

                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 3.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          boxShadow: [
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                                      'Filter Data Using  ',
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        fontFamily:
                                                            FontFamily.semiBold,
                                                        color:
                                                            AppColors
                                                                .blackColor,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged:
                                                null, // <-- disables selection
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (filteredProducts.isNotEmpty)
                                SizedBox(height: 1.h),
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
                                          _removeProductFromCart(product);
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
                                                product,
                                              )
                                              : _addVariationProductsToCart(
                                                product,
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
                              "${product.cartQuantity} Qty",
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
                              "${product.cartQuantity} Qty",
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

  Future<void> _addSimpleProductsToCart(
    CategoryWiseProductsModal product,
  ) async {
    setState(() {
      isAddingToCart = true;
      // 🔹 update UI immediately
      product.cartQuantity = (product.cartQuantity ?? 0) + 1;
    });

    final cartService = CartService();

    try {
      final response = await cartService.increaseCartItem(
        productId: int.parse(product.id.toString()),
        itemNote: '',
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

      showCustomSuccessSnackbar(
        title:
            message.contains("update") ? "Quantity Updated" : "Added to Cart",
        message: message,
      );
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
      product.cartQuantity = (product.cartQuantity ?? 0) + 1;
    });

    final cartService = CartService();

    try {
      final response = await cartService.increaseCartItem(
        productId: int.parse(product.id.toString()),
        variationId: variationId,
        variation: {"attribute_${variationKey ?? ''}": variationValue ?? ''},
        itemNote: '',
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

      showCustomSuccessSnackbar(
        title:
            message.contains("update") ? "Quantity Updated" : "Added to Cart",
        message: message,
      );
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
      // ----------------- Get cached quantity safely -----------------
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

      // ----------------- Call CartService to decrease item -----------------
      final response = await cartService.decreaseCartItem(
        productId: product.id!,
      );

      // ----------------- Get updated quantity from cache -----------------
      final updatedData = await cartService.getCachedProductCartDataSafe(
        product.id!,
      );
      setState(() {
        product.cartQuantity = updatedData["totalQuantity"]?.toInt() ?? 0;
      });

      // ----------------- Show appropriate message -----------------
      if (response != null) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final message =
              response.data?["message"] ?? "Product quantity removed.";
          showCustomSuccessSnackbar(
            title: "Quantity Updated",
            message: message,
          );
        } else if (response.statusCode == 204) {
          showCustomErrorSnackbar(
            title: "Cart Empty",
            message: "No items in cart to remove.",
          );
        }
      } else {
        // Offline mode
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
      // ✅ Load from Hive if offline
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

        // ✅ Save fresh API data into Hive
        await box.put('subCategories_${widget.id}', response.body);
      } else {
        // API error → fallback to cache
        final cachedData = box.get('subCategories_${widget.id}');
        if (cachedData != null) {
          final List data = json.decode(cachedData);
          subCategoriesList =
              data.map((e) => FetchSubCategoriesModal.fromJson(e)).toList();
        }

        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Loaded cached data (if available).',
        );
      }
    } catch (_) {
      // Network exception → fallback to cache
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

    // Offline first
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

        // ✅ Save API response JSON in Hive
        await box.put('pdf_${widget.slug}', response.body);

        pdfLink = fetchPdfFile?.savedUrl ?? '';

        // ✅ Prefetch PDF bytes for offline download
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
        // API error → fallback to cache
        final cachedData = box.get('pdf_${widget.slug}');
        if (cachedData != null) {
          final data = json.decode(cachedData);
          fetchPdfFile = FetchPdfFileModal.fromJson(data);
          pdfLink = fetchPdfFile?.savedUrl ?? '';
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Loaded cached data (if available).',
        );
      }
    } catch (_) {
      // Network exception → fallback to cache
      final cachedData = box.get('pdf_${widget.slug}');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        fetchPdfFile = FetchPdfFileModal.fromJson(data);
        pdfLink = fetchPdfFile?.savedUrl ?? '';
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Loaded cached data (if available).',
      );
    }
  }

  // Future<void> _fetchPdfFile() async {
  //   var box = HiveService().getPdfFileBox();
  //
  //   if (!await checkInternet()) {
  //     // ✅ Load from Hive if offline
  //     final cachedData = box.get('pdf_${widget.slug}');
  //     if (cachedData != null) {
  //       final data = json.decode(cachedData);
  //       fetchPdfFile = FetchPdfFileModal.fromJson(data);
  //       pdfLink = fetchPdfFile?.savedUrl ?? '';
  //     }
  //     return;
  //   }
  //
  //   try {
  //     final response = await CategoriesProvider().fetchPdfFileApi(widget.slug);
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       fetchPdfFile = FetchPdfFileModal.fromJson(data);
  //
  //       // ✅ Save fresh API data into Hive
  //       await box.put('pdf_${widget.slug}', response.body);
  //
  //       pdfLink = fetchPdfFile?.savedUrl ?? '';
  //     } else {
  //       // API error → fallback to cache
  //       final cachedData = box.get('pdf_${widget.slug}');
  //       if (cachedData != null) {
  //         final data = json.decode(cachedData);
  //         fetchPdfFile = FetchPdfFileModal.fromJson(data);
  //         pdfLink = fetchPdfFile?.savedUrl ?? '';
  //       }
  //
  //       showCustomErrorSnackbar(
  //         title: 'Server Error',
  //         message: 'Something went wrong. Loaded cached data (if available).',
  //       );
  //     }
  //   } catch (_) {
  //     // Network exception → fallback to cache
  //     final cachedData = box.get('pdf_${widget.slug}');
  //     if (cachedData != null) {
  //       final data = json.decode(cachedData);
  //       fetchPdfFile = FetchPdfFileModal.fromJson(data);
  //       pdfLink = fetchPdfFile?.savedUrl ?? '';
  //     }
  //
  //     showCustomErrorSnackbar(
  //       title: 'Network Error',
  //       message: 'Unable to connect. Loaded cached data (if available).',
  //     );
  //   }
  // }
}
