import 'package:bellissemo_ecom/utils/customInputDecoration.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'colors.dart';
import 'fontFamily.dart';

class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final bool readOnly;
  final FormFieldValidator<String>? validator;

  const SearchField({
    super.key,
    required this.controller,
    this.hintText = "Search...",
    this.onChanged,
    this.readOnly = false,
    this.validator,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_checkText);
  }

  void _checkText() {
    setState(() {
      _showClear = widget.controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_checkText);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: widget.controller,
        readOnly: widget.readOnly,
        validator: widget.validator,
        cursorColor: AppColors.blackColor,
        onChanged: widget.onChanged,
        style: TextStyle(
          fontFamily: FontFamily.regular,
          fontSize: 15.sp,
          color: AppColors.blackColor,
        ),
        decoration: inputDecoration(
          hintText: widget.hintText,
          // left search icon
          searchIcon: Icon(Icons.search, color: AppColors.mainColor),
          // right clear icon
          ico:
              _showClear
                  ? GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                    },
                    child: Icon(Icons.clear, color: AppColors.blackColor),
                  )
                  : null,
        ),
      ),
    );
  }
}
