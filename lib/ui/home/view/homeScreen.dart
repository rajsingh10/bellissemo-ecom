import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/apiConfigs.dart';
import 'package:bellissemo_ecom/ui/customers/modal/fetchCustomersModal.dart';
import 'package:bellissemo_ecom/ui/customers/provider/customerProvider.dart';
import 'package:bellissemo_ecom/ui/home/provider/homeProvider.dart';
import 'package:bellissemo_ecom/ui/products/modal/fetchProductsModal.dart';
import 'package:bellissemo_ecom/ui/products/provider/productsProvider.dart';
import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/multipleImagesSlider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../apiCalling/Loader.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/customButton.dart';
import '../../../utils/customMenuDrawer.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/searchFields.dart';
import '../../../utils/snackBars.dart';
import '../../cart/service/cartServices.dart';
import '../../category/modal/fetchCategoriesModal.dart';
import '../../category/provider/categoriesProvider.dart';
import '../../category/view/categoryScreen.dart';
import '../../products/view/productDetailsScreen.dart';
import '../../products/view/productsScreen.dart';
import '../../profile/modal/profileModal.dart';
import '../../profile/provider/profileProvider.dart';
import '../modal/bannersModal.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyHome = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();

  bool searchBar = false;
  List<FetchCategoriesModal> categoriesList = [];
  List<BannersModal> bannersList = [];
  List<String> bannersImagesList = [];
  List<FetchCustomersModal> customersList = [];
  List<FetchProductsModal> productsList = [];
  int? customerId;

  int _getCrossAxisCount(BuildContext context) {
    if (isIpad) {
      return 4;
    } else {
      return 2;
    }
  }

  bool isAddingToCart = false;
  bool isIpad = 100.w >= 800;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> checkCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt("customerId");

    // If no customer selected, show the popup
    if (customerId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSelectCustomerDialog();
      });
    }
  }

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);

    // Load cached data first for immediate display
    _loadCachedData();

    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([
        _fetchCategories().then((_) => setState(() {})),
        _fetchCustomers().then(
          (_) => setState(() {
            checkCustomer();
          }),
        ),
        _fetchProducts().then((_) => setState(() {})),
        _fetchBanner().then((_) => setState(() {})),
        _fetchProfile().then((_) => setState(() {})),
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
    var categoriesBox = HiveService().getCategoriesBox();
    var bannerBox = HiveService().getBannerBox();
    var profileBox = HiveService().getProfileBox();
    var customerBox = HiveService().getCustomerBox();
    var productsBox = HiveService().getProductsBox();

    final cachedCategories = categoriesBox.get('categories');
    if (cachedCategories != null) {
      final List data = json.decode(cachedCategories);
      categoriesList =
          data.map((e) => FetchCategoriesModal.fromJson(e)).toList();
    }

    final cachedCustomers = customerBox.get('customers');
    if (cachedCustomers != null) {
      final List data = json.decode(cachedCustomers);
      customersList = data.map((e) => FetchCustomersModal.fromJson(e)).toList();
    }
    final cachedProducts = productsBox.get('products');
    if (cachedProducts != null) {
      final List data = json.decode(cachedProducts);
      productsList = data.map((e) => FetchProductsModal.fromJson(e)).toList();
    }

    final cachedBanner = bannerBox.get('banner');
    if (cachedBanner != null) {
      final List data = json.decode(cachedBanner);
      bannersList = data.map((e) => BannersModal.fromJson(e)).toList();
      bannersImagesList =
          bannersList.map((b) => b.featuredImageUrl ?? '').toList();
    }

    final cachedProfile = profileBox.get('profile');
    if (cachedProfile != null) {
      profile = ProfileModal.fromJson(json.decode(cachedProfile));
    }
    setState(() {});
  }

  Map<int, int> quantities = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyHome,
      drawer: CustomDrawer(),
      backgroundColor: AppColors.containerColor,
      body:
          isLoading
              ? Loader()
              : Stack(
                children: [
                  SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0.w,
                        vertical: 0.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(40),
                                bottomLeft: Radius.circular(40),
                              ),
                              color: AppColors.bgColor,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 6.5.h,
                                right: 3.w,
                                left: 3.w,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              _scaffoldKeyHome.currentState
                                                  ?.openDrawer();
                                            },
                                            child: CircleAvatar(
                                              radius: isIpad ? 40 : 20,
                                              backgroundColor:
                                                  AppColors.containerColor,
                                              child: Icon(
                                                CupertinoIcons.bars,
                                                color: AppColors.blackColor,
                                                size: isIpad ? 40 : 25,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 2.w),
                                          SizedBox(
                                            width: 40.w,
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "Hy, ",
                                                    style: TextStyle(
                                                      fontSize: 17.sp,
                                                      color: AppColors.gray,
                                                      fontFamily:
                                                          FontFamily.light,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: profile?.name ?? '',
                                                    style: TextStyle(
                                                      fontSize: 17.sp,
                                                      color:
                                                          AppColors.blackColor,
                                                      fontFamily:
                                                          FontFamily.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                barrierDismissible: false,

                                                context: context,
                                                builder: (
                                                  BuildContext context,
                                                ) {
                                                  int? selectedCustomerId;
                                                  String? selectedCustomerName;
                                                  String? errorText;

                                                  return FutureBuilder(
                                                    future:
                                                        SharedPreferences.getInstance(),
                                                    builder: (
                                                      context,
                                                      snapshot,
                                                    ) {
                                                      if (!snapshot.hasData) {
                                                        return Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        );
                                                      }

                                                      final prefs =
                                                          snapshot.data!;
                                                      selectedCustomerId = prefs
                                                          .getInt("customerId");
                                                      selectedCustomerName =
                                                          prefs.getString(
                                                            "customerName",
                                                          );

                                                      return StatefulBuilder(
                                                        builder: (
                                                          context,
                                                          setState,
                                                        ) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                AppColors
                                                                    .whiteColor,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    15,
                                                                  ),
                                                            ),
                                                            title: Text(
                                                              "Select Customer",
                                                              style: TextStyle(
                                                                fontSize: 18.sp,
                                                                fontFamily:
                                                                    FontFamily
                                                                        .bold,
                                                                color:
                                                                    AppColors
                                                                        .blackColor,
                                                              ),
                                                            ),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                // List of customers
                                                                ...customersList.map((
                                                                  customer,
                                                                ) {
                                                                  bool
                                                                  isSelected =
                                                                      selectedCustomerId ==
                                                                      customer
                                                                          .id;
                                                                  return InkWell(
                                                                    onTap: () {
                                                                      setState(() {
                                                                        selectedCustomerId =
                                                                            customer.id;
                                                                        selectedCustomerName =
                                                                            "${customer.firstName} ${customer.lastName}";
                                                                        errorText =
                                                                            null; // clear error
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
                                                                      decoration: BoxDecoration(
                                                                        color:
                                                                            isSelected
                                                                                ? AppColors.mainColor.withValues(
                                                                                  alpha:
                                                                                      0.1,
                                                                                )
                                                                                : AppColors.whiteColor,
                                                                        border: Border.all(
                                                                          color:
                                                                              isSelected
                                                                                  ? AppColors.mainColor
                                                                                  : AppColors.gray,
                                                                          width:
                                                                              1,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                      ),
                                                                      child: Row(
                                                                        children: [
                                                                          Icon(
                                                                            isSelected
                                                                                ? Icons.radio_button_checked
                                                                                : Icons.radio_button_off,
                                                                            color:
                                                                                isSelected
                                                                                    ? AppColors.mainColor
                                                                                    : AppColors.gray,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Text(
                                                                            "${customer.firstName} ${customer.lastName}",
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  16.sp,
                                                                              fontFamily:
                                                                                  FontFamily.regular,
                                                                              color:
                                                                                  AppColors.blackColor,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                }),
                                                                if (errorText !=
                                                                    null) ...[
                                                                  SizedBox(
                                                                    height: 8,
                                                                  ),
                                                                  Text(
                                                                    errorText!,
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .red,
                                                                      fontSize:
                                                                          14.sp,
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
                                                                title:
                                                                    "Confirm",
                                                                route: () async {
                                                                  if (selectedCustomerId !=
                                                                          null &&
                                                                      selectedCustomerName !=
                                                                          null) {
                                                                    final prevCustomerId =
                                                                        prefs.getInt(
                                                                          "customerId",
                                                                        );

                                                                    if (prevCustomerId !=
                                                                        selectedCustomerId) {
                                                                      // Customer changed -> save new values and clear cart
                                                                      await prefs.setInt(
                                                                        "customerId",
                                                                        selectedCustomerId!,
                                                                      );
                                                                      await prefs.setString(
                                                                        "customerName",
                                                                        selectedCustomerName!,
                                                                      );
                                                                      _clearCart();
                                                                    } else {
                                                                      // Customer did not change -> just close dialog
                                                                      Get.back();
                                                                    }
                                                                  } else {
                                                                    setState(() {
                                                                      errorText =
                                                                          " Please select a customer before proceeding.";
                                                                    });
                                                                  }
                                                                },
                                                                color:
                                                                    AppColors
                                                                        .mainColor,
                                                                fontcolor:
                                                                    AppColors
                                                                        .whiteColor,
                                                                height: 5.h,
                                                                width: 27.w,
                                                                fontsize: 15.sp,
                                                                radius: 12.0,
                                                                iconData:
                                                                    Icons.check,
                                                                iconsize: 17.sp,
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },

                                            child: CircleAvatar(
                                              radius: isIpad ? 40 : 20,
                                              backgroundColor:
                                                  AppColors.containerColor,
                                              child: Icon(
                                                Icons.person_outline_rounded,
                                                color: AppColors.blackColor,
                                                size: isIpad ? 35 : 25,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: isIpad ? 2.w : 3.5.w),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                searchBar =
                                                    !searchBar; // toggle visibility
                                              });
                                            },
                                            child: CircleAvatar(
                                              radius: isIpad ? 40 : 20,
                                              backgroundColor:
                                                  AppColors.containerColor,
                                              child: Icon(
                                                Icons.search,
                                                color: AppColors.blackColor,
                                                size: isIpad ? 35 : 25,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: isIpad ? 2.w : 3.5.w),
                                          Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: isIpad ? 40 : 20,
                                                backgroundColor:
                                                    AppColors.containerColor,
                                                child: Icon(
                                                  Icons.notifications_none,
                                                  color: AppColors.blackColor,
                                                  size: isIpad ? 35 : 25,
                                                ),
                                              ),
                                              Positioned(
                                                right: 2,
                                                top: 2,
                                                child: CircleAvatar(
                                                  radius: isIpad ? 10 : 6,
                                                  backgroundColor:
                                                      AppColors.counterColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                  if (searchBar)
                                    SearchField(
                                      controller: searchController,
                                      hintText: "Search the entire shop",
                                    ),
                                  SizedBox(height: 1.h),

                                  ImageSlider(
                                    imageUrls: bannersImagesList,
                                    height: 18.h,
                                  ),

                                  SizedBox(height: 2.h),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 2.h),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                topLeft: Radius.circular(40),
                              ),
                              color: AppColors.bgColor,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 2.5.h,
                                right: 4.w,
                                left: 4.w,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Categories",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontFamily: FontFamily.bold,
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.offAll(
                                            () => CategoriesScreen(),
                                            transition: Transition.fade,
                                            duration: const Duration(
                                              milliseconds: 450,
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              "View All",
                                              style: TextStyle(
                                                fontSize:
                                                    isIpad ? 14.sp : 16.sp,
                                                fontFamily: FontFamily.bold,
                                                color: AppColors.gray,
                                              ),
                                            ),
                                            SizedBox(width: 1.w),
                                            CircleAvatar(
                                              radius: 15,
                                              backgroundColor:
                                                  AppColors.mainColor,
                                              child: Icon(
                                                Icons.arrow_forward,
                                                color: AppColors.whiteColor,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2.h),

                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        for (
                                          int i = 0;
                                          i < (categoriesList.length);
                                          i++
                                        )
                                          InkWell(
                                            onTap: () {
                                              Get.to(
                                                () => ProductsScreen(
                                                  cate: categoriesList[i].name,
                                                  slug: categoriesList[i].slug,
                                                  id:
                                                      categoriesList[i].id
                                                          .toString(),
                                                ),
                                                transition:
                                                    Transition
                                                        .leftToRightWithFade,
                                                duration: const Duration(
                                                  milliseconds: 450,
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                left: i == 0 ? 0 : 10,
                                                right: 10,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Material(
                                                    shape: CircleBorder(),
                                                    elevation: 2,
                                                    clipBehavior: Clip.hardEdge,
                                                    child: InkWell(
                                                      onTap: () {
                                                        // handle tap
                                                      },
                                                      customBorder:
                                                          CircleBorder(),
                                                      child: ClipOval(
                                                        child:
                                                            isIpad
                                                                ? CustomNetworkImage(
                                                                  imageUrl:
                                                                      categoriesList[i]
                                                                          .image
                                                                          ?.src ??
                                                                      '',
                                                                  width: 10.w,
                                                                  height: 10.w,
                                                                  isProfile:
                                                                      false,
                                                                )
                                                                : CustomNetworkImage(
                                                                  imageUrl:
                                                                      categoriesList[i]
                                                                          .image
                                                                          ?.src ??
                                                                      '',
                                                                  width: 15.w,
                                                                  height: 15.w,
                                                                  isProfile:
                                                                      false,
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 1.h),
                                                  SizedBox(
                                                    width: 15.w,
                                                    child: Text(
                                                      categoriesList[i].name
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,

                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontFamily:
                                                            FontFamily.light,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors
                                                                .blackColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: isIpad ? 4.h : 2.h),
                                  InkWell(
                                    onTap: () {
                                      Get.to(
                                        () => CategoriesScreen(),
                                        transition:
                                            Transition.leftToRightWithFade,
                                        duration: const Duration(
                                          milliseconds: 450,
                                        ),
                                      );
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Products",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontFamily: FontFamily.bold,
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "View All",
                                              style: TextStyle(
                                                fontSize:
                                                    isIpad ? 14.sp : 16.sp,
                                                fontFamily: FontFamily.bold,
                                                color: AppColors.gray,
                                              ),
                                            ),
                                            SizedBox(width: 1.w),
                                            CircleAvatar(
                                              radius: 15,
                                              backgroundColor:
                                                  AppColors.mainColor,
                                              child: Icon(
                                                Icons.arrow_forward,
                                                color: AppColors.whiteColor,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  GridView.count(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics: ClampingScrollPhysics(),
                                    crossAxisCount: _getCrossAxisCount(context),
                                    childAspectRatio: 0.75,
                                    mainAxisSpacing: 1.h,
                                    crossAxisSpacing: 2.w,
                                    children:
                                        productsList
                                            .where(
                                              (p) => p.stockStatus == 'instock',
                                            )
                                            .take(isIpad ? 8 : 6)
                                            .map((p) => _buildGridItem(p))
                                            .toList(),
                                  ),

                                  SizedBox(height: 1.h),
                                ],
                              ),
                            ),
                          ),
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
      bottomNavigationBar: SizedBox(
        height: isIpad ? 14.h : 10.h,
        child: CustomBar(selected: 3),
      ),
    );
  }

  Widget _buildGridItem(FetchProductsModal product) {
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
                                          log('hello');
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
                                        : () {
                                          log('Kaaaa');
                                        },
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

  Future<void> _fetchCategories() async {
    var box = HiveService().getCategoriesBox();

    if (!await checkInternet()) {
      final cachedData = box.get('categories');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        categoriesList =
            data
                .map<FetchCategoriesModal>(
                  (e) => FetchCategoriesModal.fromJson(e),
                )
                .toList();
      } else {
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
      }
      return;
    }

    try {
      final response = await CategoriesProvider().fetchCategoriesApi();
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        categoriesList =
            data
                .map<FetchCategoriesModal>(
                  (e) => FetchCategoriesModal.fromJson(e),
                )
                .toList();

        await box.put('categories', response.body);
      } else {
        final cachedData = box.get('categories');
        if (cachedData != null) {
          final List data = json.decode(cachedData);
          categoriesList =
              data
                  .map<FetchCategoriesModal>(
                    (e) => FetchCategoriesModal.fromJson(e),
                  )
                  .toList();
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      final cachedData = box.get('categories');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        categoriesList =
            data
                .map<FetchCategoriesModal>(
                  (e) => FetchCategoriesModal.fromJson(e),
                )
                .toList();
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }

  Future<void> _fetchCustomers() async {
    var box = HiveService().getCustomerBox();

    if (!await checkInternet()) {
      final cachedData = box.get('customers');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        customersList =
            data
                .map<FetchCustomersModal>(
                  (e) => FetchCustomersModal.fromJson(e),
                )
                .toList();
      } else {
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
      }
      return;
    }

    try {
      final response = await CustomerProvider().fetchCustomers();
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        customersList =
            data
                .map<FetchCustomersModal>(
                  (e) => FetchCustomersModal.fromJson(e),
                )
                .toList();

        await box.put('customers', response.body);
      } else {
        final cachedData = box.get('customers');
        if (cachedData != null) {
          final List data = json.decode(cachedData);
          customersList =
              data
                  .map<FetchCustomersModal>(
                    (e) => FetchCustomersModal.fromJson(e),
                  )
                  .toList();
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      final cachedData = box.get('customers');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        customersList =
            data
                .map<FetchCustomersModal>(
                  (e) => FetchCustomersModal.fromJson(e),
                )
                .toList();
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }

  Future<void> _fetchProducts() async {
    var box = HiveService().getProductsBox();

    if (!await checkInternet()) {
      final cachedData = box.get('products');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        productsList =
            data
                .map<FetchProductsModal>((e) => FetchProductsModal.fromJson(e))
                .toList();
      } else {
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
      }
      return;
    }

    try {
      final response = await ProductsProvider().fetchProducts();
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        productsList =
            data
                .map<FetchProductsModal>((e) => FetchProductsModal.fromJson(e))
                .toList();

        await box.put('products', response.body);
      } else {
        final cachedData = box.get('products');
        if (cachedData != null) {
          final List data = json.decode(cachedData);
          productsList =
              data
                  .map<FetchProductsModal>(
                    (e) => FetchProductsModal.fromJson(e),
                  )
                  .toList();
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      final cachedData = box.get('products');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        productsList =
            data
                .map<FetchProductsModal>((e) => FetchProductsModal.fromJson(e))
                .toList();
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }

  Future<void> _fetchBanner() async {
    var box = HiveService().getBannerBox();

    if (!await checkInternet()) {
      // Load cached banner if offline
      final cachedData = box.get('banner');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        bannersList = data.map((e) => BannersModal.fromJson(e)).toList();
      } else {
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
      }
      return;
    }

    try {
      final response = await HomeProvider().fetchBanners();
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        bannersList = data.map((e) => BannersModal.fromJson(e)).toList();
        bannersImagesList =
            bannersList.map((banner) => banner.featuredImageUrl ?? '').toList();
        // Save banner to Hive
        await box.put('banner', response.body);
      } else {
        // Fallback: load cache if server fails
        final cachedData = box.get('banner');
        if (cachedData != null) {
          final List data = json.decode(cachedData);
          bannersList = data.map((e) => BannersModal.fromJson(e)).toList();
          bannersImagesList =
              bannersList
                  .map((banner) => banner.featuredImageUrl ?? '')
                  .toList();
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      // Fallback: load cache on network error
      final cachedData = box.get('banner');
      if (cachedData != null) {
        final List data = json.decode(cachedData);
        bannersList = data.map((e) => BannersModal.fromJson(e)).toList();
        bannersImagesList =
            bannersList.map((banner) => banner.featuredImageUrl ?? '').toList();
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }

  Future<void> _fetchProfile() async {
    var box = HiveService().getProfileBox();

    if (!await checkInternet()) {
      final cachedData = box.get('profile');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        profile = ProfileModal.fromJson(data);
      } else {
        showCustomErrorSnackbar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
      }
      return;
    }

    try {
      final response = await ProfileProvider().fetchProfile();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        profile = ProfileModal.fromJson(data);
        await box.put('profile', response.body);
      } else {
        final cachedData = box.get('profile');
        if (cachedData != null) {
          final data = json.decode(cachedData);
          profile = ProfileModal.fromJson(data);
        }
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      final cachedData = box.get('profile');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        profile = ProfileModal.fromJson(data);
      }
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }
  }

  Future<void> _addSimpleProductsToCart(FetchProductsModal product) async {
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
    FetchProductsModal product,
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

  Future<void> _removeProductFromCart(FetchProductsModal product) async {
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

  Future<void> _clearCart() async {
    Get.back();
    setState(() => isAddingToCart = true);
    try {
      final response = await CartService().clearCart();
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 204)) {
        Get.back();
      }
      setState(() => isAddingToCart = false);
    } catch (e) {
      setState(() => isAddingToCart = false);
      showCustomErrorSnackbar(
        title: "Error",
        message: "Failed to clear cart.\n$e",
      );
    } finally {
      setState(() => isAddingToCart = false);
    }
  }

  /// Customer Dialogue
  void _showSelectCustomerDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        int? selectedCustomerId;
        String? selectedCustomerName;
        String? errorText;

        return FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final prefs = snapshot.data!;
            selectedCustomerId = prefs.getInt("customerId");
            selectedCustomerName = prefs.getString("customerName");

            return StatefulBuilder(
              builder: (context, setState) {
                return WillPopScope(
                  onWillPop: () async {
                    setState(() {
                      errorText =
                          " Please select a customer before proceeding.";
                    });
                    return false;
                  }, // Prevent back button
                  child: AlertDialog(
                    backgroundColor: AppColors.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Text(
                      "Select Customer",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: FontFamily.bold,
                        color: AppColors.blackColor,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // List of customers
                        ...customersList.map((customer) {
                          bool isSelected = selectedCustomerId == customer.id;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedCustomerId = customer.id;
                                selectedCustomerName =
                                    "${customer.firstName} ${customer.lastName}";
                                errorText = null; // clear error
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 10,
                              ),
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.mainColor.withAlpha(25)
                                        : AppColors.whiteColor,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppColors.mainColor
                                          : AppColors.gray,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color:
                                        isSelected
                                            ? AppColors.mainColor
                                            : AppColors.gray,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "${customer.firstName} ${customer.lastName}",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontFamily: FontFamily.regular,
                                      color: AppColors.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        if (errorText != null) ...[
                          SizedBox(height: 0.5.h),
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
                      // Disable Cancel button or just show error
                      CustomButton(
                        title: "Cancel",
                        route: () {
                          setState(() {
                            errorText =
                                " Please select a customer before proceeding.";
                          });
                        },
                        color: AppColors.containerColor,
                        fontcolor: AppColors.blackColor,
                        height: 5.h,
                        width: 27.w,
                        fontsize: 15.sp,
                        radius: 12.0,
                      ),
                      CustomButton(
                        title: "Confirm",
                        route: () async {
                          if (selectedCustomerId != null &&
                              selectedCustomerName != null) {
                            final prevCustomerId = prefs.getInt("customerId");

                            if (prevCustomerId != selectedCustomerId) {
                              // Customer changed -> save new values and clear cart
                              await prefs.setInt(
                                "customerId",
                                selectedCustomerId!,
                              );
                              await prefs.setString(
                                "customerName",
                                selectedCustomerName!,
                              );
                              _clearCart();
                            }

                            // Close dialog only after saving
                            Get.back();
                          } else {
                            setState(() {
                              errorText =
                                  " Please select a customer before proceeding.";
                            });
                          }
                        },
                        color: AppColors.mainColor,
                        fontcolor: AppColors.whiteColor,
                        height: 5.h,
                        width: 27.w,
                        fontsize: 15.sp,
                        radius: 12.0,
                        iconData: Icons.check,
                        iconsize: 17.sp,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
