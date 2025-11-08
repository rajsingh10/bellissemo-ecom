import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/ui/cart/View/cartScreen.dart';
import 'package:bellissemo_ecom/ui/category/view/categoryScreen.dart';
import 'package:bellissemo_ecom/ui/customers/view/customersScreen.dart';
import 'package:bellissemo_ecom/ui/login/modal/freshTokenModal.dart'
    show FreshTokenModal;
import 'package:bellissemo_ecom/ui/orderhistory/view/orderHistoryScreen.dart';
import 'package:bellissemo_ecom/ui/profile/view/profileScreen.dart';
import 'package:bellissemo_ecom/utils/customButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../ApiCalling/apiConfigs.dart';
import '../../../apiCalling/Loader.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/colors.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/customMenuDrawer.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/images.dart';
import '../../../utils/searchFields.dart';
import '../../../utils/snackBars.dart';
import '../../cart/service/cartServices.dart';
import '../../customers/modal/fetchCustomersModal.dart';
import '../../customers/provider/customerProvider.dart';
import '../../profile/modal/profileModal.dart';
import '../../profile/provider/profileProvider.dart';
import '../../reports/view/reportsScreen.dart';
import '../modal/bannersModal.dart';
import '../provider/homeProvider.dart';

class HomeMenuScreen extends StatefulWidget {
  const HomeMenuScreen({super.key});

  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyHome2 = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();

  bool searchBar = false;
  bool isDrawerOpen = false;
  bool isIpad = 100.w >= 800;
  List<BannersModal> bannersList = [];
  List<String> bannersImagesList = [];
  List<FetchCustomersModal> customersList = [];
  bool isLoading = true;
  bool isAddingToCart = false;

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

  Future<void> initStartupSequence() async {
    // Start stopwatch for performance tracking
    final stopwatch = Stopwatch()..start();

    try {
      setState(() => isLoading = true);

      // 1️⃣ First: Refresh token
      await getTokenApi();

      // 2️⃣ Then: Load initial data (in parallel)
      await loadInitialData();
    } catch (e, st) {
      log("❌ Startup Error: $e");
      log("Stacktrace: $st");
    } finally {
      stopwatch.stop();
      log("✅ All startup tasks done in ${stopwatch.elapsedMilliseconds} ms");
      setState(() => isLoading = false);
    }
  }

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);

    // Load cached data first for immediate display
    _loadCachedData();

    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([
        _fetchProfile().then((_) => setState(() {})),
        _fetchCustomers().then(
          (_) => setState(() {
            checkCustomer();
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
    var profileBox = HiveService().getProfileBox();
    var customerBox = HiveService().getCustomerBox();

    final cachedCustomers = customerBox.get('customers');
    if (cachedCustomers != null) {
      final List data = json.decode(cachedCustomers);
      customersList = data.map((e) => FetchCustomersModal.fromJson(e)).toList();
    }

    final cachedProfile = profileBox.get('profile');
    if (cachedProfile != null) {
      profile = ProfileModal.fromJson(json.decode(cachedProfile));
    }

    setState(() {}); // Refresh UI immediately
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initStartupSequence();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyHome2,
      drawer: CustomDrawer(),
      backgroundColor: AppColors.containerColor,
      body:
          isLoading
              ? Loader()
              : Stack(
                children: [
                  Padding(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            _scaffoldKeyHome2.currentState
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
                                                    color: AppColors.blackColor,
                                                    fontFamily: FontFamily.bold,
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
                                        // GestureDetector(
                                        //   onTap: () {
                                        //     showDialog(
                                        //       barrierDismissible: false,
                                        //
                                        //       context: context,
                                        //       builder: (BuildContext context) {
                                        //         int? selectedCustomerId;
                                        //         String? selectedCustomerName;
                                        //         String? errorText;
                                        //
                                        //         return FutureBuilder(
                                        //           future:
                                        //               SharedPreferences.getInstance(),
                                        //           builder: (context, snapshot) {
                                        //             if (!snapshot.hasData) {
                                        //               return Center(
                                        //                 child:
                                        //                     CircularProgressIndicator(),
                                        //               );
                                        //             }
                                        //
                                        //             final prefs =
                                        //                 snapshot.data!;
                                        //             selectedCustomerId = prefs
                                        //                 .getInt("customerId");
                                        //             selectedCustomerName = prefs
                                        //                 .getString(
                                        //                   "customerName",
                                        //                 );
                                        //
                                        //             return StatefulBuilder(
                                        //               builder: (
                                        //                 context,
                                        //                 setState,
                                        //               ) {
                                        //                 return AlertDialog(
                                        //                   backgroundColor:
                                        //                       AppColors
                                        //                           .whiteColor,
                                        //                   shape: RoundedRectangleBorder(
                                        //                     borderRadius:
                                        //                         BorderRadius.circular(
                                        //                           15,
                                        //                         ),
                                        //                   ),
                                        //                   title: Text(
                                        //                     "Select Customer",
                                        //                     style: TextStyle(
                                        //                       fontSize: 18.sp,
                                        //                       fontFamily:
                                        //                           FontFamily
                                        //                               .bold,
                                        //                       color:
                                        //                           AppColors
                                        //                               .blackColor,
                                        //                     ),
                                        //                   ),
                                        //                   content: Column(
                                        //                     mainAxisSize:
                                        //                         MainAxisSize
                                        //                             .min,
                                        //                     children: [
                                        //                       // List of customers
                                        //                       ...customersList.map((
                                        //                         customer,
                                        //                       ) {
                                        //                         bool
                                        //                         isSelected =
                                        //                             selectedCustomerId ==
                                        //                             customer.id;
                                        //                         return InkWell(
                                        //                           onTap: () {
                                        //                             setState(() {
                                        //                               selectedCustomerId =
                                        //                                   customer
                                        //                                       .id;
                                        //                               selectedCustomerName =
                                        //                                   "${customer.firstName} ${customer.lastName}";
                                        //                               errorText =
                                        //                                   null; // clear error
                                        //                             });
                                        //                           },
                                        //                           child: Container(
                                        //                             padding: EdgeInsets.symmetric(
                                        //                               vertical:
                                        //                                   12,
                                        //                               horizontal:
                                        //                                   10,
                                        //                             ),
                                        //                             margin:
                                        //                                 EdgeInsets.symmetric(
                                        //                                   vertical:
                                        //                                       5,
                                        //                                 ),
                                        //                             decoration: BoxDecoration(
                                        //                               color:
                                        //                                   isSelected
                                        //                                       ? AppColors.mainColor.withValues(
                                        //                                         alpha:
                                        //                                             0.1,
                                        //                                       )
                                        //                                       : AppColors.whiteColor,
                                        //                               border: Border.all(
                                        //                                 color:
                                        //                                     isSelected
                                        //                                         ? AppColors.mainColor
                                        //                                         : AppColors.gray,
                                        //                                 width:
                                        //                                     1,
                                        //                               ),
                                        //                               borderRadius:
                                        //                                   BorderRadius.circular(
                                        //                                     10,
                                        //                                   ),
                                        //                             ),
                                        //                             child: Row(
                                        //                               children: [
                                        //                                 Icon(
                                        //                                   isSelected
                                        //                                       ? Icons.radio_button_checked
                                        //                                       : Icons.radio_button_off,
                                        //                                   color:
                                        //                                       isSelected
                                        //                                           ? AppColors.mainColor
                                        //                                           : AppColors.gray,
                                        //                                 ),
                                        //                                 SizedBox(
                                        //                                   width:
                                        //                                       10,
                                        //                                 ),
                                        //                                 Text(
                                        //                                   "${customer.firstName} ${customer.lastName}",
                                        //                                   style: TextStyle(
                                        //                                     fontSize:
                                        //                                         16.sp,
                                        //                                     fontFamily:
                                        //                                         FontFamily.regular,
                                        //                                     color:
                                        //                                         AppColors.blackColor,
                                        //                                   ),
                                        //                                 ),
                                        //                               ],
                                        //                             ),
                                        //                           ),
                                        //                         );
                                        //                       }),
                                        //                       if (errorText !=
                                        //                           null) ...[
                                        //                         SizedBox(
                                        //                           height: 8,
                                        //                         ),
                                        //                         Text(
                                        //                           errorText!,
                                        //                           style: TextStyle(
                                        //                             color:
                                        //                                 Colors
                                        //                                     .red,
                                        //                             fontSize:
                                        //                                 14.sp,
                                        //                           ),
                                        //                         ),
                                        //                       ],
                                        //                     ],
                                        //                   ),
                                        //                   actions: [
                                        //                     CustomButton(
                                        //                       title: "Cancel",
                                        //                       route: () {
                                        //                         Get.back();
                                        //                       },
                                        //                       color:
                                        //                           AppColors
                                        //                               .containerColor,
                                        //                       fontcolor:
                                        //                           AppColors
                                        //                               .blackColor,
                                        //                       height: 5.h,
                                        //                       width: 27.w,
                                        //                       fontsize: 15.sp,
                                        //                       radius: 12.0,
                                        //                     ),
                                        //                     CustomButton(
                                        //                       title: "Confirm",
                                        //                       route: () async {
                                        //                         if (selectedCustomerId !=
                                        //                                 null &&
                                        //                             selectedCustomerName !=
                                        //                                 null) {
                                        //                           final prevCustomerId =
                                        //                               prefs.getInt(
                                        //                                 "customerId",
                                        //                               );
                                        //
                                        //                           if (prevCustomerId !=
                                        //                               selectedCustomerId) {
                                        //                             // Customer changed -> save new values and clear cart
                                        //                             await prefs.setInt(
                                        //                               "customerId",
                                        //                               selectedCustomerId!,
                                        //                             );
                                        //                             await prefs.setString(
                                        //                               "customerName",
                                        //                               selectedCustomerName!,
                                        //                             );
                                        //                             _clearCart();
                                        //                           } else {
                                        //                             // Customer did not change -> just close dialog
                                        //                             Get.back();
                                        //                           }
                                        //                         } else {
                                        //                           setState(() {
                                        //                             errorText =
                                        //                                 "Please select a customer!";
                                        //                           });
                                        //                         }
                                        //                       },
                                        //                       color:
                                        //                           AppColors
                                        //                               .mainColor,
                                        //                       fontcolor:
                                        //                           AppColors
                                        //                               .whiteColor,
                                        //                       height: 5.h,
                                        //                       width: 27.w,
                                        //                       fontsize: 15.sp,
                                        //                       radius: 12.0,
                                        //                       iconData:
                                        //                           Icons.check,
                                        //                       iconsize: 17.sp,
                                        //                     ),
                                        //                   ],
                                        //                 );
                                        //               },
                                        //             );
                                        //           },
                                        //         );
                                        //       },
                                        //     );
                                        //   },
                                        //
                                        //   child: CircleAvatar(
                                        //     radius: isIpad ? 40 : 20,
                                        //     backgroundColor:
                                        //         AppColors.containerColor,
                                        //     child: Icon(
                                        //       Icons.person_outline_rounded,
                                        //       color: AppColors.blackColor,
                                        //       size: isIpad ? 35 : 25,
                                        //     ),
                                        //   ),
                                        // ),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                int? selectedCustomerId;
                                                String? selectedCustomerName;
                                                String? errorText;
                                                TextEditingController
                                                searchController =
                                                    TextEditingController();

                                                return FutureBuilder(
                                                  future:
                                                      SharedPreferences.getInstance(),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    }

                                                    final prefs =
                                                        snapshot.data!;
                                                    selectedCustomerId = prefs
                                                        .getInt("customerId");
                                                    selectedCustomerName = prefs
                                                        .getString(
                                                          "customerName",
                                                        );

                                                    // Create a mutable list copy for filtering
                                                    List<FetchCustomersModal>
                                                    filteredList = List.from(
                                                      customersList,
                                                    );

                                                    return StatefulBuilder(
                                                      builder: (
                                                        context,
                                                        setState,
                                                      ) {
                                                        void filterCustomers(
                                                          String query,
                                                        ) {
                                                          setState(() {
                                                            if (query.isEmpty) {
                                                              filteredList =
                                                                  List.from(
                                                                    customersList,
                                                                  );
                                                            } else {
                                                              filteredList =
                                                                  customersList
                                                                      .where(
                                                                        (
                                                                          c,
                                                                        ) => ("${c.firstName} ${c.lastName}")
                                                                            .toLowerCase()
                                                                            .contains(
                                                                              query.toLowerCase(),
                                                                            ),
                                                                      )
                                                                      .toList();
                                                            }
                                                          });
                                                        }

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
                                                          content: SizedBox(
                                                            width:
                                                                double
                                                                    .maxFinite,
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                // 🔍 Search Bar
                                                                TextField(
                                                                  controller:
                                                                      searchController,
                                                                  decoration: InputDecoration(
                                                                    prefixIcon: Icon(
                                                                      Icons
                                                                          .search,
                                                                      color:
                                                                          AppColors
                                                                              .mainColor,
                                                                    ),
                                                                    hintText:
                                                                        "Search customer...",
                                                                    hintStyle: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .grey,
                                                                      fontSize:
                                                                          14.sp,
                                                                    ),
                                                                    enabledBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            10,
                                                                          ),
                                                                      borderSide: BorderSide(
                                                                        color:
                                                                            AppColors.gray,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            10,
                                                                          ),
                                                                      borderSide: BorderSide(
                                                                        color:
                                                                            AppColors.mainColor,
                                                                        width:
                                                                            1.2,
                                                                      ),
                                                                    ),
                                                                    contentPadding: const EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          15,
                                                                    ),
                                                                  ),
                                                                  onChanged:
                                                                      filterCustomers,
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),

                                                                // Customer List
                                                                Flexible(
                                                                  child:
                                                                      filteredList
                                                                              .isNotEmpty
                                                                          ? ListView.builder(
                                                                            shrinkWrap:
                                                                                true,
                                                                            itemCount:
                                                                                filteredList.length,
                                                                            itemBuilder: (
                                                                              context,
                                                                              index,
                                                                            ) {
                                                                              final customer =
                                                                                  filteredList[index];
                                                                              bool
                                                                              isSelected =
                                                                                  selectedCustomerId ==
                                                                                  customer.id;

                                                                              return InkWell(
                                                                                onTap: () {
                                                                                  setState(
                                                                                    () {
                                                                                      selectedCustomerId =
                                                                                          customer.id;
                                                                                      selectedCustomerName =
                                                                                          "${customer.firstName} ${customer.lastName}";
                                                                                      errorText =
                                                                                          null;
                                                                                    },
                                                                                  );
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
                                                                                    borderRadius: BorderRadius.circular(
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
                                                                                      const SizedBox(
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
                                                                            },
                                                                          )
                                                                          : Padding(
                                                                            padding: const EdgeInsets.symmetric(
                                                                              vertical:
                                                                                  20,
                                                                            ),
                                                                            child: Text(
                                                                              "No customers found.",
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
                                                                ),

                                                                if (errorText !=
                                                                    null) ...[
                                                                  const SizedBox(
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
                                                              title: "Confirm",
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
                                                                    Get.back();
                                                                  }
                                                                } else {
                                                                  setState(() {
                                                                    errorText =
                                                                        "Please select a customer!";
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

                                // ImageSlider(
                                //   imageUrls: bannersImagesList,
                                //   height: 18.h,
                                // ),
                                SizedBox(height: 2.h),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h),

                        Expanded(
                          child:
                              isIpad
                                  ? Container(
                                    height: Device.height,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(40),
                                        topLeft: Radius.circular(40),
                                      ),
                                      color: AppColors.bgColor,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: isIpad ? 0.5.h : 2.5.h,
                                        right: 4.w,
                                        left: 4.w,
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  Imgs.onlyLogo,
                                                  height: isIpad ? 06.w : 13.w,
                                                  width: isIpad ? 07.w : 15.w,
                                                  fit: BoxFit.cover,
                                                ),
                                                Text(
                                                  "Bellissemo App",
                                                  style: TextStyle(
                                                    fontSize:
                                                        isIpad ? 20.sp : 22.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.blackColor,
                                                    fontFamily:
                                                        FontFamily.regular,
                                                    letterSpacing: 1.1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 1.h),
                                            Wrap(
                                              spacing: 0.w,
                                              runSpacing: 3.h,
                                              alignment: WrapAlignment.center,
                                              children: [
                                                _buildMenuItem(
                                                  Imgs.firstImage,
                                                  "Catalogs",
                                                ),
                                                _buildMenuItem(
                                                  Imgs.customerImage,
                                                  "Customers",
                                                ),
                                                _buildMenuItem(
                                                  Imgs.fourthImage,
                                                  "Cart",
                                                ),
                                                _buildMenuItem(
                                                  Imgs.secondImage,
                                                  "Orders",
                                                ),
                                                _buildMenuItem(
                                                  Imgs.reportImage,
                                                  "Report",
                                                ),
                                                _buildMenuItem(
                                                  Imgs.fifthImage,
                                                  "Account",
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 3.h),
                                            CustomButton(
                                              title: 'Explore More..',
                                              radius: isIpad ? 1.w : 3.w,
                                              route: () {
                                                Get.to(
                                                  () => CategoriesScreen(),
                                                );
                                              },
                                              iconData:
                                                  Icons
                                                      .production_quantity_limits_sharp,
                                              color: AppColors.mainColor,
                                              fontcolor: AppColors.whiteColor,
                                              height: 5.h,
                                              fontsize: 18.sp,
                                            ).paddingOnly(bottom: 1.h),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  : Container(
                                    height: Device.height,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(40),
                                        topLeft: Radius.circular(40),
                                      ),
                                      color: AppColors.bgColor,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: isIpad ? 0.5.h : 2.5.h,
                                        right: 4.w,
                                        left: 4.w,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                Imgs.onlyLogo,
                                                height: isIpad ? 06.w : 13.w,
                                                width: isIpad ? 08.w : 15.w,
                                                fit: BoxFit.cover,
                                              ),
                                              Text(
                                                "Bellissemo App",
                                                style: TextStyle(
                                                  fontSize:
                                                      isIpad ? 20.sp : 22.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.blackColor,
                                                  fontFamily:
                                                      FontFamily.regular,
                                                  letterSpacing: 1.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 3.h),
                                          Wrap(
                                            spacing: 0.w,
                                            runSpacing: 3.h,
                                            alignment: WrapAlignment.center,
                                            children: [
                                              _buildMenuItem(
                                                Imgs.firstImage,
                                                "Catalogs",
                                              ),
                                              _buildMenuItem(
                                                Imgs.customerImage,
                                                "Customers",
                                              ),
                                              _buildMenuItem(
                                                Imgs.fourthImage,
                                                "Cart",
                                              ),
                                              _buildMenuItem(
                                                Imgs.secondImage,
                                                "Orders",
                                              ),
                                              _buildMenuItem(
                                                Imgs.reportImage,
                                                "Report",
                                              ),
                                              _buildMenuItem(
                                                Imgs.fifthImage,
                                                "Account",
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5.h),
                                          CustomButton(
                                            title: 'Explore More..',
                                            radius: isIpad ? 1.w : 3.w,
                                            route: () {
                                              Get.to(() => CategoriesScreen());
                                            },
                                            iconData:
                                                Icons
                                                    .production_quantity_limits_sharp,
                                            color: AppColors.mainColor,
                                            fontcolor: AppColors.whiteColor,
                                            height: 5.h,
                                            fontsize: 18.sp,
                                          ).paddingOnly(bottom: 1.h),
                                        ],
                                      ),
                                    ),
                                  ),
                        ),
                      ],
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

  Widget _buildMenuItem(String svgPath, String title) {
    double totalSpacing = 2 * 4.w;
    double itemWidth = (100.w - totalSpacing) / 3;

    return SizedBox(
      width: itemWidth,
      child: GestureDetector(
        onTap: () {
          switch (title) {
            case "Orders":
              Get.offAll(() => OrderHistoryScreen());
              break;
            case "Catalogs":
              Get.offAll(() => CategoriesScreen());
              break;
            case "Customers":
              Get.to(() => CustomersScreen());
              break;
            case "Cart":
              Get.offAll(() => CartScreen());
              break;
            case "Report":
              Get.to(() => ReportScreen());
              break;
            case "Account":
              Get.offAll(() => ProfileScreen());
              break;
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: isIpad ? EdgeInsets.all(12.sp) : EdgeInsets.all(15.sp),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius:
                    isIpad
                        ? BorderRadius.circular(15)
                        : BorderRadius.circular(20),
                color: Colors.white,
                border: Border.all(color: AppColors.mainColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainColor.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                svgPath,
                height: isIpad ? 24.sp : 23.sp,
                width: isIpad ? 24.sp : 23.sp,
                color: AppColors.mainColor,
                // 🔹 keep tint (remove if you want original svg color)
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: FontFamily.semiBold,
                color: AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
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
  // void _showSelectCustomerDialog() {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       int? selectedCustomerId;
  //       String? selectedCustomerName;
  //       String? errorText;
  //
  //       return FutureBuilder(
  //         future: SharedPreferences.getInstance(),
  //         builder: (context, snapshot) {
  //           if (!snapshot.hasData) {
  //             return Center(child: CircularProgressIndicator());
  //           }
  //
  //           final prefs = snapshot.data!;
  //           selectedCustomerId = prefs.getInt("customerId");
  //           selectedCustomerName = prefs.getString("customerName");
  //
  //           return StatefulBuilder(
  //             builder: (context, setState) {
  //               return WillPopScope(
  //                 onWillPop: () async {
  //                   setState(() {
  //                     errorText =
  //                         " Please select a customer before proceeding.";
  //                   });
  //                   return false;
  //                 }, // Prevent back button
  //                 child: AlertDialog(
  //                   backgroundColor: AppColors.whiteColor,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   title: Text(
  //                     "Select Customer",
  //                     style: TextStyle(
  //                       fontSize: 18.sp,
  //                       fontFamily: FontFamily.bold,
  //                       color: AppColors.blackColor,
  //                     ),
  //                   ),
  //                   content: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       // List of customers
  //                       ...customersList.map((customer) {
  //                         bool isSelected = selectedCustomerId == customer.id;
  //                         return InkWell(
  //                           onTap: () {
  //                             setState(() {
  //                               selectedCustomerId = customer.id;
  //                               selectedCustomerName =
  //                                   "${customer.firstName} ${customer.lastName}";
  //                               errorText = null; // clear error
  //                             });
  //                           },
  //                           child: Container(
  //                             padding: EdgeInsets.symmetric(
  //                               vertical: 12,
  //                               horizontal: 10,
  //                             ),
  //                             margin: EdgeInsets.symmetric(vertical: 5),
  //                             decoration: BoxDecoration(
  //                               color:
  //                                   isSelected
  //                                       ? AppColors.mainColor.withAlpha(25)
  //                                       : AppColors.whiteColor,
  //                               border: Border.all(
  //                                 color:
  //                                     isSelected
  //                                         ? AppColors.mainColor
  //                                         : AppColors.gray,
  //                                 width: 1,
  //                               ),
  //                               borderRadius: BorderRadius.circular(10),
  //                             ),
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   isSelected
  //                                       ? Icons.radio_button_checked
  //                                       : Icons.radio_button_off,
  //                                   color:
  //                                       isSelected
  //                                           ? AppColors.mainColor
  //                                           : AppColors.gray,
  //                                 ),
  //                                 SizedBox(width: 10),
  //                                 Text(
  //                                   "${customer.firstName} ${customer.lastName}",
  //                                   style: TextStyle(
  //                                     fontSize: 16.sp,
  //                                     fontFamily: FontFamily.regular,
  //                                     color: AppColors.blackColor,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         );
  //                       }),
  //                       if (errorText != null) ...[
  //                         SizedBox(height: 0.5.h),
  //                         Text(
  //                           errorText!,
  //                           style: TextStyle(
  //                             color: Colors.red,
  //                             fontSize: 14.sp,
  //                           ),
  //                         ),
  //                       ],
  //                     ],
  //                   ),
  //                   actions: [
  //                     // Disable Cancel button or just show error
  //                     CustomButton(
  //                       title: "Cancel",
  //                       route: () {
  //                         setState(() {
  //                           errorText =
  //                               " Please select a customer before proceeding.";
  //                         });
  //                       },
  //                       color: AppColors.containerColor,
  //                       fontcolor: AppColors.blackColor,
  //                       height: 5.h,
  //                       width: 27.w,
  //                       fontsize: 15.sp,
  //                       radius: 12.0,
  //                     ),
  //                     CustomButton(
  //                       title: "Confirm",
  //                       route: () async {
  //                         if (selectedCustomerId != null &&
  //                             selectedCustomerName != null) {
  //                           Get.back();
  //                           final prevCustomerId = prefs.getInt("customerId");
  //
  //                           if (prevCustomerId != selectedCustomerId) {
  //                             // Customer changed -> save new values and clear cart
  //                             await prefs.setInt(
  //                               "customerId",
  //                               selectedCustomerId!,
  //                             );
  //                             await prefs.setString(
  //                               "customerName",
  //                               selectedCustomerName!,
  //                             );
  //                             _clearCart();
  //                           }
  //
  //                           // Close dialog only after saving
  //                         } else {
  //                           setState(() {
  //                             errorText =
  //                                 " Please select a customer before proceeding.";
  //                           });
  //                         }
  //                       },
  //                       color: AppColors.mainColor,
  //                       fontcolor: AppColors.whiteColor,
  //                       height: 5.h,
  //                       width: 27.w,
  //                       fontsize: 15.sp,
  //                       radius: 12.0,
  //                       iconData: Icons.check,
  //                       iconsize: 17.sp,
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  /// Customer Dialogue
  void _showSelectCustomerDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        int? selectedCustomerId;
        String? selectedCustomerName;
        String? errorText;
        TextEditingController searchController = TextEditingController();

        return FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final prefs = snapshot.data!;
            selectedCustomerId = prefs.getInt("customerId");
            selectedCustomerName = prefs.getString("customerName");

            // Make a copy for filtering
            List<FetchCustomersModal> filteredList = List.from(customersList);

            return StatefulBuilder(
              builder: (context, setState) {
                void filterCustomers(String query) {
                  setState(() {
                    if (query.isEmpty) {
                      filteredList = List.from(customersList);
                    } else {
                      filteredList =
                          customersList
                              .where(
                                (c) => ("${c.firstName} ${c.lastName}")
                                    .toLowerCase()
                                    .contains(query.toLowerCase()),
                              )
                              .toList();
                    }
                  });
                }

                return WillPopScope(
                  onWillPop: () async {
                    setState(() {
                      errorText = "Please select a customer before proceeding.";
                    });
                    return false;
                  },
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
                    content: SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🔍 Search Bar
                          TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.mainColor,
                              ),
                              hintText: "Search customer...",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppColors.gray,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppColors.mainColor,
                                  width: 1.2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                            ),
                            onChanged: filterCustomers,
                          ),
                          const SizedBox(height: 10),

                          // Customer List
                          Flexible(
                            child:
                                filteredList.isNotEmpty
                                    ? ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: filteredList.length,
                                      itemBuilder: (context, index) {
                                        final customer = filteredList[index];
                                        bool isSelected =
                                            selectedCustomerId == customer.id;

                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedCustomerId = customer.id;
                                              selectedCustomerName =
                                                  "${customer.firstName} ${customer.lastName}";
                                              errorText = null;
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
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? AppColors.mainColor
                                                          .withAlpha(25)
                                                      : AppColors.whiteColor,
                                              border: Border.all(
                                                color:
                                                    isSelected
                                                        ? AppColors.mainColor
                                                        : AppColors.gray,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isSelected
                                                      ? Icons
                                                          .radio_button_checked
                                                      : Icons.radio_button_off,
                                                  color:
                                                      isSelected
                                                          ? AppColors.mainColor
                                                          : AppColors.gray,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  "${customer.firstName} ${customer.lastName}",
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontFamily:
                                                        FontFamily.regular,
                                                    color: AppColors.blackColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    : Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      child: Text(
                                        "No customers found.",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                    ),
                          ),

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
                    ),
                    actions: [
                      // Disable Cancel button or just show error
                      CustomButton(
                        title: "Cancel",
                        route: () {
                          setState(() {
                            errorText =
                                "Please select a customer before proceeding.";
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
                            Get.back();
                            final prevCustomerId = prefs.getInt("customerId");

                            if (prevCustomerId != selectedCustomerId) {
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
                          } else {
                            setState(() {
                              errorText =
                                  "Please select a customer before proceeding.";
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

  Future<String?> getSavedLoginToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_token');
  }

  FreshTokenModal? freshTokenModal;

  getTokenApi() async {
    print("a call tha che");
    String? token = await getSavedLoginToken();

    print("my token shu ave che :: $token");
    if (token == null || token.isEmpty) {
      throw Exception('Token not found');
    }
    final Map<String, String> data = {"refresh_token": token ?? ""};

    print("ram na data${data}");
    final hasInternet = await checkInternet();
    print("Internet status: $hasInternet");
    checkInternet().then((internet) async {
      if (internet) {
        HomeProvider()
            .refreshToken(data)
            .then((response) async {
              freshTokenModal = FreshTokenModal.fromJson(
                json.decode(response.body),
              );
              if (response.statusCode == 200) {
                log("✅ All data loaded in token ave che ms");
                await saveLoginToken(freshTokenModal?.refreshToken ?? "");
              } else if (response.statusCode == 422) {
              } else {}
            })
            .catchError((error, stackTrace) {
              print("error=====>>>>>>${stackTrace}");
              print("Catch Error ===>>> ${error.toString()}");
            });
      } else {
        // buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Future<void> saveLoginToken(String? token) async {
    if (token == null || token.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_token', token);
    log("✅ All data loaded in token ave che ms  ${token}");
  }
}
