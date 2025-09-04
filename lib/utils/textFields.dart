import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:sizer/sizer.dart';

import 'colors.dart';
import 'fontFamily.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String text;
  final int? maxLength;
  final int? maxline;
  final Callback? ontap;
  final bool? isTextavailable;
  final bool isTextCentered;
  final bool textsize;
  final bool readOnly;
  final void Function()? buttonOnPressed;
  final Widget? suffix;
  final Widget? prefix;
  final EdgeInsets? pad;
  final FormFieldValidator? validator;
  final bool? enable;
  final bool? obscureText;
  final TextInputType textInputType;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.text,
    this.maxLength,
    this.maxline,
    this.ontap,
    required this.isTextavailable,
    this.isTextCentered = false,
    this.textsize = false,
    this.readOnly = false,
    this.buttonOnPressed,
    this.suffix,
    this.prefix,
    this.pad,
    this.validator,
    this.enable,
    this.obscureText,
    required this.textInputType,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.obscureText ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.text,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.light,
                    color: AppColors.blackColor,
                    fontSize: 16.sp,
                  ),
                ),
                if (widget.validator !=
                    null) // shows red * if validator is present
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.redColor,
                      fontSize: 16.sp,
                      fontFamily: FontFamily.light,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            maxLines: widget.maxline ?? 1,
            readOnly: widget.readOnly,
            cursorColor: AppColors.blackColor,
            onTap: widget.ontap,
            obscureText: isObscured,
            keyboardType: widget.textInputType,
            controller: widget.controller,
            validator: widget.validator,
            style: const TextStyle(fontFamily: FontFamily.regular),
            inputFormatters: [
              LengthLimitingTextInputFormatter(widget.maxLength),
            ],
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              suffixIcon:
                  widget.obscureText == true
                      ? IconButton(
                        icon: Icon(
                          isObscured ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        },
                      )
                      : widget.suffix,
              prefixIcon: widget.prefix,
              enabled: widget.enable ?? true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              fillColor: AppColors.whiteColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.w),
                borderSide: const BorderSide(
                  width: 1.5,
                  style: BorderStyle.solid,
                  color: AppColors.border,
                ),
              ),
              errorStyle: TextStyle(color: AppColors.redColor, fontSize: 15.sp),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.w),
                borderSide: const BorderSide(
                  width: 1.5,
                  style: BorderStyle.solid,
                  color: AppColors.redColor,
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
                  color: AppColors.border,
                ),
              ),
              filled: true,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: AppColors.border,
                fontFamily: FontFamily.regular,
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
