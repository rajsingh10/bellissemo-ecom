import 'dart:convert';

import 'package:bellissemo_ecom/apiCalling/apiConfigs.dart';
import 'package:bellissemo_ecom/apiCalling/checkInternetModule.dart';
import 'package:bellissemo_ecom/services/hiveServices.dart';
import 'package:bellissemo_ecom/ui/customers/modal/CustomerDetailModal.dart';
import 'package:bellissemo_ecom/ui/customers/provider/customerProvider.dart';
import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/customMenuDrawer.dart';
import 'package:bellissemo_ecom/utils/emptyWidget.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:bellissemo_ecom/utils/snackBars.dart';
import 'package:bellissemo_ecom/utils/titlebarWidget.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../apiCalling/loader.dart' show Loader;

class CustomerDetailScreen extends StatefulWidget {
  String? id;

  CustomerDetailScreen({super.key, required this.id});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

bool isLoading = false;
bool hasData = false;
bool isIpad = 100.w >= 800;

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyCustomerview =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
    });
    _fetchCustomerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      drawer: CustomDrawer(),
      key: _scaffoldKeyCustomerview,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TitleBar(
              title: 'Customer Detail',
              isDrawerEnabled: true,
              isBackEnabled: true,
              drawerCallback: () {
                _scaffoldKeyCustomerview.currentState?.openDrawer();
              },
            ),
            if (isLoading)
              Loader()
            else if (hasData) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: isIpad ? 60 : 35,
                      backgroundColor: AppColors.mainColor,
                      child: Icon(
                        Icons.person,
                        size: isIpad ? 80 : 40,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer?.firstName ?? "N/A",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: FontFamily.semiBold,
                            color: AppColors.blackColor,
                          ),
                        ),
                        Text(
                          customer?.email ?? "N/A",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: FontFamily.semiBold,
                            color: AppColors.blackColor,
                          ),
                        ),
                        Text(
                          customer?.allMetaData?.mobileNumber ?? "N/A",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: FontFamily.semiBold,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.fiber_smart_record_sharp,
                          color: AppColors.mainColor,
                          size: 18.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Company Name',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: FontFamily.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      customer?.allMetaData?.companyName ?? "N/A",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontFamily: FontFamily.semiBold,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Divider(height: 2.h, color: Colors.grey[300]),
                    Row(
                      children: [
                        Icon(
                          Icons.fiber_smart_record_sharp,
                          color: AppColors.mainColor,
                          size: 18.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Vat Number',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: FontFamily.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      customer?.allMetaData?.vatNumber ?? "N/A",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontFamily: FontFamily.semiBold,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Divider(height: 2.h, color: Colors.grey[300]),
                    Row(
                      children: [
                        Icon(
                          Icons.fiber_smart_record_sharp,
                          color: AppColors.mainColor,
                          size: 18.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Company Registration Number',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: FontFamily.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      customer?.allMetaData?.companyRegistrationNumber ?? "N/A",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontFamily: FontFamily.semiBold,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Divider(height: 2.h, color: Colors.grey[300]),
                    Row(
                      children: [
                        Icon(
                          Icons.fiber_smart_record_sharp,
                          color: AppColors.mainColor,
                          size: 18.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Address',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: FontFamily.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      customer?.shipping?.address1 == ""
                          ? "N/A"
                          : customer?.shipping?.address1 ?? "N/A",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontFamily: FontFamily.semiBold,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Divider(height: 2.h, color: Colors.grey[300]),
                    Row(
                      children: [
                        Icon(
                          Icons.fiber_smart_record_sharp,
                          color: AppColors.mainColor,
                          size: 18.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Contact Name',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: FontFamily.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      customer?.allMetaData?.contactName ?? "N/A",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontFamily: FontFamily.semiBold,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Divider(height: 2.h, color: Colors.grey[300]),
                    Row(
                      children: [
                        Icon(
                          Icons.fiber_smart_record_sharp,
                          color: AppColors.mainColor,
                          size: 18.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'phone Number',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: FontFamily.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      customer?.allMetaData?.billingPhone == ""
                          ? "N/A"
                          : customer?.allMetaData?.billingPhone ?? "N/A",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontFamily: FontFamily.semiBold,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Divider(height: 2.h, color: Colors.grey[300]),
                    Row(
                      children: [
                        Icon(
                          Icons.fiber_smart_record_sharp,
                          color: AppColors.mainColor,
                          size: 18.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Mobile Number',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: FontFamily.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      customer?.allMetaData?.mobileNumber ?? "N/A",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontFamily: FontFamily.semiBold,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Padding(
                padding: EdgeInsets.symmetric(vertical: isIpad ? 2.h : 35.h),
                child: emptyWidget(
                  icon: Icons.person,
                  text: 'Customer Details',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchCustomerDetails() async {
    setState(() {
      isLoading = true;
      hasData = false;
    });

    var box = HiveService().getCustomerDetailsBox();

    if (!await checkInternet()) {
      final cachedData = box.get('customerDetails${widget.id.toString()}');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        customer = Customerdetailmodal.fromJson(data);
        hasData = true;
      } else {
        print("❌ No internet and no cached data found");
        showCustomErrorSnackbar(
          context,title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
        hasData = false;
      }

      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await CustomerProvider().Customerdetailapi(
        widget.id.toString(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        customer = Customerdetailmodal.fromJson(data);
        await box.put('customerDetails${widget.id ?? ""}', response.body);
        hasData = true;
      } else {
        print(
          "❌ Server Error → statusCode: ${response.statusCode}, body: ${response.body}",
        );

        final cachedData = box.get('customerDetails${widget.id ?? ""}');
        if (cachedData != null) {
          final data = json.decode(cachedData);
          customer = Customerdetailmodal.fromJson(data);
          hasData = true;
        } else {
          hasData = false;
        }

        showCustomErrorSnackbar(
          context,title: 'Server Error',
          message: 'Something went wrong. Please try again later.',
        );
      }
    } catch (e, stack) {
      print("❌ Exception in _fetchCustomerDetails: $e");
      print("📌 Stacktrace:\n$stack");

      final cachedData = box.get('customerDetails${widget.id.toString()}');
      if (cachedData != null) {
        final data = json.decode(cachedData);
        customer = Customerdetailmodal.fromJson(data);
        hasData = true;
      } else {
        hasData = false;
      }

      showCustomErrorSnackbar(
        context,title: 'Network Error',
        message: 'Unable to connect. Please check your internet and try again.',
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
