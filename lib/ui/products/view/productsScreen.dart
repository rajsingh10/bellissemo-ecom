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

  Future<void> _loadCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customerId = prefs.getInt("customerId");
      customerName = prefs.getString("customerName");
    });
    loadInitialData();
  }

  List<int> _optionsFor(Orientation orientation) {
    if (!isIpad) return [3, 4]; // phone
    return orientation != Orientation.portrait
        ? [3, 4, 5, 6] // iPad portrait
        : [3, 4, 5]; // iPad landscape
  }

  // NEW: clamp currently selected itemsPerPage to valid list
  void _ensureValidItemsPerPage(Orientation orientation) {
    final newOptions = _optionsFor(orientation);
    if (!_listEquals(newOptions, itemsPerPageOptions)) {
      itemsPerPageOptions = newOptions;

      if (!itemsPerPageOptions.contains(itemsPerPage)) {
        // choose the closest allowed value to current selection
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

  // tiny helper
  bool _listEquals(List<int> a, List<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      itemsPerPage = isIpad ? 4 : 3;
    });
    _loadCustomer(); // instead of dummy products
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
    final productsBox = HiveService().getCategoryProductsBox();
    final subCategoriesBox = HiveService().getSubCategoriesBox();
    final pdfFileBox = HiveService().getPdfFileBox();

    // ✅ use the same key pattern as fetch (_fetchProducts)
    final cachedProducts = productsBox.get('categoryProducts_${widget.id}');
    if (cachedProducts != null) {
      final List data = json.decode(cachedProducts);
      categoryWiseProductsList =
          data.map((e) => CategoryWiseProductsModal.fromJson(e)).toList();
      _filterProducts(); // refresh filtered list
    }

    final cachedSubCategories = subCategoriesBox.get(
      'subCategories_${widget.id}',
    );
    if (cachedSubCategories != null) {
      // ✅ fixed null check
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
  Widget build(BuildContext context) {
    // Wrap with OrientationBuilder to detect rotation and force itemsPerPage = 4
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_lastOrientation != orientation) {
          _lastOrientation = orientation;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              // update options and clamp value safely on orientation change
              _ensureValidItemsPerPage(orientation);
            });
          });
        } else {
          // first build or unchanged—still ensure options are correct
          _ensureValidItemsPerPage(orientation);
        }

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
                              : const SizedBox.shrink(),
                          SizedBox(height: 1.h),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                children: [
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
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          boxShadow: const [
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
                                                                  FontFamily
                                                                      .bold,
                                                              color:
                                                                  AppColors
                                                                      .mainColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    content:
                                                        subCategoriesList
                                                                .isEmpty
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
                                                                          padding: const EdgeInsets.symmetric(
                                                                            vertical:
                                                                                12,
                                                                            horizontal:
                                                                                10,
                                                                          ),
                                                                          margin: const EdgeInsets.symmetric(
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
                                                                                        : const SizedBox.shrink(),
                                                                              ),
                                                                              const SizedBox(
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
                                                            AppColors
                                                                .blackColor,
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
                                                            AppColors
                                                                .whiteColor,
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                                          fontFamily:
                                                              FontFamily
                                                                  .semiBold,
                                                          color:
                                                              AppColors
                                                                  .blackColor,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                              onChanged:
                                                  null, // disabled selection, acts like a button
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 3.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          boxShadow: const [
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
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                dropdownColor: Colors.white,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontFamily:
                                                      FontFamily.regular,
                                                  color: AppColors.blackColor,
                                                ),
                                                icon: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: AppColors.mainColor,
                                                ),
                                                items:
                                                    itemsPerPageOptions.map((
                                                      e,
                                                    ) {
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
                                  if (filteredProducts.isNotEmpty)
                                    SizedBox(height: 1.h),
                                  filteredProducts.isEmpty
                                      ? Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: isIpad ? 2.h : 15.h,
                                        ),
                                        child: emptyWidget(
                                          icon:
                                              Icons.production_quantity_limits,
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
                        ],
                      ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
                    ],
                  ),
          bottomNavigationBar: SizedBox(
            height: isIpad ? 14.h : 10.h,
            child: CustomBar(selected: 8),
          ),
        );
      },
    );
  }

  bool isIpad = 100.w >= 800;

  // Widget _buildGridItem(CategoryWiseProductsModal product) {
  //   return InkWell(
  //     onTap:
  //         product.stockStatus == 'instock'
  //             ? () {
  //               Get.to(
  //                 () => ProductDetailsScreen(
  //                   productId: product.id.toString(),
  //                   isVariation: product.variations?.length != 0,
  //                   id: widget.id,
  //                   cate: widget.cate,
  //                   slug: widget.slug,
  //                 ),
  //                 transition: Transition.leftToRightWithFade,
  //                 duration: const Duration(milliseconds: 450),
  //               );
  //             }
  //             : () {
  //               showCustomErrorSnackbar(
  //                 title: "Out of Stock",
  //                 message: "${product.name} is not available right now!",
  //               );
  //             },
  //     child: Opacity(
  //       opacity: product.stockStatus == 'instock' ? 1.0 : 0.4,
  //       child: Card(
  //         color: AppColors.cardBgColor2,
  //         elevation: 3,
  //         shadowColor: Colors.black45,
  //         shape: RoundedRectangleBorder(
  //           side: BorderSide(color: AppColors.border),
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Product Image
  //             Expanded(
  //               child: ClipRRect(
  //                 borderRadius: const BorderRadius.vertical(
  //                   top: Radius.circular(20),
  //                 ),
  //                 child: Stack(
  //                   children: [
  //                     CarouselSlider(
  //                       options: CarouselOptions(
  //                         height: Device.height,
  //                         viewportFraction: 1,
  //                         enlargeCenterPage: false,
  //                         enableInfiniteScroll: false,
  //                         autoPlay: true,
  //                       ),
  //                       items:
  //                           (product.images ?? []).map((img) {
  //                             return ClipRRect(
  //                               borderRadius: BorderRadius.circular(20),
  //                               child: CustomNetworkImage(
  //                                 imageUrl: img.src ?? '',
  //                                 height: double.infinity,
  //                                 width: double.infinity,
  //                                 isFit: true,
  //                                 radius: 20,
  //                               ),
  //                             );
  //                           }).toList(),
  //                     ),
  //                     if ((product.variations?.length ?? 0) == 0)
  //                       Positioned(
  //                         left: 6,
  //                         right: 6,
  //                         bottom: 6,
  //                         child: LayoutBuilder(
  //                           builder: (context, constraints) {
  //                             // Inverse dynamic size
  //                             double iconSize =
  //                                 (60 + (120 - constraints.maxWidth)) * 0.20;
  //                             iconSize = iconSize.clamp(
  //                               32,
  //                               35,
  //                             ); // adjust limits as needed
  //
  //                             return IntrinsicWidth(
  //                               child: Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   IconButton(
  //                                     onPressed:
  //                                         (product.stockStatus == "instock")
  //                                             ? () => _removeProductFromCart(
  //                                               product,
  //                                             )
  //                                             : null,
  //                                     padding: EdgeInsets.zero,
  //                                     constraints: const BoxConstraints(),
  //                                     icon: Icon(
  //                                       Icons.remove,
  //                                       size: iconSize,
  //                                       color: AppColors.blackColor,
  //                                     ),
  //                                   ),
  //
  //                                   IconButton(
  //                                     onPressed:
  //                                         (product.stockStatus == "instock")
  //                                             ? () {
  //                                               (product.variations?.length ??
  //                                                           0) ==
  //                                                       0
  //                                                   ? _addSimpleProductsToCart(
  //                                                     product,
  //                                                   )
  //                                                   : _addVariationProductsToCart(
  //                                                     product,
  //                                                     product
  //                                                         .firstVariation
  //                                                         ?.id,
  //                                                     product
  //                                                         .firstVariation
  //                                                         ?.varAttributes
  //                                                         ?.getKey(),
  //                                                     product
  //                                                         .firstVariation
  //                                                         ?.varAttributes
  //                                                         ?.getValue(),
  //                                                   );
  //                                             }
  //                                             : null,
  //                                     padding: EdgeInsets.zero,
  //                                     constraints: const BoxConstraints(),
  //                                     icon: Icon(
  //                                       Icons.add,
  //                                       size: iconSize,
  //                                       color: AppColors.blackColor,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             );
  //                           },
  //                         ),
  //                       ),
  //
  //                     if (product.stockStatus != 'instock')
  //                       Positioned.fill(
  //                         child: Container(
  //                           color: Colors.black.withValues(alpha: 0.4),
  //                           // <-- fix here
  //                           child: Center(
  //                             child: Text(
  //                               "Out of Stock",
  //                               style: TextStyle(
  //                                 fontSize: 14.sp,
  //                                 fontFamily: FontFamily.bold,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //
  //             // Details
  //             Padding(
  //               padding: EdgeInsets.all(2.w),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // Title
  //                   Text(
  //                     product.name ?? '',
  //                     style: TextStyle(
  //                       fontFamily: FontFamily.bold,
  //                       fontSize: 15.sp,
  //                       color: AppColors.blackColor,
  //                     ),
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                   SizedBox(height: 0.5.h),
  //
  //                   // Pack Size + Price Row
  //                   product.variations?.length == 0 ||
  //                           product.variations == null
  //                       ? Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Text(
  //                             product.packSize == ""
  //                                 ? 'MOQ : 1'
  //                                 : 'MOQ : ${product.packSize}',
  //                             style: TextStyle(
  //                               fontSize: 14.sp,
  //                               fontFamily: FontFamily.regular,
  //                               color: AppColors.gray,
  //                             ),
  //                           ),
  //                           Text(
  //                             "${product.cartQuantity == 0 || product.cartQuantity == null || product.cartQuantity == "" || product.cartQuantity == "0" ? "" : product.cartQuantity}",
  //                             style: TextStyle(
  //                               fontSize: 14.sp,
  //                               fontFamily: FontFamily.semiBold,
  //                               color: AppColors.mainColor,
  //                             ),
  //                           ),
  //                         ],
  //                       )
  //                       : Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Text(
  //                             'MOQ : ${product.firstVariation?.packSize}',
  //                             style: TextStyle(
  //                               fontSize: 14.sp,
  //                               fontFamily: FontFamily.regular,
  //                               color: AppColors.gray,
  //                             ),
  //                           ),
  //                           Text(
  //                             "${product.cartQuantity == 0 || product.cartQuantity == null || product.cartQuantity == "" || product.cartQuantity == "0" ? "" : product.cartQuantity}",
  //                             style: TextStyle(
  //                               fontSize: 14.sp,
  //                               fontFamily: FontFamily.semiBold,
  //                               color: AppColors.mainColor,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildGridItem(
    CategoryWiseProductsModal product, {
    double scale = 1.0,
  }) {
    final bool hasVariations = (product.variations?.isNotEmpty ?? false);
    final int qty = int.tryParse(product.cartQuantity?.toString() ?? '0') ?? 0;

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

    final imgs = (product.images ?? []);
    final safeCount =
        imgs.isNotEmpty ? imgs.length : 1; // show placeholder if empty

    return InkWell(
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
                  message: "${product.name} is not available right now!",
                );
              },
      child: Opacity(
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
                    // ============== IMAGE SLIDER (square) =================
                    AspectRatio(
                      aspectRatio: 1,
                      child: CarouselSlider.builder(
                        itemCount:
                            (product.images?.length ?? 0) > 0
                                ? product.images!.length
                                : 1,
                        options: CarouselOptions(
                          viewportFraction: 1,
                          enableInfiniteScroll:
                              (product.images?.length ?? 0) > 1,
                          enlargeCenterPage: false,
                          autoPlay: (product.images?.length ?? 0) > 1,
                          autoPlayInterval: const Duration(seconds: 4),
                        ),
                        itemBuilder: (_, i, __) {
                          final src =
                              (product.images?.isNotEmpty ?? false)
                                  ? (product.images![i].src ?? '')
                                  : '';

                          return ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                px(16),
                              ), // keep top rounded only
                            ),
                            child: CustomNetworkImage(
                              imageUrl: src,
                              height: double.infinity,
                              width: double.infinity,
                              isFit: true,
                              // ✅ keep full cover
                              radius: 0, // ✅ avoid inner corner rounding
                            ),
                          );
                        },
                      ),
                    ),
                    // ================= TITLE =================
                    Padding(
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
                      padding: EdgeInsets.fromLTRB(
                        px(10),
                        px(6),
                        px(10),
                        px(10),
                      ),
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
                                    qty.toString(), // ALWAYS SHOW
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
                              padding:  EdgeInsets.only(right: 1.w),
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
                      // light frost overlay, cleaner UI
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

  // 1) Group + sort by subcategory (and sort items inside each group if you want)
  List<MapEntry<String, List<CategoryWiseProductsModal>>> _groupBySubcategory(
    List<CategoryWiseProductsModal> products,
  ) {
    final map = <String, List<CategoryWiseProductsModal>>{};

    for (final p in products) {
      final key =
          (p.subCategoryName?.trim().isNotEmpty ?? false)
              ? p.subCategoryName!.trim()
              : 'Uncategorized';
      map.putIfAbsent(key, () => []).add(p);
    }

    final sections =
        map.entries.toList()
          ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    for (final e in sections) {
      e.value.sort(
        (a, b) => (a.name ?? '').toLowerCase().compareTo(
          (b.name ?? '').toLowerCase(),
        ),
      );
    }

    return sections;
  }

  // 2) Build the grouped UI: subcategory grid -> divider -> next subcategory grid
  Widget buildGroupedProducts(
    List<CategoryWiseProductsModal> allProducts, {
    required bool isIpad,
  }) {
    final sections = _groupBySubcategory(allProducts);

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      itemCount: sections.length,
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder:
          (_, __) => Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Divider(thickness: 1.2, color: AppColors.border),
          ),
      itemBuilder: (context, index) {
        final subcat = sections[index].key;
        final items = sections[index].value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 0.5.w, bottom: 0.8.h),
              child: Text(
                subcat,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: FontFamily.semiBold,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            GridView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isIpad ? 3 : 2,
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.w,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (_, i) => _buildGridItem(items[i]),
            ),
          ],
        );
      },
    );
  }

  // Widget buildGroupedGrid(List<CategoryWiseProductsModal> filteredProducts) {
  //   final Map<String, List<CategoryWiseProductsModal>> grouped = {};
  //
  //   for (var p in filteredProducts) {
  //     final key =
  //         (p.subCategoryName ?? "").trim().isEmpty
  //             ? "Others"
  //             : p.subCategoryName!.trim();
  //     grouped.putIfAbsent(key, () => []).add(p);
  //   }
  //
  //   final sortedGroups =
  //       grouped.entries.toList()
  //         ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
  //
  //   return ListView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemCount: sortedGroups.length,
  //     itemBuilder: (context, index) {
  //       final subCategory = sortedGroups[index].key;
  //       final products = sortedGroups[index].value;
  //
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           GridView.count(
  //             shrinkWrap: true,
  //             padding: EdgeInsets.zero,
  //             physics: const NeverScrollableScrollPhysics(),
  //             crossAxisCount: itemsPerPage,
  //             childAspectRatio: 0.75,
  //             mainAxisSpacing: 1.h,
  //             crossAxisSpacing: 2.w,
  //             children: products.map((p) => _buildGridItem(p)).toList(),
  //           ),
  //           if (index != sortedGroups.length - 1)
  //             Padding(
  //               padding: EdgeInsets.symmetric(vertical: 1.h),
  //               child: const DashedDivider(
  //                 height: 1.2,
  //                 color: AppColors.blueColor, // or AppColors.mainColor
  //               ),
  //             ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
        // grid math
        const spacing = 12.0;
        final cross = itemsPerPage;
        final totalSpacing = spacing * (cross - 1);
        final colWidth = (constraints.maxWidth - totalSpacing) / cross;

        // scale used by your card
        final scale = (colWidth / 220.0).clamp(0.75, 1.15);

        double extraTextTitle = 20; // title line height
        double extraRow = 40; // MOQ + counter row height
        double extraPaddings = 24; // vertical paddings/margins
        final double extra =
            (extraTextTitle + extraRow + extraPaddings) * scale;

        // total height = image (colWidth) + extras
        final double totalHeight = colWidth + extra;

        // final ratio
        double childAspectRatio = colWidth / totalHeight;

        // safety clamps (avoid too-short or too-tall tiles)
        childAspectRatio = childAspectRatio.clamp(0.60, 0.95);

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedGroups.length,
          itemBuilder: (context, index) {
            final products = sortedGroups[index].value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  itemCount: products.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cross,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: childAspectRatio, // ✅ dynamic & safe
                  ),
                  itemBuilder:
                      (_, i) => _buildGridItem(products[i], scale: scale),
                ),
                if (index != sortedGroups.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: DashedDivider(
                      height: 1.2,
                      color: AppColors.blueColor,
                    ),
                  ),
              ],
            );
          },
        );
      },
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
