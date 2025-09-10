import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/colors.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/textFields.dart';
import '../../../utils/titlebarWidget.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController genderController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController stateController = TextEditingController();
    final TextEditingController countryController = TextEditingController();
    final TextEditingController dobController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.containerColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TitleBar(
              title: 'Edit Profile',
              isDrawerEnabled: false,
              isSearchEnabled: false,
              isBackEnabled: true,
            ),
            SizedBox(height: 2.h),

            Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),

                      //   image: const DecorationImage(
                      //     fit: BoxFit.cover,
                      //     image: NetworkImage(
                      //       "https://images.unsplash.com/photo-1633332755192-727a05c4013d",
                      //     ),
                      // ),
                    ),
                    child: CustomNetworkImage(
                      imageUrl:
                          'https://images.unsplash.com/photo-1633332755192-727a05c4013d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlcnxlbnwwfHwwfHx8MA%3D%3D',
                      height: 80,
                      width: 80,
                      isCircle: true,
                      isProfile: true,
                      isFit: true,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: MediaQuery.of(context).size.width / 2 - 60,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.mainColor,
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),

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
                    controller: nameController,
                    hintText: "Enter full name",
                    text: "Full Name",
                    isTextavailable: true,
                    textInputType: TextInputType.name,
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: emailController,
                    hintText: "Enter email",
                    text: "Email",
                    isTextavailable: true,
                    textInputType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: phoneController,
                    hintText: "Enter phone number",
                    text: "Phone",
                    isTextavailable: true,
                    textInputType: TextInputType.phone,
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: genderController,
                    hintText: "Select gender",
                    text: "Gender",
                    isTextavailable: true,
                    readOnly: true,
                    suffix: const Icon(Icons.arrow_drop_down),
                    textInputType: TextInputType.text,
                    ontap: () {
                      // TODO: open gender selection
                    },
                  ),
                  SizedBox(height: 1.h),
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
                  AppTextField(
                    controller: dobController,
                    hintText: "Select date of birth",
                    text: "Date of Birth",
                    isTextavailable: true,
                    readOnly: true,
                    suffix: const Icon(Icons.date_range),
                    textInputType: TextInputType.text,
                    ontap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(1990, 1, 1),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        dobController.text =
                            "${pickedDate.day} ${_monthName(pickedDate.month)} ${pickedDate.year}";
                      }
                    },
                  ),
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
                    "Save Changes",
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
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }
}
