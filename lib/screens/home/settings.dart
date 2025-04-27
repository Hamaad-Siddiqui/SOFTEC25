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
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 60.h),
            // Profile section at the top
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 32.h,
              ),
              child: Center(
                child: Column(
                  children: [
                    // Profile picture
                    CircleAvatar(
                      radius: 50.r,
                      backgroundColor: AppColors
                          .secondaryColor
                          .withOpacity(0.1),
                      child:
                          bloc.user != null &&
                                  bloc
                                      .user!
                                      .photoUrl
                                      .isNotEmpty
                              ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(
                                      50.r,
                                    ),
                                child: Image.network(
                                  bloc.user!.photoUrl,
                                  fit: BoxFit.cover,
                                  width: 100.r,
                                  height: 100.r,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress ==
                                        null)
                                      return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color:
                                            AppColors
                                                .secondaryColor,
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    );
                                  },
                                ),
                              )
                              : SvgPicture.asset(
                                'assets/svg/account-circle.svg',
                                height: 60.r,
                                width: 60.r,
                                colorFilter:
                                    ColorFilter.mode(
                                      AppColors
                                          .secondaryColor,
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
                        fontSize: 22.sp,
                        color: AppColors.secondaryColor,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // User email
                    Text(
                      bloc.user != null
                          ? bloc.user!.email
                          : 'user@example.com',
                      style: regular.copyWith(
                        fontSize: 15.sp,
                        color: AppColors.grayTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Connected list of settings options with full-width dividers
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      // Top divider (above the first item)
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.grey.withOpacity(0.3),
                      ),

                      Expanded(
                        child: ListView(
                          physics:
                              const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: [
                            // Edit Profile
                            _buildSettingOption(
                              svgPath:
                                  'assets/svg/edit-profile.svg',
                              title: 'Edit Profile',
                              onTap: () {
                                // Handle edit profile
                              },
                            ),

                            // Dark Mode with switch
                            _buildSettingOptionWithSwitch(
                              hasPadding: false,
                              svgPath:
                                  'assets/svg/dark-mode.svg',
                              title: 'Dark Mode',
                              value: _darkMode,
                              onChanged: (value) {
                                setState(() {
                                  _darkMode = value;
                                });
                              },
                            ),

                            // Notification Style
                            _buildSettingOption(
                              svgPath:
                                  'assets/svg/notification-style.svg',
                              title: 'Notification Style',
                              onTap: () {
                                // Handle notification style
                              },
                            ),

                            // Customization
                            _buildSettingOption(
                              svgPath:
                                  'assets/svg/customization.svg',
                              title: 'Customization',
                              onTap: () {
                                // Handle customization
                              },
                            ),

                            // Change Password
                            _buildSettingOption(
                              svgPath:
                                  'assets/svg/change-password.svg',
                              title: 'Change Password',
                              onTap: () {
                                // Handle change password
                              },
                            ),

                            // Logout
                            _buildSettingOption(
                              svgPath:
                                  'assets/svg/logout.svg',
                              title: 'Logout',
                              onTap: _handleLogout,
                              showDivider: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption({
    required String svgPath,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 20.h,
            ),
            child: Row(
              children: [
                // SVG Icon (without container)
                SvgPicture.asset(
                  svgPath,
                  width: 24.h,
                  height: 24.h,
                  colorFilter: ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 24.w),
                Text(
                  title,
                  style: semiBold.copyWith(
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.h,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey.withOpacity(0.3),
          ),
      ],
    );
  }

  Widget _buildSettingOptionWithSwitch({
    bool hasPadding = true,
    required String svgPath,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: hasPadding ? 20.h : 12.h,
          ),
          child: Row(
            children: [
              // SVG Icon (without container)
              SvgPicture.asset(
                svgPath,
                width: 24.h,
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 24.w),
              Text(
                title,
                style: semiBold.copyWith(
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              // Custom switch that looks like the one in the image
              CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: Colors.black,
                inactiveTrackColor: Colors.grey.withOpacity(
                  0.3,
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: Colors.grey.withOpacity(0.3),
        ),
      ],
    );
  }
}
