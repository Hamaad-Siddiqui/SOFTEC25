import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:softec25/styles.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  static const String routeName = '/login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    // Future.delayed(const Duration(seconds: 5), () {
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLightBgColor,
      body: SizedBox(
        width: 1.sw,
        height: 1.sh,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: ScreenUtil().statusBarHeight + 80.h,
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/adat.svg',
                    height: 30.h,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Aadat',
                    style: bold.copyWith(fontSize: 24.sp),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Log in to your Aadat account',
                style: regular.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.greyTextColor,
                ),
              ),
              SizedBox(height: 26.h),
              Row(
                children: [
                  Text(
                    'Email',
                    style: semiBold.copyWith(
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
