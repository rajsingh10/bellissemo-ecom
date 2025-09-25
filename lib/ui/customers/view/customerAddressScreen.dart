import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/colors.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/textFields.dart';
import '../../../utils/titlebarWidget.dart';

class CustomerAddressScreen extends StatefulWidget {
  const CustomerAddressScreen({super.key});

  @override
  State<CustomerAddressScreen> createState() => _CustomerAddressScreenState();
}

class _CustomerAddressScreenState extends State<CustomerAddressScreen> {

  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController postcode = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TitleBar(
              title: 'Address',
              isDrawerEnabled: false,
              isSearchEnabled: false,
              isBackEnabled: true,
            ),
            SizedBox(height: 2.h),



            Container(
              padding: EdgeInsets.all(4.w),
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
                children: [

                  AppTextField(
                    controller: addressController,
                    hintText: "Enter address",
                    text: "Address",
                    isTextavailable: true,
                    textInputType: TextInputType.streetAddress,
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: cityController,
                    hintText: "Enter city",
                    text: "City",
                    isTextavailable: true,
                    textInputType: TextInputType.text,
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: postcode,
                    hintText: "Enter Post Code",
                    text: "Postcode",
                    isTextavailable: true,
                    textInputType: TextInputType.number,
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: stateController,
                    hintText: "Enter state",
                    text: "State",
                    isTextavailable: true,
                    textInputType: TextInputType.text,
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: countryController,
                    hintText: "Enter country",
                    text: "Country",
                    isTextavailable: true,
                    textInputType: TextInputType.text,
                  ),
                  SizedBox(height: 1.h),

                ],
              ),
            ),

            SizedBox(height: 3.h),

            /// Save Button
            InkWell(
              onTap: () {
                Get.back(); // Save logic here
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Save Address",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 18.sp,
                      fontFamily: FontFamily.semiBold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
      ) ,
    );
  }
}
