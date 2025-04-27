import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:softec25/bloc/main_bloc.dart';
import 'package:softec25/models/reminder_model.dart';
import 'package:softec25/models/task_model.dart';
import 'package:softec25/screens/home/ai.dart';
import 'package:softec25/styles.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  static const String routeName = '/plannerScreen';

  @override
  State<PlannerScreen> createState() =>
      _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _monthDays;
  bool _showMonthView = false;

  // Initialize with some dummy tasks and reminders
  late List<dynamic>
  _allItems; // Combined tasks and reminders

  @override
  void initState() {
    super.initState();

    // Set today as the selected date
    _selectedDate = DateTime.now();

    // Generate days for the current month
    _generateMonthDays();

    // Fetch items for the selected date (initially today)
    _fetchItemsForSelectedDate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = Provider.of<MainBloc>(
        context,
        listen: false,
      );
      bloc.fetchReminders();
    });
  }

  // Generate days for the current month
  void _generateMonthDays() {
    final DateTime firstDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final DateTime lastDay = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    );

    // Include days from the previous month to start the grid from Monday
    int startPadding =
        firstDay.weekday -
        1; // 0 = Monday in DateTime.weekday

    // Get the last days of previous month for padding
    final DateTime prevMonthLastDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      0,
    );
    List<DateTime> prevMonthDays = [];
    for (int i = 0; i < startPadding; i++) {
      prevMonthDays.add(
        DateTime(
          prevMonthLastDay.year,
          prevMonthLastDay.month,
          prevMonthLastDay.day - (startPadding - 1) + i,
        ),
      );
    }

    // Current month days
    List<DateTime> currentMonthDays = [];
    for (int i = 1; i <= lastDay.day; i++) {
      currentMonthDays.add(
        DateTime(
          _selectedDate.year,
          _selectedDate.month,
          i,
        ),
      );
    }

    // Include days from the next month to have a complete grid (6 rows x 7 columns)
    int daysNeeded =
        42 -
        (prevMonthDays.length + currentMonthDays.length);
    List<DateTime> nextMonthDays = [];
    for (int i = 1; i <= daysNeeded; i++) {
      nextMonthDays.add(
        DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          i,
        ),
      );
    }

    // Combine all days
    _monthDays = [
      ...prevMonthDays,
      ...currentMonthDays,
      ...nextMonthDays,
    ];
  }

  // Fetch tasks and reminders for the selected date
  void _fetchItemsForSelectedDate() {
    final bloc = Provider.of<MainBloc>(
      context,
      listen: false,
    );

    // Get items for the selected date
    _allItems = bloc.getRemindersAndTasksForDate(
      _selectedDate,
    );

    // If it's a mock environment or we need sample data
    if (_allItems.isEmpty) {
      _generateSampleItems();
    }

    // Sort items by time
    _sortItemsByTime();
  }

  // Generate sample items for UI testing
  void _generateSampleItems() {
    final now = DateTime.now();

    _allItems = [
      // Full day items (no specific time)
      TaskModel(
        id: 'fd1',
        title: 'Project Planning Day',
        description: 'Plan the quarterly project roadmap',
        dueDate: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        ),
        category: 'Work',
        createdAt: now.subtract(const Duration(days: 3)),
      ),

      // Morning items
      ReminderModel(
        id: 'm1',
        title: 'Team Standup',
        description: 'Daily team standup meeting',
        dueDate: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          9,
          30,
        ),
        category: 'Work',
        createdAt: now.subtract(const Duration(days: 2)),
        userId: 'user123',
      ),
      TaskModel(
        id: 'm2',
        title: 'Review PR #452',
        description: 'Code review for the new feature',
        dueDate: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          11,
          0,
        ),
        category: 'Work',
        createdAt: now.subtract(const Duration(days: 1)),
      ),

      // Afternoon items
      ReminderModel(
        id: 'a1',
        title: 'Lunch with Alex',
        description: 'Discuss collaboration opportunities',
        dueDate: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          12,
          30,
        ),
        category: 'Personal',
        createdAt: now.subtract(const Duration(days: 2)),
        userId: 'user123',
      ),
      TaskModel(
        id: 'a2',
        title: 'Client Call',
        description: 'Project status update',
        dueDate: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          14,
          0,
        ),
        category: 'Work',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ReminderModel(
        id: 'a3',
        title: 'Send Weekly Report',
        description:
            'Compile and send the weekly progress report',
        dueDate: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          16,
          0,
        ),
        category: 'Work',
        createdAt: now.subtract(const Duration(days: 1)),
        userId: 'user123',
      ),

      // Evening items
      TaskModel(
        id: 'e1',
        title: 'Gym Session',
        description: 'Upper body workout',
        dueDate: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          18,
          30,
        ),
        category: 'Health',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ReminderModel(
        id: 'e2',
        title: 'Call Parents',
        description: 'Weekly check-in call',
        dueDate: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          20,
          0,
        ),
        category: 'Personal',
        createdAt: now.subtract(const Duration(days: 2)),
        userId: 'user123',
      ),
    ];
  }

  // Sort items by time
  void _sortItemsByTime() {
    _allItems.sort((a, b) {
      DateTime timeA;
      DateTime timeB;

      if (a is TaskModel) {
        timeA = a.dueDate;
      } else if (a is ReminderModel) {
        timeA = a.dueDate;
      } else {
        return 0;
      }

      if (b is TaskModel) {
        timeB = b.dueDate;
      } else if (b is ReminderModel) {
        timeB = b.dueDate;
      } else {
        return 0;
      }

      return timeA.compareTo(timeB);
    });
  }

  // Check if a date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if a date is in the current month
  bool _isCurrentMonth(DateTime date) {
    return date.month == _selectedDate.month &&
        date.year == _selectedDate.year;
  }

  // Navigate to previous month
  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month - 1,
        1,
      );
      _generateMonthDays();
    });
  }

  // Navigate to next month
  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + 1,
        1,
      );
      _generateMonthDays();
    });
  }

  // Select a day
  void _selectDay(DateTime day) {
    setState(() {
      _selectedDate = day;
      _showMonthView = false;
      _fetchItemsForSelectedDate();
    });
  }

  // Toggle month view
  void _toggleMonthView() {
    setState(() {
      _showMonthView = !_showMonthView;
      if (_showMonthView) {
        _generateMonthDays();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLightBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _showMonthView
                ? _buildMonthView()
                : _buildDayView(),
          ],
        ),
      ),
    );
  }

  // Build the header with date selector
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/svg/back.svg',
                  height: 24.h,
                  width: 24.h,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                'Planner',
                style: semiBold.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.darkTextColor,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.add_alert_outlined,
                  color: AppColors.secondaryColor,
                  size: 24.h,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AIScreen.routeName,
                    arguments: {'type': 'reminder'},
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _toggleMonthView,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: Color(0xFFcfe6ed),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.yMMMM().format(
                      _selectedDate,
                    ),
                    style: semiBold.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    _showMonthView
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.secondaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the month view calendar
  Widget _buildMonthView() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.secondaryColor,
                    ),
                    onPressed: _previousMonth,
                  ),
                  Text(
                    DateFormat.yMMMM().format(
                      _selectedDate,
                    ),
                    style: semiBold.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.secondaryColor,
                    ),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children:
                    [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ]
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: medium.copyWith(
                                  fontSize: 12.sp,
                                  color:
                                      AppColors
                                          .grayTextColor,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                itemCount: _monthDays.length,
                itemBuilder: (context, index) {
                  final day = _monthDays[index];
                  final isToday = _isToday(day);
                  final isCurrentMonth = _isCurrentMonth(
                    day,
                  );
                  final isSelected =
                      day.year == _selectedDate.year &&
                      day.month == _selectedDate.month &&
                      day.day == _selectedDate.day;

                  return GestureDetector(
                    onTap: () => _selectDay(day),
                    child: Container(
                      margin: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.secondaryColor
                                : isToday
                                ? Color(0xffcfe6ed)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          day.day.toString(),
                          style: medium.copyWith(
                            fontSize: 14.sp,
                            color:
                                isSelected
                                    ? Colors.white
                                    : !isCurrentMonth
                                    ? AppColors
                                        .grayTextColor
                                        .withOpacity(0.5)
                                    : AppColors
                                        .darkTextColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  // Build the day view with time slots
  Widget _buildDayView() {
    final now = DateTime.now();
    final currentTimeHour =
        _isToday(_selectedDate)
            ? now.hour
            : -1; // To highlight current hour

    // Split items by time category
    final fullDayItems =
        _allItems
            .where(
              (item) =>
                  (item is TaskModel &&
                      item.dueDate.hour == 0 &&
                      item.dueDate.minute == 0) ||
                  (item is ReminderModel &&
                      item.dueDate.hour == 0 &&
                      item.dueDate.minute == 0),
            )
            .toList();

    final timedItems =
        _allItems
            .where(
              (item) =>
                  (item is TaskModel &&
                      (item.dueDate.hour != 0 ||
                          item.dueDate.minute != 0)) ||
                  (item is ReminderModel &&
                      (item.dueDate.hour != 0 ||
                          item.dueDate.minute != 0)),
            )
            .toList();

    return Expanded(
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        children: [
          // Selected date header
          Text(
            DateFormat(
              'EEEE, MMMM d',
            ).format(_selectedDate),
            style: semiBold.copyWith(
              fontSize: 18.sp,
              color: AppColors.darkTextColor,
            ),
          ),
          SizedBox(height: 16.h),

          // Full day items section
          if (fullDayItems.isNotEmpty) ...[
            _buildSectionHeader('Full Day'),
            ...fullDayItems.map(
              (item) => _buildItemCard(item, true),
            ),
            SizedBox(height: 16.h),
          ],

          // Time slots with items
          for (int hour = 0; hour < 24; hour++) ...[
            if (_hasItemsInHour(timedItems, hour)) ...[
              _buildTimeSlot(
                hour,
                _getItemsForHour(timedItems, hour),
                isCurrentHour: hour == currentTimeHour,
              ),
            ],
          ],
        ],
      ),
    );
  }

  // Check if there are items in a specific hour
  bool _hasItemsInHour(List<dynamic> items, int hour) {
    return items.any((item) {
      if (item is TaskModel) {
        return item.dueDate.hour == hour;
      } else if (item is ReminderModel) {
        return item.dueDate.hour == hour;
      }
      return false;
    });
  }

  // Get items for a specific hour
  List<dynamic> _getItemsForHour(
    List<dynamic> items,
    int hour,
  ) {
    return items.where((item) {
        if (item is TaskModel) {
          return item.dueDate.hour == hour;
        } else if (item is ReminderModel) {
          return item.dueDate.hour == hour;
        }
        return false;
      }).toList()
      ..sort((a, b) {
        int minutesA = 0;
        int minutesB = 0;

        if (a is TaskModel) {
          minutesA = a.dueDate.minute;
        } else if (a is ReminderModel) {
          minutesA = a.dueDate.minute;
        }

        if (b is TaskModel) {
          minutesB = b.dueDate.minute;
        } else if (b is ReminderModel) {
          minutesB = b.dueDate.minute;
        }

        return minutesA.compareTo(minutesB);
      });
  }

  // Build a section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: semiBold.copyWith(
          fontSize: 16.sp,
          color: AppColors.secondaryColor,
        ),
      ),
    );
  }

  // Build a time slot with its items
  Widget _buildTimeSlot(
    int hour,
    List<dynamic> items, {
    bool isCurrentHour = false,
  }) {
    final timeString = DateFormat(
      'h a',
    ).format(DateTime(2022, 1, 1, hour));

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 60.w,
            child: Text(
              timeString,
              style: medium.copyWith(
                fontSize: 14.sp,
                color:
                    isCurrentHour
                        ? AppColors.secondaryColor
                        : AppColors.grayTextColor,
              ),
            ),
          ),

          // Vertical line with current time indicator
          Container(
            width: 24.w,
            height:
                items.length *
                98.h, // Height based on number of items
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                // Vertical line
                Positioned(
                  top: 12.h,
                  bottom: 0,
                  left: 12.w,
                  child: Container(
                    width: 1.w,
                    color: Color(0xffe2e3e7),
                  ),
                ),

                // Circle at the top
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isCurrentHour
                              ? AppColors.secondaryColor
                              : Color(0xffe2e3e7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items column
          Expanded(
            child: Column(
              children:
                  items
                      .map(
                        (item) =>
                            _buildItemCard(item, false),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Build a card for a task or reminder
  Widget _buildItemCard(dynamic item, bool isFullDay) {
    final bool isTask = item is TaskModel;
    final String title =
        isTask
            ? (item).title
            : (item as ReminderModel).title;
    final String description =
        isTask
            ? (item).description
            : (item as ReminderModel).description;
    final DateTime dueDate =
        isTask
            ? (item).dueDate
            : (item as ReminderModel).dueDate;
    final String category =
        isTask
            ? (item).category
            : (item as ReminderModel).category;
    final bool isCompleted =
        isTask
            ? (item).isCompleted
            : (item as ReminderModel).isCompleted;

    // Format the time as a string
    final String timeString =
        isFullDay
            ? 'All Day'
            : DateFormat('h:mm a').format(dueDate);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color:
              isCompleted
                  ? Colors.green.withOpacity(0.3)
                  : Color(0xffe2e3e7),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Task/Reminder indicator
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isTask
                          ? AppColors.secondaryColor
                          : Color(0xFFf9eca7),
                ),
              ),
              SizedBox(width: 8.w),

              // Title with completion status
              Expanded(
                child: Text(
                  title,
                  style: semiBold.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.darkTextColor,
                    decoration:
                        isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Category badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFcfe6ed),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  category,
                  style: medium.copyWith(
                    fontSize: 10.sp,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Description
          if (description.isNotEmpty) ...[
            Text(
              description,
              style: regular.copyWith(
                fontSize: 12.sp,
                color: AppColors.grayTextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
          ],

          // Time
          Row(
            children: [
              SvgPicture.asset(
                'assets/svg/clock.svg',
                height: 12.h,
                width: 12.h,
                colorFilter: ColorFilter.mode(
                  AppColors.grayTextColor,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                timeString,
                style: regular.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.grayTextColor,
                ),
              ),

              Spacer(),

              // Checkbox for completion status
              GestureDetector(
                onTap: () => _toggleItemCompletion(item),
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isCompleted
                            ? Colors.green.withOpacity(0.8)
                            : Colors.transparent,
                    border: Border.all(
                      color:
                          isCompleted
                              ? Colors.green.withOpacity(
                                0.8,
                              )
                              : AppColors.grayTextColor,
                      width: 1.w,
                    ),
                  ),
                  child:
                      isCompleted
                          ? Icon(
                            Icons.check,
                            size: 10.w,
                            color: Colors.white,
                          )
                          : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Toggle completion status of an item
  void _toggleItemCompletion(dynamic item) {
    final bloc = Provider.of<MainBloc>(
      context,
      listen: false,
    );

    setState(() {
      if (item is TaskModel) {
        final updatedTask = TaskModel(
          id: item.id,
          title: item.title,
          description: item.description,
          dueDate: item.dueDate,
          category: item.category,
          createdAt: item.createdAt,
          isCompleted: !item.isCompleted,
          subtasks: item.subtasks,
        );

        // In a real app, update in Firestore
        // bloc.updateTask(updatedTask);

        // For demo, update in the _allItems list
        final index = _allItems.indexWhere(
          (i) => i is TaskModel && i.id == item.id,
        );
        if (index != -1) {
          _allItems[index] = updatedTask;
        }
      } else if (item is ReminderModel) {
        final updatedReminder = ReminderModel(
          id: item.id,
          title: item.title,
          description: item.description,
          dueDate: item.dueDate,
          category: item.category,
          createdAt: item.createdAt,
          isCompleted: !item.isCompleted,
          userId: item.userId,
        );

        // Update in Firestore via bloc
        bloc.updateReminder(updatedReminder);

        // Update in the _allItems list
        final index = _allItems.indexWhere(
          (i) => i is ReminderModel && i.id == item.id,
        );
        if (index != -1) {
          _allItems[index] = updatedReminder;
        }
      }
    });
  }
}
