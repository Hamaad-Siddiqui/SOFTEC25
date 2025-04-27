import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:softec25/styles.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const String routeName = '/notificationScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLightBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/svg/back.svg',
            height: 24.h,
            width: 24.h,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: semiBold.copyWith(
            fontSize: 18.sp,
            color: AppColors.secondaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Color(0xFFf6f6f6),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/svg/notification.svg',
                height: 40.h,
                width: 40.h,
                colorFilter: ColorFilter.mode(
                  AppColors.secondaryColor.withOpacity(0.7),
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No notifications yet',
              style: semiBold.copyWith(
                fontSize: 18.sp,
                color: AppColors.darkTextColor,
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 40.w,
              ),
              child: Text(
                'When you receive notifications, they will appear here',
                style: regular.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.grayTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
