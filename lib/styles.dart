import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Change Colors here
// use as `AppColors.primaryColor`, `AppColors.secondaryColor`, etc
class AppColors {
  static const primaryColor = Color(0xFFffffff);
  static const secondaryColor = Color(0xFF09090b);

  static const lightTextColor = Color(0xFF8B8B8B);
  static const darkTextColor = Color(0xFF000000);
}

// change TextStyles here
// use as regular.copyWith(), bold.copyWith(), etc
// and override the properties in the copyWith method

final thin = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14.sp,
  fontWeight: FontWeight.w100,
  color: AppColors.darkTextColor,
);

final light = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14.sp,
  fontWeight: FontWeight.w300,
  color: AppColors.darkTextColor,
);

final regular = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14.sp,
  fontWeight: FontWeight.w400,
  color: AppColors.darkTextColor,
);

final medium = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14.sp,
  fontWeight: FontWeight.w500,
  color: AppColors.darkTextColor,
);

final semiBold = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14.sp,
  fontWeight: FontWeight.w600,
  color: AppColors.darkTextColor,
);

final bold = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14.sp,
  fontWeight: FontWeight.w700,
  color: AppColors.darkTextColor,
);

final black = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14.sp,
  fontWeight: FontWeight.w900,
  color: AppColors.darkTextColor,
);
