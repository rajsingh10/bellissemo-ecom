import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/utils/customMenuDrawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../apiCalling/Check Internet Module.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/colors.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/emptyWidget.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/searchFields.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/titlebarWidget.dart';
import '../../products/view/productsScreen.dart';
import '../modal/fetchCategoriesModal.dart';
import '../provider/categoriesProvider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int itemsPerPage = 4;
  int currentPage = 0;
  final List<int> itemsPerPageOptions = [4, 8, 12, 16];

  List<FetchCategoriesModal> filteredCategories = [];
  List<FetchCategoriesModal> categoriesList = [];

  String selectedSort = "A-Z";
  final List<String> sortOptions = ["A-Z", "Z-A"];

  final GlobalKey<ScaffoldState> _scaffoldKeyCatalog =
      GlobalKey<ScaffoldState>();

  bool isSearchEnabled = false;
  bool isLoading = true;
  bool isIpad = 100.w >= 800;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      _filterCategories(searchController.text);
    });

    setState(() {
      itemsPerPage = 100.w >= 800 ? 8 : 4;
    });

    loadInitialData();
  }

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);

    // Load cached data first
    _loadCachedData();

    final stopwatch = Stopwatch()..start();

    try {
      await _fetchCategories();
      _filterCategories();
    } catch (e) {
      log("Error loading initial data: $e");
    } finally {
      stopwatch.stop();
      log("All API calls completed in ${stopwatch.elapsed.inMilliseconds} ms");
      setState(() => isLoading = false);
    }
  }

  void _loadCachedData() {
    var categoriesBox = HiveService().getCategoriesBox();
    final cachedCategories = categoriesBox.get('categories');
    if (cachedCategories != null) {
      final List data = json.decode(cachedCategories);
      categoriesList =
          data.map((e) => FetchCategoriesModal.fromJson(e)).toList();
      filteredCategories = List.from(categoriesList);
    }
    setState(() {});
  }

  Future<void> _fetchCategories() async {
    var box = HiveService().getCategoriesBox();

    if (!await checkInternet()) {
      // ✅ Load from Hive if offline
      final cachedData = box.get('categories');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        categoriesList =
            data.map((e) => FetchCategoriesModal.fromJson(e)).toList();
      }

      showCustomErrorSnackbar(
        title: 'No Internet',
        message: 'Loaded cached categories (if available).',
      );
      return;
    }

    try {
      final response = await CategoriesProvider().fetchCategoriesApi();
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        categoriesList =
            data.map((e) => FetchCategoriesModal.fromJson(e)).toList();

        // ✅ Save fresh API data into Hive
        await box.put('categories', response.body);
      } else {
        // API error → fallback to cache
        final cachedData = box.get('categories');
        if (cachedData != null) {
          final List data = json.decode(cachedData);
          categoriesList =
              data.map((e) => FetchCategoriesModal.fromJson(e)).toList();
        }

        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Loaded cached data (if available).',
        );
      }
    } catch (_) {
      // Network exception → fallback to cache
      final cachedData = box.get('categories');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        categoriesList =
            data.map((e) => FetchCategoriesModal.fromJson(e)).toList();
      }

      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Loaded cached data (if available).',
      );
    }
  }

  void _filterCategories([String query = ""]) {
    setState(() {
      if (query.isEmpty) {
        filteredCategories = List.from(categoriesList);
      } else {
        filteredCategories =
            categoriesList
                .where(
                  (c) => c.name!.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }

      // Sorting
      if (selectedSort == "A-Z") {
        filteredCategories.sort((a, b) => a.name!.compareTo(b.name!));
      } else if (selectedSort == "Z-A") {
        filteredCategories.sort((a, b) => b.name!.compareTo(a.name!));
      }

      currentPage = 0;
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    return 100.w >= 800 ? 4 : 2;
  }

  @override
  Widget build(BuildContext context) {
    int startIndex = currentPage * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage).clamp(
      0,
      filteredCategories.length,
    );
    List<FetchCategoriesModal> currentPageCategories = filteredCategories
        .sublist(startIndex, endIndex);

    final ScrollController scrollController = ScrollController();

    return Scaffold(
      key: _scaffoldKeyCatalog,
      drawer: CustomDrawer(),
      backgroundColor: AppColors.bgColor,
      body:
          isLoading
              ? Loader()
              : Column(
                children: [
                  TitleBar(
                    title: 'Catalogs',
                    isDrawerEnabled: true,
                    isSearchEnabled: true,
                    drawerCallback: () {
                      _scaffoldKeyCatalog.currentState?.openDrawer();
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
                          if (filteredCategories.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Sort Dropdown
                                  _buildSortDropdown(),

                                  // Items per Page Dropdown
                                  _buildItemsPerPageDropdown(),
                                ],
                              ),
                            ),
                          SizedBox(height: 1.h),

                          filteredCategories.isEmpty
                              ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 15.h),
                                child: emptyWidget(
                                  icon: Icons.category,
                                  text: 'Categories',
                                ),
                              )
                              : Column(
                                children: [
                                  GridView.count(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    crossAxisCount: _getCrossAxisCount(context),
                                    childAspectRatio: 0.8,
                                    mainAxisSpacing: 1.h,
                                    crossAxisSpacing: 2.w,
                                    children:
                                        currentPageCategories
                                            .map((c) => _buildGridItem(c))
                                            .toList(),
                                  ),
                                  SizedBox(height: 2.h),
                                  if (filteredCategories.length > itemsPerPage)
                                    _buildPagination(scrollController),
                                  SizedBox(height: 2.h),
                                ],
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
      bottomNavigationBar: SizedBox(
        height: isIpad ? 14.h : 10.h,
        child: CustomBar(selected: 1),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
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
                  sortOptions
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontFamily: FontFamily.semiBold,
                              color: AppColors.mainColor,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedSort = value);
                  _filterCategories();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsPerPageDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
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
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: itemsPerPage,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.mainColor,
              ),
              items:
                  itemsPerPageOptions
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.toString(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontFamily: FontFamily.semiBold,
                              color: AppColors.mainColor,
                            ),
                          ),
                        ),
                      )
                      .toList(),
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
    );
  }

  Widget _buildPagination(ScrollController scrollController) {
    int startIndex = currentPage * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage).clamp(
      0,
      filteredCategories.length,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageButton(
          icon: Icons.arrow_back_ios_new,
          enabled: currentPage > 0,
          onTap: () {
            if (currentPage > 0) {
              setState(() => currentPage--);
              scrollController.animateTo(
                0,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          },
        ),
        SizedBox(width: 4.w),
        Text(
          "Page ${currentPage + 1}",
          style: TextStyle(
            fontSize: 15.sp,
            fontFamily: FontFamily.semiBold,
            color: AppColors.blackColor,
          ),
        ),
        SizedBox(width: 4.w),
        _pageButton(
          icon: Icons.arrow_forward_ios,
          enabled: endIndex < filteredCategories.length,
          onTap: () {
            if (endIndex < filteredCategories.length) {
              setState(() => currentPage++);
              scrollController.animateTo(
                0,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _pageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.all(isIpad ? 1.2.w : 1.5.w),
        decoration: BoxDecoration(
          color: enabled ? AppColors.mainColor : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: isIpad ? 15.sp : 18.sp, color: Colors.white),
      ),
    );
  }

  Widget _buildGridItem(FetchCategoriesModal category) {
    return InkWell(
      onTap: () {
        Get.to(
          () => ProductsScreen(cate: category.name, id: category.id.toString()),
          transition: Transition.leftToRightWithFade,
          duration: const Duration(milliseconds: 450),
        );
      },
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
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: CustomNetworkImage(
                  imageUrl: category.image?.src ?? '',
                  height: double.infinity,
                  width: double.infinity,
                  isFit: true,
                  radius: 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name ?? '',
                    style: TextStyle(
                      fontFamily: FontFamily.bold,
                      fontSize: 15.sp,
                      color: AppColors.blackColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "${category.count} products",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: FontFamily.regular,
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
