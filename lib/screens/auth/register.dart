import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:softec25/bloc/main_bloc.dart';
import 'package:softec25/screens/auth/login.dart';
import 'package:softec25/screens/home/dashboard.dart';
import 'package:softec25/styles.dart';
import 'package:softec25/utils/utils.dart';
import 'package:softec25/widgets/buttons.dart';
import 'package:softec25/widgets/dialog.dart';
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

  Future<void> _registerWithEmail() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validate inputs
    if (fullName.isEmpty) {
      showCustomDialog(
        context,
        title: 'Error',
        description: 'Please enter your full name',
      );
      return;
    } else if (email.isEmpty) {
      showCustomDialog(
        context,
        title: 'Error',
        description: 'Please enter your email',
      );
      return;
    } else if (!isEmailValid(email)) {
      showCustomDialog(
        context,
        title: 'Error',
        description: 'Enter a valid email',
      );
      return;
    } else if (password.isEmpty) {
      showCustomDialog(
        context,
        title: 'Error',
        description: 'Please enter your password',
      );
      return;
    } else if (password.length < 6) {
      showCustomDialog(
        context,
        title: 'Error',
        description:
            'Password must be at least 6 characters long',
      );
      return;
    } else if (confirmPassword.isEmpty) {
      showCustomDialog(
        context,
        title: 'Error',
        description: 'Please confirm your password',
      );
      return;
    } else if (password != confirmPassword) {
      showCustomDialog(
        context,
        title: 'Error',
        description: 'Passwords do not match',
      );
      return;
    }

    final mb = context.read<MainBloc>();

    showLoadingIndicator(context);

    final result = await mb.registerUser(
      name: fullName,
      email: email,
      password: password,
    );

    hideLoadingIndicator();

    if (!mounted) return;

    if (result == 'ok') {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Dashboard.routeName,
        (route) => false,
      );
    } else {
      // Show error message
      showCustomDialog(
        context,
        title: 'Error',
        description: result,
      );
    }
  }

  Future<void> _registerWithGoogle() async {
    final mb = context.read<MainBloc>();

    showLoadingIndicator(context);

    final result = await mb.loginWithGoogle();

    hideLoadingIndicator();

    if (!mounted) return;

    if (result == 'ok') {
      // Google sign-in successful
      Navigator.of(context).pushNamedAndRemoveUntil(
        Dashboard.routeName,
        (route) => false,
      );
    } else if (result == 'banned') {
      showCustomDialog(
        context,
        title: 'Account Banned',
        description:
            'Your account has been banned. Please contact support for more information.',
      );
    } else {
      // Show error message
      showCustomDialog(
        context,
        title: 'Error',
        description: result,
      );
    }
  }

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
                      'assets/svg/aadat.svg',
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
                  hintText: 'john doe',
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
                  obscureText: true,
                ),
                SizedBox(height: 37.h),
                PrimaryButton(
                  text: 'Create Account',
                  onPressed: _registerWithEmail,
                ),
                SizedBox(height: 20.h),
                SecondaryButton(
                  text: 'Sign up with Google',
                  svgIcon: 'assets/svg/google.svg',
                  onPressed: _registerWithGoogle,
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
                    SizedBox(width: 3),
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
