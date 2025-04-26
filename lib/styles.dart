import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  static const primaryColor = Color(0xFFffffff);
  static const secondaryColor = Color(0xFF09090b);
  static const scaffoldLightBgColor = Color(0xFFFFFFFF);

  static const textFieldFillColor = Color(0xFFF7F7F8);
  static final barrierColor = const Color(
    0xFF151515,
  ).withOpacity(0.62);

  static const lightTextColor = Color(0xFFFFFFFF);
  static const greyTextColor = Color(0xFF707281);
  static const grayTextColor = Color(0xFF71717A);
  static const hintTextColor = Color(0xFFA0A1AB);
  static const darkTextColor = Color(0xFF000000);
}

/// Inter 300 font weight
final light = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w300,
  fontSize: 14.sp,
  color: AppColors.darkTextColor,
);

/// Inter 400 font weight
final regular = TextStyle(
  fontFamily: 'Inter',
  fontSize: 14.sp,
  color: AppColors.darkTextColor,
);

/// Inter 500 font weight
final medium = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w500,
  fontSize: 14.sp,
  color: AppColors.darkTextColor,
);

/// Inter 600 font weight
final semiBold = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w600,
  fontSize: 14.sp,
  color: AppColors.darkTextColor,
);

/// Gotham 700 font weight
final bold = TextStyle(
  fontFamily: 'Gotham',
  fontWeight: FontWeight.bold,
  fontSize: 14.sp,
  color: AppColors.darkTextColor,
);

/// Inter 700 font weight
final interBold = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w700,
  fontSize: 14.sp,
  color: AppColors.darkTextColor,
);
