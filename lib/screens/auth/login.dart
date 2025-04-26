import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:softec25/screens/auth/forgot_password.dart';
import 'package:softec25/screens/auth/register.dart';
import 'package:softec25/styles.dart';
import 'package:softec25/widgets/buttons.dart';
import 'package:softec25/widgets/textfield.dart';

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
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
                    style: interBold.copyWith(
                      fontSize: 24.sp,
                    ),
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
              ),
              SizedBox(height: 13.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(ForgotPassword.routeName);
                    },
                    child: Text(
                      'Forgot password?',
                      style: semiBold.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 37.h),
              PrimaryButton(
                text: 'Continue with Email',
                onPressed: () {},
              ),
              SizedBox(height: 20.h),
              SecondaryButton(
                text: 'Continue with Google',
                svgIcon: 'assets/svg/google.svg',
                onPressed: () {},
              ),
              SizedBox(height: 68.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don’t have an account?',
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
                      ).pushNamed(Register.routeName);
                    },
                    padding: EdgeInsets.zero,
                    minSize: 0,

                    child: Text(
                      'Register',
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
    );
  }
}
