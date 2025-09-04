import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/titlebarWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          TitleBar(
            title: 'Products',
            isDrawerEnabled: true,
            isSearchEnabled: true,
          ),
        ],
      ).paddingSymmetric(horizontal: 3.w,vertical: 0.5.h),
    );
  }
}
