import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/colors.dart';
import '../../../utils/customMenuDrawer.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/textFields.dart';
import '../../../utils/titlebarWidget.dart';
import '../../cart/service/cartServices.dart';
import 'customersScreen.dart';


class CreateCustomerPage extends StatefulWidget {
  const CreateCustomerPage({Key? key}) : super(key: key);

  @override
  State<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends State<CreateCustomerPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeyaddCustomer =
  GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      drawer: CustomDrawer(),
      key: _scaffoldKeyaddCustomer,
      body: SingleChildScrollView(

        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TitleBar(
                title: 'Add Customers',
                isDrawerEnabled: true,
                isSearchEnabled: false,
                drawerCallback: () {
                  _scaffoldKeyaddCustomer.currentState?.openDrawer();
                },
                // onSearch: () {
                //   setState(() {
                //     isSearchEnabled = !isSearchEnabled;
                //   });
                // },
              ),
              /// 🧍 First Name
              AppTextField(
                controller: nameController,
                hintText: "First Name",
                text: "First Name",
                isTextavailable: true,
                textInputType: TextInputType.name,
                prefix: Icon(
                  Icons.person_outline,
                  color: AppColors.gray,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter first name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 1.h),

              /// 🧍 Last Name
              AppTextField(
                controller: lastNameController,
                hintText: "Last Name",
                text: "Last Name",
                isTextavailable: true,
                textInputType: TextInputType.name,
                prefix: Icon(
                  Icons.person_outline,
                  color: AppColors.gray,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter last name";
                  }
                  return null;
                },
              ),
               SizedBox(height: 1.h),

              /// ✉️ Email / Username
              AppTextField(
                controller: emailController,
                hintText: "Email Address",
                text: "Email Address",
                isTextavailable: true,
                textInputType: TextInputType.emailAddress,
                prefix: Icon(
                  Icons.email_outlined,
                  color: AppColors.gray,
                ),
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
               SizedBox(height: 5.h),

              /// ✅ Submit Button
              InkWell(
                onTap: () async {
                  // if (_formKey.currentState!.validate()) {
                  //   final cartService = CartService(); // 👈 create instance
                  //
                  //   cartService.addCustomer(
                  //     email: emailController.text.trim(),
                  //     firstName: nameController.text.trim(),
                  //     lastName: lastNameController.text.trim(),
                  //     password: "12345678",
                  //     username: "${nameController.text
                  //         .trim()}${lastNameController.text.trim()}",
                  //   );
                  // }
                  if (_formKey.currentState!.validate()) {
                    final cartService = CartService();

                    final response = await cartService.addCustomer(
                      email: emailController.text.trim(),
                      firstName: nameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                      password: "12345678",
                      username: "${nameController.text.trim()}${lastNameController.text.trim()}",
                    );

                    // ✅ Navigate only if added successfully
                    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
                      Get.to(() => CustomersScreen()); // 👈 your next screen here
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
          ).paddingSymmetric(vertical: 1.h,horizontal: 2.w),
        ),
      ),
    );
  }

  void _submitCustomer() {
    final name = nameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Customer Created: $name $lastName ($email)"),
        backgroundColor: Colors.green,
      ),
    );

    // TODO: 🔗 Add your API call or local DB save logic here
  }
}