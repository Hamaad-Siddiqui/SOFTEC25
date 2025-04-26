import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:softec25/bloc/main_bloc.dart';
import 'package:softec25/styles.dart';
import 'package:softec25/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(
      context,
      listen: false,
    );
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
                height: ScreenUtil().statusBarHeight + 40.h,
              ),
              Row(
                children: [
                  bloc.user!.photoUrl == ""
                      ? SvgPicture.asset(
                        'assets/svg/aadat.svg',
                        height: 40.h,
                        width: 40.h,
                      )
                      : CircleAvatar(
                        radius: 20.h,
                        backgroundImage: NetworkImage(
                          bloc.user!.photoUrl,
                        ),
                      ),
                  SizedBox(width: 12.w),
                  Column(
                    mainAxisAlignment:
                        MainAxisAlignment.start,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: semiBold.copyWith(
                          fontSize: 20.sp,
                        ),
                      ),
                      Text(
                        '${bloc.user!.fullName} ! 👋 ',
                        style: regular.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.grayTextColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 32.h,
                    height: 32.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFFf0f0f0),
                        width: 1.w,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svg/notification.svg',
                        height: 24.h,
                        width: 24.h,
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
