import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:softec25/styles.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField({
    Key? key,
    this.focusNode,
    this.controller,
    this.keyboardType,
    this.svgIcon,
    this.suffixIcon,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.padding = EdgeInsets.zero,
    required this.hintText,
    this.hasNextTextField = false,
    this.obscureText = false,
    this.isDropdown = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.svgSize,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
    this.borderRadius,
    this.inputFormatters = const [],
    this.showClearButton = false,
    this.initialValue = '',
    this.onSubmitted,
  }) : super(key: key);

  final FocusNode? focusNode;
  TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? svgIcon;
  final String? suffixIcon;
  final String hintText;
  final bool hasNextTextField;
  final bool obscureText;
  final bool isDropdown;
  final EdgeInsets padding;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int minLines;
  final double? svgSize;
  final bool readOnly;
  final VoidCallback? onTap;
  final double? borderRadius;
  final TextInputAction? textInputAction;
  final void Function(String? text)? onChanged;
  final List<TextInputFormatter> inputFormatters;
  final bool showClearButton;
  final String initialValue;
  final void Function(String? text)? onSubmitted;

  @override
  State<CustomTextField> createState() =>
      _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool showPassword = false;

  @override
  void initState() {
    if (widget.initialValue.isNotEmpty) {
      if (widget.controller != null) {
        widget.controller!.text = widget.initialValue;
      } else {
        widget.controller = TextEditingController(
          text: widget.initialValue,
        );
      }
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? 12.w;
    return Padding(
      padding: widget.padding,
      child: TextField(
        onSubmitted: widget.onSubmitted,
        readOnly: widget.readOnly,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        textCapitalization: widget.textCapitalization,
        obscureText: widget.obscureText && !showPassword,
        controller: widget.controller,
        focusNode: widget.focusNode,
        inputFormatters: widget.inputFormatters,
        cursorColor: AppColors.secondaryColor,
        textInputAction:
            widget.textInputAction ??
            (widget.hasNextTextField
                ? TextInputAction.next
                : TextInputAction.done),
        keyboardType: widget.keyboardType,
        style: medium.copyWith(
          fontSize: 15.sp,
          color: AppColors.darkTextColor,
        ),
        decoration: InputDecoration(
          fillColor: AppColors.textFieldFillColor,
          contentPadding: EdgeInsets.only(
            top: 14.h,
            bottom: 14.h,
            left: 14.w,
            right:
                widget.showClearButton || widget.obscureText
                    ? 0.w
                    : 14.w,
          ),
          isDense: true,
          filled: true,
          prefixIconConstraints:
              widget.svgIcon != null
                  ? BoxConstraints(
                    minHeight: widget.svgSize ?? 20.w,
                    maxHeight: widget.svgSize ?? 20.w,
                  )
                  : null,
          prefixIcon:
              widget.svgIcon != null
                  ? Padding(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 12.w,
                    ),
                    child: SvgPicture.asset(
                      widget.svgIcon!,
                      height: widget.svgSize ?? 20.w,
                      fit: BoxFit.fitHeight,
                    ),
                  )
                  : null,
          // Add a suffix icon if obscureText is true
          suffixIcon:
              widget.showClearButton
                  ? CupertinoButton(
                    onPressed: () {
                      widget.controller!.clear();
                      widget.onChanged!(
                        widget.controller!.text,
                      );
                    },
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: Icon(
                        CupertinoIcons.clear_thick_circled,
                        color: AppColors.secondaryColor,
                        size: 20.w,
                      ),
                    ),
                  )
                  : widget.obscureText
                  ? CupertinoButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: SvgPicture.asset(
                        showPassword
                            ? 'assets/svg/eye.svg'
                            : 'assets/svg/eye-off.svg',
                        height: 24.w,
                      ),
                    ),
                  )
                  : widget.suffixIcon != null
                  ? Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: SvgPicture.asset(
                      widget.suffixIcon!,
                      height: 24.w,
                    ),
                  )
                  : null,
          suffixIconConstraints:
              widget.suffixIcon != null
                  ? BoxConstraints(
                    minHeight: 24.w,
                    maxHeight: 24.w,
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              borderRadius,
            ),
            // borderSide: const BorderSide(
            //   width: 1,
            //   color: AppColors.borderColor,
            // ),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              borderRadius,
            ),
            borderSide: const BorderSide(
              color: AppColors.secondaryColor,
              width: 1.5,
            ),
          ),
          hintText: widget.hintText,
          hintStyle: regular.copyWith(
            fontSize: 15.sp,
            color: AppColors.hintTextColor,
          ),
        ),
      ),
    );
  }
}
