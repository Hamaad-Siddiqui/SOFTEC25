import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:softec25/screens/home/ai.dart';
import 'package:softec25/screens/home/home.dart';
import 'package:softec25/screens/home/mood_tracking.dart';
import 'package:softec25/screens/home/settings.dart';
import 'package:softec25/screens/operations/notes.dart';
import 'package:softec25/styles.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  static const String routeName = '/dashboard';

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin {
  int _selectedIndex = 0; // Home selected by default
  bool _showOverlay =
      false; // To control visibility of the options overlay

  // Animation controllers for menu items
  late AnimationController _fadeController;
  late List<AnimationController> _itemControllers;
  late List<Animation<Offset>> _itemOffsetAnimations;

  // Animation controller for bottom nav bar
  late AnimationController _navBarController;
  late Animation<Offset> _navBarAnimation;

  // List of dummy screens for the navigation
  final List<Widget> _screens = [
    HomeScreen(),
    const DummyScreen(
      title: 'Calendar',
      color: Colors.green,
    ),
    const DummyScreen(
      title: 'Progress',
      color: Colors.orange,
    ),
    SettingScreen(),
  ];

  // List of SVG icon paths in order
  final List<String> _iconPaths = [
    'assets/svg/home.svg',
    'assets/svg/calendar.svg',
    'assets/svg/progress.svg',
    'assets/svg/settings.svg',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize fade animation controller for the overlay
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Initialize item animation controllers (one for each menu option)
    _itemControllers = List.generate(
      4, // 4 menu items: Note, Checklist, Reminder, Task
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    // Create slide animations for each menu item (from bottom to their position)
    _itemOffsetAnimations =
        _itemControllers.map((controller) {
          return Tween<Offset>(
            begin: const Offset(0, 1), // Start from below
            end: Offset.zero, // End at original position
          ).animate(
            CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            ),
          );
        }).toList();

    // Initialize bottom navigation bar animation controller
    _navBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Create slide animation for bottom navigation bar (slide down out of view)
    _navBarAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(
        0,
        1,
      ), // Slide down by 100% of its height
    ).animate(
      CurvedAnimation(
        parent: _navBarController,
        curve: Curves.easeInOut,
      ),
    );

    // Bottom nav bar should be visible initially
    _navBarController.value = 0.0;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    _navBarController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Toggle overlay visibility with animations
  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });

    if (_showOverlay) {
      // Show overlay and animate items
      _fadeController.forward();
      _navBarController.forward(); // Slide navbar out

      // Staggered animation for menu items (from bottom to top)
      for (
        int i = _itemControllers.length - 1;
        i >= 0;
        i--
      ) {
        Future.delayed(
          Duration(
            milliseconds:
                50 * (_itemControllers.length - 1 - i),
          ),
          () => _itemControllers[i].forward(),
        );
      }
    } else {
      // Hide overlay and reset animations
      _fadeController.reverse();
      _navBarController.reverse(); // Slide navbar back in
      for (var controller in _itemControllers) {
        controller.reverse();
      }
    }
  }

  // Create a new note
  void _createNewNote() {
    _toggleOverlay(); // Close the overlay first

    // Navigate to note detail screen in create mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NoteDetailScreen(
              // Pass null note to create a new one
              isEditing: true, // Start in editing mode
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody:
          true, // Important to allow content to flow under bottom nav
      body: Stack(
        children: [
          // Main screen content
          _screens[_selectedIndex],

          // Dark overlay with options
          if (_showOverlay)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    // Full screen semi-transparent dark overlay
                    Positioned.fill(
                      child: FadeTransition(
                        opacity: _fadeController,
                        child: GestureDetector(
                          onTap: _toggleOverlay,
                          child: Container(
                            color: Colors.black.withOpacity(
                              0.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Option buttons positioned above where the FAB was
                    Positioned(
                      bottom:
                          110.h, // Position above where FAB was
                      right:
                          16.w, // Align with right side of screen
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          // Note option
                          SlideTransition(
                            position:
                                _itemOffsetAnimations[0],
                            child: _buildOptionButton(
                              label: 'Note',
                              iconPath:
                                  'assets/svg/journal.svg',
                              bgColor:
                                  AppColors.secondaryColor,

                              onTap: () {
                                _createNewNote();
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Checklist option
                          SlideTransition(
                            position:
                                _itemOffsetAnimations[1],
                            child: _buildOptionButton(
                              label: 'Checklist',
                              iconPath:
                                  'assets/svg/line.svg',
                              bgColor:
                                  AppColors.secondaryColor,

                              onTap: () {
                                _toggleOverlay();
                                // Add action for Checklist
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Reminder option
                          SlideTransition(
                            position:
                                _itemOffsetAnimations[2],
                            child: _buildOptionButton(
                              label: 'Reminder',
                              iconPath:
                                  'assets/svg/notification.svg',
                              bgColor:
                                  AppColors.secondaryColor,
                              onTap: () {
                                _toggleOverlay();
                                Navigator.pushNamed(
                                  context,
                                  MoodTrackingScreen
                                      .routeName,
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Tasks option
                          SlideTransition(
                            position:
                                _itemOffsetAnimations[3],
                            child: _buildOptionButton(
                              label: 'Task',
                              iconPath:
                                  'assets/svg/progress.svg',
                              bgColor: const Color(
                                0xFF3D7EFF,
                              ),
                              onTap: () {
                                _toggleOverlay();
                                Navigator.pushNamed(
                                  context,
                                  AIScreen.routeName,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 0 &&
                  !_showOverlay // Only show FAB on Home screen and when overlay is not shown
              ? FloatingActionButton(
                onPressed: _toggleOverlay,
                // backgroundColor: const Color(0xFF47464A),
                backgroundColor: AppColors.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  Icons.add,
                  size: 24.w,
                  color: Colors.white,
                ),
              )
              : null,
      bottomNavigationBar: SlideTransition(
        position: _navBarAnimation,
        child: Container(
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
              SizedBox(
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

  Widget _buildOptionButton({
    required String label,
    required String iconPath,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              height: 36.h,
              width: 36.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  height: 20.h,
                  width: 20.h,
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
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
    super.key,
    required this.title,
    required this.color,
  });

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
