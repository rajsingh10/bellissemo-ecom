import 'package:bellissemo_ecom/utils/snackBars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../apiCalling/Loader.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../utils/colors.dart';
import '../../../utils/customMenuDrawer.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/textFields.dart';
import '../../../utils/titlebarWidget.dart';
import '../../cart/service/cartServices.dart';
import 'customersScreen.dart';

class CreateCustomerPage extends StatefulWidget {
  const CreateCustomerPage({super.key});

  @override
  State<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends State<CreateCustomerPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companynaame = TextEditingController();
  final TextEditingController crn = TextEditingController();
  final TextEditingController vatno = TextEditingController();
  final TextEditingController Address = TextEditingController();
  final TextEditingController cname = TextEditingController();
  final TextEditingController phoneno = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeyaddCustomer =
      GlobalKey<ScaffoldState>();
  bool isAdding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      drawer: CustomDrawer(),
      key: _scaffoldKeyaddCustomer,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TitleBar(
                    title: 'Add Customers',
                    isDrawerEnabled: true,
                    isSearchEnabled: false,
                    isBackEnabled: true,
                    drawerCallback: () {
                      _scaffoldKeyaddCustomer.currentState?.openDrawer();
                    },
                    // onSearch: () {
                    //   setState(() {
                    //     isSearchEnabled = !isSearchEnabled;
                    //   });
                    // },
                  ),

                  AppTextField(
                    controller: nameController,
                    hintText: "First Name",
                    text: "First Name",
                    isTextavailable: true,
                    textInputType: TextInputType.name,
                    prefix: Icon(Icons.person_outline, color: AppColors.gray),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter first name";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: lastNameController,
                    hintText: "Last Name",
                    text: "Last Name",
                    isTextavailable: true,
                    textInputType: TextInputType.name,
                    prefix: Icon(Icons.person_outline, color: AppColors.gray),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter last name";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: emailController,
                    hintText: "Email Address",
                    text: "Email Address",
                    isTextavailable: true,
                    textInputType: TextInputType.emailAddress,
                    prefix: Icon(Icons.email_outlined, color: AppColors.gray),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email address";
                      }

                      // If contains '@', treat as email
                      if (value.contains('@')) {
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return "Please enter a valid email address";
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: companynaame,
                    hintText: "Company name",
                    text: "Company name",
                    isTextavailable: true,
                    textInputType: TextInputType.emailAddress,
                    prefix: Icon(
                      Icons.drive_file_rename_outline,
                      color: AppColors.gray,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: crn,
                    hintText: "Company registration number",
                    text: "Company registration number",
                    isTextavailable: true,
                    textInputType: TextInputType.name,
                    prefix: Icon(Icons.commit_rounded, color: AppColors.gray),
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: vatno,
                    hintText: "Vat number",
                    text: "Vat number",
                    isTextavailable: true,
                    textInputType: TextInputType.name,
                    prefix: Icon(
                      Icons.vertical_align_top,
                      color: AppColors.gray,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: Address,
                    hintText: "Address ",
                    text: "Address ",
                    isTextavailable: true,
                    textInputType: TextInputType.name,
                    prefix: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.gray,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: cname,
                    hintText: "Contact Name",
                    text: "Contact Name",
                    isTextavailable: true,
                    textInputType: TextInputType.name,
                    prefix: Icon(Icons.person, color: AppColors.gray),
                  ),
                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: phoneno,
                    hintText: "phone Number",
                    text: "Phone Number",
                    isTextavailable: true,
                    textInputType: TextInputType.number,
                    prefix: Icon(Icons.call, color: AppColors.gray),
                  ),

                  SizedBox(height: 1.h),
                  AppTextField(
                    controller: mobile,
                    hintText: "Mobile Number",
                    text: "Mobile Number",
                    isTextavailable: true,
                    textInputType: TextInputType.number,
                    prefix: Icon(Icons.call, color: AppColors.gray),
                  ),
                  SizedBox(height: 4.h),
                  InkWell(
                    // onTap: () async {
                    //   if (_formKey.currentState!.validate()) {
                    //     setState(() {
                    //       isAdding = true;
                    //     });
                    //     final cartService = CartService();
                    //
                    //     final response = await cartService.addCustomer(
                    //       companynaame: companynaame.text.trim(),
                    //       companyregistrationnumber: crn.text.trim(),
                    //       contactname: cname.text.trim(),
                    //       mobilenumber: mobile.text.trim(),
                    //       vatnumber: vatno.text.trim(),
                    //       email: emailController.text.trim(),
                    //       firstName: nameController.text.trim(),
                    //       lastName: lastNameController.text.trim(),
                    //       password: "12345678",
                    //       address: Address.text.trim(),
                    //       username:
                    //           "${nameController.text.trim()}${lastNameController.text.trim()}",
                    //     );
                    //
                    //     if (response != null &&
                    //         (response.statusCode == 200 ||
                    //             response.statusCode == 201)) {
                    //       setState(() {
                    //         isAdding = false;
                    //       });
                    //       Get.to(() => CustomersScreen());
                    //     } else {
                    //       setState(() {
                    //         isAdding = false;
                    //       });
                    //       Get.snackbar("Error", "Failed to add customer");
                    //     }
                    //   }
                    // },
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isAdding = true;
                        });

                        final cartService = CartService();
                        final response = await cartService.addCustomer(
                          companynaame: companynaame.text.trim(),
                          companyregistrationnumber: crn.text.trim(),
                          contactname: cname.text.trim(),
                          mobilenumber: mobile.text.trim(),
                          vatnumber: vatno.text.trim(),
                          email: emailController.text.trim(),
                          firstName: nameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          password: "12345678",
                          address: Address.text.trim(),
                          username:
                              "${nameController.text.trim()}${lastNameController.text.trim()}",
                        );

                        setState(() {
                          isAdding = false;
                        });

                        if (response == null) {
                          // 🔹 This means offline or request failed (but stored locally)
                          bool hasInternet = await checkInternet();
                          if (!hasInternet) {
                            showCustomSuccessSnackbar(
                              title: "Offline Mode",
                              message:
                                  "Customer saved locally. Will sync automatically when online.",
                            );
                            Get.to(() => CustomersScreen());
                          } else {
                            showCustomErrorSnackbar(
                              title: 'There was an error while adding customer',
                              message: 'Please try again',
                            );
                          }
                          return;
                        }

                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          Get.snackbar(
                            "Success",
                            "Customer added successfully!",
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                          Get.to(() => CustomersScreen());
                        } else {
                          Get.snackbar("Error", "Failed to add customer");
                        }
                      }
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
                          "Add Customer",
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 18.sp,
                            fontFamily: FontFamily.semiBold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ).paddingSymmetric(vertical: 1.h, horizontal: 2.w),
            ),
          ),
          if (isAdding)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: Loader(),
            ),
        ],
      ),
    );
  }
}
