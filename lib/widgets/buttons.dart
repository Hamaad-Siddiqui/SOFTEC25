import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:softec25/styles.dart';

import '../utils/utils.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.padding,
    this.backgroundColor,
    this.isLoading = false,
    this.disabled = false,
    this.textStyle,
    this.icon,
  });
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool isLoading;
  final bool disabled;
  final TextStyle? textStyle;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final borderRadius = 12.r;

    final textHeight =
        getTextSize(
          text,
          textStyle ??
              bold.copyWith(
                fontSize: 15.sp,
                letterSpacing: -0.24,
              ),
        ).height;

    return SizedBox(
      width: width ?? double.infinity,
      child: Padding(
        padding:
            padding ??
            EdgeInsets.symmetric(horizontal: 0.w),
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            backgroundColor:
                disabled
                    ? Colors.grey
                    : backgroundColor ??
                        AppColors.secondaryColor,
            padding: EdgeInsets.symmetric(
              vertical: icon != null ? 14.h : 14.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius,
              ),
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed:
              isLoading || disabled ? null : onPressed,
          child:
              isLoading
                  ? Center(
                    child: SizedBox(
                      height: textHeight,
                      width: textHeight,
                      child:
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(
                                  AppColors.primaryColor,
                                ),
                          ),
                    ),
                  )
                  : icon != null
                  ? Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Image.asset(icon!, height: 16.h),
                      SizedBox(width: 15.w),
                      Text(
                        text,
                        style:
                            textStyle ??
                            medium.copyWith(
                              fontSize: 14.sp,
                              color:
                                  AppColors.lightTextColor,
                            ),
                      ),
                    ],
                  )
                  : Text(
                    text,
                    style:
                        textStyle ??
                        medium.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.lightTextColor,
                        ),
                  ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.padding,
    this.backgroundColor = Colors.white,
    this.isLoading = false,
    this.disabled = false,
    this.textStyle,
    this.svgIcon,
  });
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool isLoading;
  final bool disabled;
  final TextStyle? textStyle;
  final String? svgIcon;

  @override
  Widget build(BuildContext context) {
    final borderRadius = 12.r;

    final textHeight =
        getTextSize(
          text,
          textStyle ??
              bold.copyWith(
                fontSize: 15.sp,
                letterSpacing: -0.24,
              ),
        ).height;

    return SizedBox(
      width: width ?? double.infinity,
      child: Padding(
        padding:
            padding ??
            EdgeInsets.symmetric(horizontal: 0.w),
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondaryColor,
            backgroundColor:
                disabled ? Colors.grey : backgroundColor,
            padding: EdgeInsets.symmetric(
              vertical: svgIcon != null ? 14.h : 14.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius,
              ),
              side: const BorderSide(
                color: Color(0xFFE4E4E7),
              ),
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed:
              isLoading || disabled ? null : onPressed,
          child:
              isLoading
                  ? Center(
                    child: SizedBox(
                      height: textHeight,
                      width: textHeight,
                      child:
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(
                                  AppColors.primaryColor,
                                ),
                          ),
                    ),
                  )
                  : svgIcon != null
                  ? Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        svgIcon!,
                        height: 16.h,
                      ),
                      SizedBox(width: 15.w),
                      Text(
                        text,
                        style:
                            textStyle ??
                            medium.copyWith(
                              fontSize: 14.sp,
                              color:
                                  AppColors.darkTextColor,
                            ),
                      ),
                    ],
                  )
                  : Text(
                    text,
                    style:
                        textStyle ??
                        medium.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.darkTextColor,
                        ),
                  ),
        ),
      ),
    );
  }
}
