import 'package:bellissemo_ecom/ui/cart/View/cartScreen.dart';
import 'package:bellissemo_ecom/ui/cart/View/chekOutScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../apiCalling/Loader.dart';
import '../../../utils/colors.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/textFields.dart';
import '../../../utils/titlebarWidget.dart';
import '../services/addressService.dart';

class CustomerAddressScreen extends StatefulWidget {
  String? fName,
      lName,
      email,
      address1,
      address2,
      city,
      postcode,
      state,
      country,
      id;

  String? crdit;

  CustomerAddressScreen({
    super.key,
    required this.fName,
    required this.lName,
    required this.email,
    required this.address1,
    required this.address2,
    required this.crdit,
    required this.city,
    required this.postcode,
    required this.state,
    required this.country,
    required this.id,
  });

  @override
  State<CustomerAddressScreen> createState() => _CustomerAddressScreenState();
}

class _CustomerAddressScreenState extends State<CustomerAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isAdding = false;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController postcode = TextEditingController();

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.fName ?? "";
    lastNameController.text = widget.lName ?? "";
    emailController.text = widget.email ?? "";
    address1Controller.text = widget.address1 ?? "";
    address2Controller.text = widget.address2 ?? "";
    cityController.text = widget.city ?? "";
    stateController.text = widget.state ?? "";
    countryController.text = widget.country ?? "";
    postcode.text = widget.postcode ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                TitleBar(
                  title: 'Change Address',
                  isDrawerEnabled: false,
                  isSearchEnabled: false,
                  isBackEnabled: true,
                ),
                SizedBox(height: 2.h),

                /// ✅ Wrap with Form
                Form(
                  key: _formKey,
                  child: Container(
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
                          controller: firstNameController,
                          hintText: "Enter first name",
                          text: "First Name",
                          isTextavailable: true,
                          textInputType: TextInputType.text,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? "First name is required"
                                      : null,
                        ),
                        SizedBox(height: 1.h),
                        AppTextField(
                          controller: lastNameController,
                          hintText: "Enter last name",
                          text: "Last Name",
                          isTextavailable: true,
                          textInputType: TextInputType.text,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? "Last name is required"
                                      : null,
                        ),
                        SizedBox(height: 1.h),
                        AppTextField(
                          controller: emailController,
                          hintText: "Enter email",
                          text: "Email Address",
                          isTextavailable: true,
                          textInputType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is required";
                            }
                            if (!GetUtils.isEmail(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 1.h),
                        AppTextField(
                          controller: address1Controller,
                          hintText: "Enter address 1",
                          text: "Address 1",
                          isTextavailable: true,
                          textInputType: TextInputType.streetAddress,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? "Address 1 is required"
                                      : null,
                        ),
                        SizedBox(height: 1.h),
                        AppTextField(
                          controller: cityController,
                          hintText: "Enter city",
                          text: "City",
                          isTextavailable: true,
                          textInputType: TextInputType.text,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? "City is required"
                                      : null,
                        ),
                        SizedBox(height: 1.h),
                        AppTextField(
                          controller: postcode,
                          hintText: "Enter Post Code",
                          text: "Postcode",
                          isTextavailable: true,
                          textInputType: TextInputType.number,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? "Postcode is required"
                                      : null,
                        ),
                        SizedBox(height: 1.h),
                        AppTextField(
                          controller: stateController,
                          hintText: "Enter state",
                          text: "State",
                          isTextavailable: true,
                          textInputType: TextInputType.text,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? "State is required"
                                      : null,
                        ),
                        SizedBox(height: 1.h),
                        AppTextField(
                          controller: countryController,
                          hintText: "Enter country",
                          text: "Country",
                          isTextavailable: true,
                          textInputType: TextInputType.text,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? "Country is required"
                                      : null,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                /// Save Button
                InkWell(
                  onTap: () async {
                    if (!_formKey.currentState!.validate()) {
                      return; // ❌ Stop if validation fails
                    }
                    setState(() {
                      isAdding = true;
                    });
                    final service = UpdateAddressService();

                    final billing = {
                      "first_name": firstNameController.text.trim(),
                      "last_name": lastNameController.text.trim(),
                      "address_1": address1Controller.text.trim(),
                      "address_2": address2Controller.text.trim(),
                      "city": cityController.text.trim(),
                      "postcode": postcode.text.trim(),
                      "country": countryController.text.trim(),
                      "state": stateController.text.trim(),
                      "email": emailController.text.trim(),
                    };

                    final shipping = Map<String, dynamic>.from(billing);

                    try {
                      final response = await service.updateAddress(
                        billing: billing,
                        shipping: shipping,
                        id: widget.id ?? '',
                      );

                      if (response != null && response.statusCode == 200) {
                        showCustomSuccessSnackbar(
                          title: "Address Updated",
                          message:
                              "Your address has been successfully updated.",
                        );
                        setState(() {
                          isAdding = false;
                        });
                        Get.offAll(CartScreen());
                        Get.to(CheckOutScreen(cridit: widget.crdit ?? ""));
                      } else if (response != null) {
                        showCustomErrorSnackbar(
                          title: "Update Failed",
                          message:
                              "Server error (${response.statusCode}). Please try again.",
                        );
                        setState(() {
                          isAdding = false;
                        });
                      } else {
                        showCustomSuccessSnackbar(
                          title: "Offline Mode",
                          message:
                              "Address saved offline. It will sync once internet is back.",
                        );
                        setState(() {
                          isAdding = false;
                        });
                      }
                    } catch (e) {
                      showCustomErrorSnackbar(
                        title: "Unexpected Error",
                        message: "Something went wrong: $e",
                      );
                      setState(() {
                        isAdding = false;
                      });
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
