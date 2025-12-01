import 'dart:convert';
import 'dart:developer';

import 'package:bellissemo_ecom/apiCalling/Loader.dart';
import 'package:bellissemo_ecom/ui/customers/view/customerDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../apiCalling/buildErrorDialog.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../../utils/colors.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/customMenuDrawer.dart';
import '../../../utils/emptyWidget.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/searchFields.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/titlebarWidget.dart';
import '../modal/DeleteCstomerModal.dart';
import '../modal/fetchCustomersModal.dart';
import '../provider/customerProvider.dart';
import 'addCustomerScreen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<FetchCustomersModal> customersList = [];
  List<FetchCustomersModal> filteredCustomers = [];
  bool isLoading = true;

  String selectedSort = "A-Z";
  final List<String> sortOptions = ["A-Z", "Z-A"];

  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();

  bool isIpad = 100.w >= 800;

  @override
  void initState() {
    super.initState();
    loadInitialData();

    searchController.addListener(() {
      _filterCustomers(searchController.text);
    });
  }

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);

    _loadCachedData();

    try {
      await _fetchCustomers();
    } catch (e) {
      log("Error loading customers: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _loadCachedData() {
    var customerBox = HiveService().getCustomerBox();
    final cachedCustomers = customerBox.get('customers');
    if (cachedCustomers != null) {
      final List data = json.decode(cachedCustomers);
      customersList =
          data
              .map<FetchCustomersModal>((e) => FetchCustomersModal.fromJson(e))
              .toList();
      filteredCustomers = List.from(customersList);
    }
  }

  Future<void> _fetchCustomers() async {
    var box = HiveService().getCustomerBox();

    if (!await checkInternet()) {
      // Load cached if offline
      _loadCachedData();
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
        _loadCachedData();
        showCustomErrorSnackbar(
          title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (_) {
      _loadCachedData();
      showCustomErrorSnackbar(
        title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    }

    _filterCustomers();
  }

  void _filterCustomers([String query = ""]) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = List.from(customersList);
      } else {
        filteredCustomers =
            customersList
                .where(
                  (c) =>
                      c.firstName!.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      c.email!.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }

      // Sorting
      if (selectedSort == "A-Z") {
        filteredCustomers.sort((a, b) => a.firstName!.compareTo(b.firstName!));
      } else if (selectedSort == "Z-A") {
        filteredCustomers.sort((a, b) => b.firstName!.compareTo(a.firstName!));
      }
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKeyCustomer =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      drawer: CustomDrawer(),
      key: _scaffoldKeyCustomer,
      body:
          isLoading
              ? Loader()
              : Column(
                children: [
                  TitleBar(
                    title: 'Customers',
                    isDrawerEnabled: true,
                    isSearchEnabled: true,
                    drawerCallback: () {
                      _scaffoldKeyCustomer.currentState?.openDrawer();
                    },
                    onSearch: () {
                      setState(() {
                        isSearchEnabled = !isSearchEnabled;
                      });
                    },
                  ),
                  if (isSearchEnabled)
                    SearchField(controller: searchController),
                  SizedBox(height: 1.h),
                  Expanded(
                    child:
                        filteredCustomers.isEmpty
                            ? Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.to(CreateCustomerPage());
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                    ),
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
                                    child: Row(
                                      children: [
                                        Text(
                                          "Add Customer",
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontFamily: FontFamily.semiBold,
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                        SizedBox(width: 1.w),
                                        DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedSort,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            dropdownColor: Colors.white,
                                            icon: Icon(
                                              Icons.person,
                                              color: AppColors.mainColor,
                                            ),
                                            items:
                                                sortOptions
                                                    .map(
                                                      (e) => DropdownMenuItem(
                                                        value: e,
                                                        child: Text(
                                                          '',
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
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged: null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isIpad ? 2.h : 15.h,
                                  ),
                                  child: emptyWidget(
                                    icon: Icons.people,
                                    text: 'Customers',
                                  ),
                                ),
                              ],
                            )
                            : SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Sort Dropdown
                                      InkWell(
                                        onTap: () {
                                          Get.to(CreateCustomerPage());
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
                                          child: Row(
                                            children: [
                                              Text(
                                                "Add Customer",
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontFamily:
                                                      FontFamily.semiBold,
                                                  color: AppColors.blackColor,
                                                ),
                                              ),
                                              SizedBox(width: 1.w),
                                              DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: selectedSort,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  dropdownColor: Colors.white,
                                                  icon: Icon(
                                                    Icons.person,
                                                    color: AppColors.mainColor,
                                                  ),
                                                  items:
                                                      sortOptions
                                                          .map(
                                                            (
                                                              e,
                                                            ) => DropdownMenuItem(
                                                              value: e,
                                                              child: Text(
                                                                '',
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      15.sp,
                                                                  fontFamily:
                                                                      FontFamily
                                                                          .semiBold,
                                                                  color:
                                                                      AppColors
                                                                          .mainColor,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                  onChanged: null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
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
                                                    sortOptions
                                                        .map(
                                                          (
                                                            e,
                                                          ) => DropdownMenuItem(
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
                                                          ),
                                                        )
                                                        .toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    setState(
                                                      () =>
                                                          selectedSort = value,
                                                    );
                                                    _filterCustomers();
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
                                  Column(
                                    children: [
                                      for (var customer in filteredCustomers)
                                        _buildGridItem(customer),
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
        child: CustomBar(selected: 8),
      ),
    );
  }

  Widget _buildGridItem(FetchCustomersModal customer) {
    return InkWell(
      onTap: () {
        Get.to(CustomerDetailScreen(id: (customer.id).toString()));
      },
      child: Card(
        color: AppColors.cardBgColor2,
        elevation: 3,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child:   Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "${customer.firstName} ${customer.lastName}",
                    style: TextStyle(
                      fontFamily: FontFamily.bold,
                      fontSize: 16.sp,
                      color: AppColors.blackColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  InkWell(
                    onTap: (){
                      deleteDailyData(customer.id.toString());
                    },
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: AppColors.mainColor

                        ),
                          child: Icon(Icons.delete,color: Colors.white,))),
                ],
              ),
              SizedBox(height: 0.5.h),
              // Text(
              //   customer.username ?? '',
              //   style: TextStyle(
              //     fontSize: 14.sp,
              //     fontFamily: FontFamily.regular,
              //     color: AppColors.gray,
              //   ),
              // ),
              // SizedBox(height: 0.5.h),
              Text(
                customer.email ?? '',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: FontFamily.regular,
                  color: AppColors.gray,
                ),
              ),
            ],
          ),
        ).paddingSymmetric(horizontal: 1.w, vertical: 0.5.h),
      ),
    );
  }
  DeleteCstomerModal? deleteCstomerModal;
  bool loader =false;
  deleteDailyData(String id) {
    checkInternet().then((internet) async {
      setState(() {
        loader = true;
      });

      if (!internet) {
        setState(() => loader = false);
        buildErrorDialog(context, 'Error', "Internet Required");
        return;
      }

      try {
        final response = await CustomerProvider().deleteDailyData(id);

        if (response.statusCode == 200) {
          // ✅ Successfully deleted → refresh list
          loadInitialData();

          Get.snackbar(
            "Success",
            "Customer Delete Success",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        } else {
          setState(() => loader = false);
          buildErrorDialog(context, 'Error', "Failed to delete data");
        }
      } catch (error) {
        setState(() => loader = false);
        buildErrorDialog(context, 'Error', error.toString());
      }
    });
  }
}
