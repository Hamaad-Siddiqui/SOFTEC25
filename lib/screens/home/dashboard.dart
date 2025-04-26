import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:softec25/styles.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  static const String routeName = '/dashboard';

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0; // Home selected by default

  // List of dummy screens for the navigation
  final List<Widget> _screens = [
    const DummyScreen(title: 'Home', color: Colors.blue),
    const DummyScreen(
      title: 'Calendar',
      color: Colors.green,
    ),
    const DummyScreen(
      title: 'Progress',
      color: Colors.orange,
    ),
    const DummyScreen(
      title: 'Settings',
      color: Colors.purple,
    ),
  ];

  // List of SVG icon paths in order
  final List<String> _iconPaths = [
    'assets/svg/home.svg',
    'assets/svg/calendar.svg',
    'assets/svg/progress.svg',
    'assets/svg/settings.svg',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height:
            80.h +
            10.h, // Added bottomBarHeight for safe area
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            // Navigation items row
            Container(
              height: 80.h,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: List.generate(
                  _iconPaths.length,
                  (index) => _buildNavItem(
                    index,
                    _iconPaths[index],
                  ),
                ),
              ),
            ),
            // Bottom padding for safe area
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: 80.w,
        height: 45.h,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.secondaryColor
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            height: 24.h,
            width: 24.w,
            // Apply color filter based on selection state
            colorFilter: ColorFilter.mode(
              isSelected
                  ? Colors.white
                  : AppColors.secondaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

// A simple dummy screen widget to show different content for each tab
class DummyScreen extends StatelessWidget {
  final String title;
  final Color color;

  const DummyScreen({
    Key? key,
    required this.title,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: semiBold.copyWith(
            fontSize: 18.sp,
            color: AppColors.darkTextColor,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: color,
            ),
            SizedBox(height: 20.h),
            Text(
              '$title Screen',
              style: interBold.copyWith(
                fontSize: 24.sp,
                color: color,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'This is a placeholder for the $title screen',
              style: medium.copyWith(fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }
}
