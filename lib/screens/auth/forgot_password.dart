import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:softec25/styles.dart';
import 'package:softec25/widgets/buttons.dart';
import 'package:softec25/widgets/textfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  static const String routeName = '/forgot_password';

  @override
  State<ForgotPassword> createState() =>
      _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLightBgColor,
      body: SingleChildScrollView(
        child: SizedBox(
          width: 1.sw,
          height: 1.sh,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height:
                      ScreenUtil().statusBarHeight + 30.h,
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: SvgPicture.asset(
                    'assets/svg/back.svg',
                    height: 24.h,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(height: 30.h),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/svg/adat.svg',
                      height: 30.h,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Aadat',
                      style: interBold.copyWith(
                        fontSize: 24.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Text(
                  'Forgot your password?',
                  style: semiBold.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.darkTextColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'You will receive an email with a link to reset your password',
                  style: regular.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.greyTextColor,
                  ),
                ),
                SizedBox(height: 30.h),
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
                CustomTextField(
                  hintText: 'name@example.com',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 40.h),
                PrimaryButton(
                  text: 'Send Email',
                  onPressed: () {
                    // TODO: Implement password reset logic
                    // For now, just show a success message and go back
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Password reset link sent to ${emailController.text}',
                          style: medium.copyWith(
                            color: AppColors.lightTextColor,
                          ),
                        ),
                        backgroundColor:
                            AppColors.secondaryColor,
                      ),
                    );

                    // Go back after showing the message
                    Future.delayed(
                      const Duration(seconds: 2),
                      () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
