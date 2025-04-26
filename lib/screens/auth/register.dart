import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:softec25/screens/auth/login.dart';
import 'package:softec25/styles.dart';
import 'package:softec25/widgets/buttons.dart';
import 'package:softec25/widgets/textfield.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  static const String routeName = '/register';

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final confirmPasswordFocusNode = FocusNode();

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
                      ScreenUtil().statusBarHeight + 10.h,
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
                SizedBox(height: 20.h),
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
                SizedBox(height: 8.h),
                Text(
                  'Create your Aadat account',
                  style: regular.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.greyTextColor,
                  ),
                ),
                SizedBox(height: 26.h),
                Row(
                  children: [
                    Text(
                      'Full Name',
                      style: semiBold.copyWith(
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                CustomTextField(
                  hintText: 'John Doe',
                  controller: fullNameController,
                  keyboardType: TextInputType.name,
                  hasNextTextField: true,
                ),
                SizedBox(height: 20.h),
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
                  hasNextTextField: true,
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Text(
                      'Password',
                      style: semiBold.copyWith(
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                CustomTextField(
                  hintText: 'your password',
                  controller: passwordController,
                  obscureText: true,
                  hasNextTextField: true,
                  onSubmitted: (value) {
                    confirmPasswordFocusNode.requestFocus();
                  },
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Text(
                      'Confirm Password',
                      style: semiBold.copyWith(
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                CustomTextField(
                  hintText: 'confirm your password',
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  obscureText: true,
                ),
                SizedBox(height: 37.h),
                PrimaryButton(
                  text: 'Create Account',
                  onPressed: () {},
                ),
                SizedBox(height: 20.h),
                SecondaryButton(
                  text: 'Sign up with Google',
                  svgIcon: 'assets/svg/google.svg',
                  onPressed: () {},
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: semiBold.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                    SizedBox(width: 5),
                    CupertinoButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(
                          Login.routeName,
                        );
                      },
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      child: Text(
                        'Login',
                        style: semiBold.copyWith(
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
