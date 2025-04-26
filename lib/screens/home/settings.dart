import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:softec25/bloc/main_bloc.dart';
import 'package:softec25/screens/auth/login.dart';
import 'package:softec25/styles.dart';
import 'package:softec25/widgets/dialog.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  static const String routeName = '/settingScreen';

  @override
  State<SettingScreen> createState() =>
      _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _darkMode = false;

  void _handleLogout() async {
    final bloc = Provider.of<MainBloc>(
      context,
      listen: false,
    );

    // Show confirmation dialog
    // showCustomDialog(
    //   context,
    //   title: 'Logout',
    //   description: 'Are you sure you want to logout?',
    //   primaryButtonText: 'Logout',
    //   primaryButtonOnPressed: () async {
    //     Navigator.of(context).pop(); // Close dialog

    //     // Perform logout
    //     await bloc.logoutUser();

    //     if (!mounted) return;

    //     // Navigate to login screen
    //     Navigator.of(context).pushNamedAndRemoveUntil(
    //       Login.routeName,
    //       (route) => false,
    //     );
    //   },
    //   secondaryButtonText: 'Cancel',
    //   secondaryButtonOnPressed: () {
    //     Navigator.of(context).pop(); // Close dialog
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: AppColors.scaffoldLightBgColor,
      body: SingleChildScrollView(
        child: SizedBox(
          width: 1.sw,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height:
                      ScreenUtil().statusBarHeight + 20.h,
                ),

                // Settings header
                Text(
                  'Settings',
                  style: interBold.copyWith(
                    fontSize: 32.sp,
                    color: AppColors.secondaryColor,
                  ),
                ),

                SizedBox(height: 32.h),

                // Profile section
                Center(
                  child: Column(
                    children: [
                      // Profile picture
                      CircleAvatar(
                        radius: 55.r,
                        backgroundColor: Colors.black,
                        child:
                            bloc.user != null &&
                                    bloc
                                        .user!
                                        .photoUrl
                                        .isNotEmpty
                                ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                        55.r,
                                      ),
                                  child: Image.network(
                                    bloc.user!.photoUrl,
                                    fit: BoxFit.cover,
                                    width: 110.r,
                                    height: 110.r,
                                  ),
                                )
                                : SvgPicture.asset(
                                  'assets/svg/aadat.svg',
                                  height: 60.r,
                                  width: 60.r,
                                  colorFilter:
                                      const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                ),
                      ),

                      SizedBox(height: 16.h),

                      // User name
                      Text(
                        bloc.user != null
                            ? bloc.user!.fullName
                            : 'User Name',
                        style: semiBold.copyWith(
                          fontSize: 24.sp,
                          color: AppColors.secondaryColor,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      // User email
                      Text(
                        bloc.user != null
                            ? bloc.user!.email
                            : 'user@example.com',
                        style: regular.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.grayTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                // Settings options list - each item designed as a card
                _buildSettingOption(
                  iconWidget: SvgPicture.asset(
                    'assets/svg/edit-profile.svg',
                    width: 24.h,
                    height: 24.h,
                    colorFilter: ColorFilter.mode(
                      AppColors.secondaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: 'Edit Profile',
                  onTap: () {
                    // Handle edit profile
                  },
                ),

                _buildSettingOptionWithSwitch(
                  title: 'Dark Mode',
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
                ),

                _buildSettingOption(
                  iconWidget: SvgPicture.asset(
                    'assets/svg/notification.svg',
                    width: 24.h,
                    height: 24.h,
                    colorFilter: ColorFilter.mode(
                      AppColors.secondaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: 'Notification Style',
                  onTap: () {
                    // Handle notification style
                  },
                ),

                _buildSettingOption(
                  iconWidget: Icon(
                    Icons.dashboard_customize_outlined,
                    size: 24.h,
                    color: AppColors.secondaryColor,
                  ),
                  title: 'Customization',
                  onTap: () {
                    // Handle customization
                  },
                ),

                _buildSettingOption(
                  iconWidget: Icon(
                    Icons.key,
                    size: 24.h,
                    color: AppColors.secondaryColor,
                  ),
                  title: 'Change Password',
                  onTap: () {
                    // Handle change password
                  },
                ),

                _buildSettingOption(
                  iconWidget: Icon(
                    Icons.logout,
                    size: 24.h,
                    color: AppColors.secondaryColor,
                  ),
                  title: 'Logout',
                  onTap: _handleLogout,
                ),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingOption({
    required Widget iconWidget,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            child: Row(
              children: [
                // Icon
                SizedBox(
                  width: 32.h,
                  height: 32.h,
                  child: iconWidget,
                ),
                SizedBox(width: 16.w),
                Text(
                  title,
                  style: semiBold.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.secondaryColor,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24.h,
                  color: AppColors.secondaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingOptionWithSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        child: Row(
          children: [
            // Moon icon for dark mode
            SizedBox(
              width: 32.h,
              height: 32.h,
              child: Icon(
                Icons.dark_mode,
                size: 24.h,
                color: AppColors.secondaryColor,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: semiBold.copyWith(
                fontSize: 16.sp,
                color: AppColors.secondaryColor,
              ),
            ),
            Spacer(),
            // Custom switch that looks more like the one in the image
            CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.secondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
