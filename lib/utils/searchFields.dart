import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'colors.dart';
import 'fontFamily.dart';

class SearchBarWithFilter extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final Widget? suffix;
  final Widget? prefix;
  final bool readOnly;
  final FormFieldValidator? validator;

  const SearchBarWithFilter({
    super.key,
    required this.controller,
    this.hintText = "Search...",
    this.onChanged,
    this.suffix,
    this.prefix,
    this.readOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: validator,
      cursorColor: AppColors.blackColor,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: FontFamily.regular,
      ),
      decoration: InputDecoration(
        prefixIcon: prefix ??
            Icon(
              Icons.search_rounded,
              color: AppColors.whiteColor,
              size: 22,
            ),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        fillColor: AppColors.whiteColor,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.border,
          fontFamily: FontFamily.regular,
          fontWeight: FontWeight.w500,
          fontSize: 15.sp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: const BorderSide(
            width: 1.5,
            style: BorderStyle.solid,
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: const BorderSide(
            width: 1.5,
            style: BorderStyle.solid,
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: const BorderSide(
            width: 1.5,
            style: BorderStyle.solid,
            color: AppColors.blackColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: const BorderSide(
            width: 1.5,
            style: BorderStyle.solid,
            color: AppColors.redColor,
          ),
        ),
        errorStyle: TextStyle(color: AppColors.redColor, fontSize: 15.sp),
      ),
    );
  }
}
