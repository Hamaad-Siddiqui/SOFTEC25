import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:softec25/bloc/main_bloc.dart';
import 'package:softec25/models/task_model.dart';
import 'package:softec25/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final now = DateTime.now();
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Create dummy tasks for different days
  late List<TaskModel> allTasks;
  // Filtered tasks for the selected date
  late List<TaskModel> filteredTasks;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for date selection
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Set today as the selected date
    _selectedDate = DateTime.now();

    // Generate week dates (3 days before today + today + 3 days after)
    _generateWeekDates();

    // Initialize dummy tasks with SubTaskModel objects for different days
    _initializeDummyTasks();

    // Filter tasks for the selected date (initially today)
    _filterTasksByDate();
  }

  // Initialize tasks for different days
  void _initializeDummyTasks() {
    final now = DateTime.now();

    allTasks = [
      // Today's tasks
      TaskModel(
        id: '1',
        title: 'Email back Mrs James',
        description:
            'For the new intern we have next week from Alex Carter, a marketing student from Brookfield University. Confirm their arrival time and make sure the orientation package is prepared. Also, check if they need any accommodation assistance during their stay.',
        dueDate: DateTime(
          now.year,
          now.month,
          now.day,
          now.hour + 2,
        ),
        category: 'Academics',
        createdAt: DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 1)),
        subtasks: [
          SubTaskModel(task: 'Review email contents'),
          SubTaskModel(task: 'Check attachments'),
        ],
      ),
      TaskModel(
        id: '2',
        title: 'Check project report',
        description:
            'Review the quarterly report before sending it to the department. Make sure all figures are accurate and up to date.',
        dueDate: DateTime(
          now.year,
          now.month,
          now.day,
          now.hour + 4,
        ),
        category: 'Work',
        createdAt: DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: '3',
        title: 'Schedule team meeting',
        description:
            'Set up the weekly progress meeting with the development team. Prepare agenda and send calendar invites to all team members.',
        dueDate: DateTime(
          now.year,
          now.month,
          now.day,
          now.hour + 6,
        ),
        category: 'Academics',
        createdAt: DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 1)),
        subtasks: [
          SubTaskModel(task: 'Create meeting agenda'),
          SubTaskModel(task: 'Book conference room'),
          SubTaskModel(task: 'Send calendar invites'),
        ],
      ),

      // Tomorrow's tasks
      TaskModel(
        id: '4',
        title: 'Doctor Appointment',
        description:
            'Annual checkup at Dr. Smith\'s clinic. Bring health insurance card and list of current medications.',
        dueDate: DateTime(
          now.year,
          now.month,
          now.day + 1,
          10,
          30,
        ),
        category: 'Personal',
        createdAt: DateTime(
          now.year,
          now.month,
          now.day - 2,
        ),
        subtasks: [
          SubTaskModel(task: 'Prepare medication list'),
          SubTaskModel(
            task: 'Collect previous medical reports',
          ),
        ],
      ),
      TaskModel(
        id: '5',
        title: 'Project Presentation',
        description:
            'Present the new feature implementation to the stakeholders. Include performance metrics and user feedback.',
        dueDate: DateTime(
          now.year,
          now.month,
          now.day + 1,
          14,
          0,
        ),
        category: 'Work',
        createdAt: DateTime(
          now.year,
          now.month,
          now.day - 1,
        ),
        subtasks: [
          SubTaskModel(task: 'Finalize slides'),
          SubTaskModel(task: 'Practice presentation'),
          SubTaskModel(task: 'Prepare for Q&A'),
        ],
      ),

      // Yesterday's tasks
      TaskModel(
        id: '6',
        title: 'Gym Workout',
        description:
            'Cardio and strength training session at Fitness First. Focus on upper body and core exercises.',
        dueDate: DateTime(
          now.year,
          now.month,
          now.day - 1,
          18,
          0,
        ),
        category: 'Health',
        createdAt: DateTime(
          now.year,
          now.month,
          now.day - 2,
        ),
        isCompleted: true,
      ),
      TaskModel(
        id: '7',
        title: 'Grocery Shopping',
        description:
            'Pick up essentials from Whole Foods. Don\'t forget milk, eggs, bread, and fresh vegetables.',
        dueDate: DateTime(
          now.year,
          now.month,
          now.day - 1,
          20,
          0,
        ),
        category: 'Personal',
        createdAt: DateTime(
          now.year,
          now.month,
          now.day - 2,
        ),
        isCompleted: true,
        subtasks: [
          SubTaskModel(
            task: 'Check pantry inventory',
            isCompleted: true,
          ),
          SubTaskModel(
            task: 'Make shopping list',
            isCompleted: true,
          ),
          SubTaskModel(
            task: 'Check for discounts',
            isCompleted: true,
          ),
        ],
      ),

      // Two days ago
      TaskModel(
        id: '8',
        title: 'Code Review',
        description:
            'Review pull request #342 from the development team. Focus on performance optimizations and code quality.',
        dueDate: DateTime(
          now.year,
          now.month,
          now.day - 2,
          15,
          0,
        ),
        category: 'Work',
        createdAt: DateTime(
          now.year,
          now.month,
          now.day - 3,
        ),
        isCompleted: true,
      ),

      // Day after tomorrow
      TaskModel(
        id: '9',
        title: 'Team Lunch',
        description:
            'Monthly team bonding lunch at Italian Bistro. Reservation made for 12:30 PM, confirm attendance with all team members.',
        dueDate: DateTime(
          now.year,
          now.month,
          now.day + 2,
          12,
          30,
        ),
        category: 'Social',
        createdAt: DateTime(now.year, now.month, now.day),
        subtasks: [
          SubTaskModel(task: 'Confirm reservation'),
          SubTaskModel(task: 'Send reminder to team'),
        ],
      ),
      TaskModel(
        id: '10',
        title: 'Contract Review',
        description:
            'Review and sign the new client contract. Check payment terms and delivery timeline before signing.',
        dueDate: DateTime(
          now.year,
          now.month,
          now.day + 2,
          16,
          0,
        ),
        category: 'Work',
        createdAt: DateTime(now.year, now.month, now.day),
      ),

      // Three days from now
      TaskModel(
        id: '11',
        title: 'Website Update',
        description:
            'Deploy the new homepage design and test all functionalities. Make sure all links are working and analytics is properly set up.',
        dueDate: DateTime(
          now.year,
          now.month,
          now.day + 3,
          11,
        ),
        category: 'Work',
        createdAt: DateTime(now.year, now.month, now.day),
        subtasks: [
          SubTaskModel(task: 'Final design review'),
          SubTaskModel(task: 'Cross-browser testing'),
          SubTaskModel(task: 'Mobile responsiveness check'),
        ],
      ),
    ];
  }

  void _generateWeekDates() {
    final now = DateTime.now();
    _weekDates = List.generate(
      7,
      (index) => DateTime(
        now.year,
        now.month,
        now.day - 3 + index,
      ),
    );
  }

  // Filter tasks based on the selected date and sort by completion status
  void _filterTasksByDate() {
    // Get all tasks for the selected date
    List<TaskModel> tasksForDate =
        allTasks.where((task) {
          return task.dueDate.year == _selectedDate.year &&
              task.dueDate.month == _selectedDate.month &&
              task.dueDate.day == _selectedDate.day;
        }).toList();

    // Sort tasks - incomplete tasks first, then completed tasks
    tasksForDate.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        // If completion status is the same, sort by due date (earlier first)
        return a.dueDate.compareTo(b.dueDate);
      }
      // Otherwise, incomplete tasks first
      return a.isCompleted ? 1 : -1;
    });

    // Store all tasks but only count uncompleted ones for the counter
    filteredTasks = tasksForDate;
  }

  // Check if a date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if a date is selected
  bool _isSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  // Handle date selection
  void _selectDate(DateTime date) {
    if (_isSelected(date)) return;

    setState(() {
      _selectedDate = date;
      _animationController.reset();
      _animationController.forward();

      // Filter tasks based on the newly selected date
      _filterTasksByDate();
    });
  }

  // Get color for date card based on date status
  Color _getDateColor(DateTime date, bool isSelected) {
    // Return secondary color for selected date
    if (isSelected) {
      return AppColors.secondaryColor;
    }

    // For today, use the existing light blue
    if (_isToday(date)) {
      return Color(0xFFE0EBFE).withOpacity(0.5);
    }

    // For past dates
    if (date.isBefore(
      DateTime(now.year, now.month, now.day),
    )) {
      // Get tasks for this date
      List<TaskModel> dateTasksCheck =
          allTasks.where((task) {
            return task.dueDate.year == date.year &&
                task.dueDate.month == date.month &&
                task.dueDate.day == date.day;
          }).toList();

      // No tasks for this date, use light gray
      if (dateTasksCheck.isEmpty) {
        return Color(0xFFE8E8E8).withOpacity(
          0.5,
        ); // Light gray for past dates with no tasks
      }

      // Check if all tasks were completed
      bool allCompleted = dateTasksCheck.every(
        (task) => task.isCompleted,
      );
      // Check if all tasks were incomplete
      bool noneCompleted = dateTasksCheck.every(
        (task) => !task.isCompleted,
      );

      if (allCompleted) {
        return Color(0xFFD1F5D3).withOpacity(
          0.5,
        ); // Light green for completed tasks
      } else if (noneCompleted) {
        return Color(0xFFF5D1D1).withOpacity(
          0.5,
        ); // Light red for incomplete tasks
      } else {
        return Color(0xFFF5EFD1).withOpacity(
          0.5,
        ); // Light yellow for mixed completion
      }
    }

    // For future dates, return transparent (will be handled by the border)
    return Colors.transparent;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height:
                      ScreenUtil().statusBarHeight + 40.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                  ),
                  child: Row(
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
                            '${bloc.user!.fullName} ! 👋 ',
                            style: regular.copyWith(
                              fontSize: 14.sp,
                              color:
                                  AppColors.grayTextColor,
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
                ),

                SizedBox(height: 30.h),

                // Progress Card
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                  ),
                  child: ProgressCard(
                    allTasks: allTasks,
                    selectedDate: _selectedDate,
                  ),
                ),

                // Date Selector Calendar
                Container(
                  height: 86.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      12.r,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.05,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _weekDates.length,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                    ),
                    itemBuilder: (context, index) {
                      final date = _weekDates[index];
                      final isSelected = _isSelected(date);
                      final isToday = _isToday(date);

                      return GestureDetector(
                        onTap: () => _selectDate(date),
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            final animatedScale =
                                isSelected
                                    ? Tween<double>(
                                      begin: 1.0,
                                      end: 1.05,
                                    ).evaluate(_animation)
                                    : 1.0;

                            return Transform.scale(
                              scale: animatedScale,
                              child: Container(
                                width: 48.w,
                                margin:
                                    EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 10.h,
                                    ),
                                decoration: BoxDecoration(
                                  color: _getDateColor(
                                    date,
                                    isSelected,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                        12.r,
                                      ),
                                  border:
                                      !isSelected &&
                                              !isToday
                                          ? Border.all(
                                            color: Colors
                                                .grey
                                                .withOpacity(
                                                  0.2,
                                                ),
                                            width: 1,
                                          )
                                          : null,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Text(
                                      DateFormat('EEE')
                                          .format(date)
                                          .substring(0, 3),
                                      style: medium.copyWith(
                                        fontSize: 12.sp,
                                        color:
                                            isSelected
                                                ? Colors
                                                    .white
                                                : AppColors
                                                    .secondaryColor
                                                    .withOpacity(
                                                      0.8,
                                                    ),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      date.day.toString(),
                                      style: semiBold.copyWith(
                                        fontSize: 16.sp,
                                        color:
                                            isSelected
                                                ? Colors
                                                    .white
                                                : AppColors
                                                    .secondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: 14.h,
                      left: 14.w,
                      right: 14.w,
                      bottom: 28.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(
                        0xFFE0EBFE,
                      ).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(
                        12.r,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/calendar2.svg',
                              height: 15.h,
                              width: 15.w,
                              colorFilter: ColorFilter.mode(
                                AppColors.secondaryColor
                                    .withOpacity(0.9),
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              DateFormat(
                                'EEEE, d\'th\' MMMM',
                              ).format(_selectedDate),
                              style: medium.copyWith(
                                height: 1,
                                fontSize: 13.sp,
                                color: AppColors
                                    .secondaryColor
                                    .withOpacity(0.9),
                              ),
                            ),
                            Spacer(),
                            // Icon(
                            //   Icons.chevron_right,
                            //   size: 18.w,
                            //   color: AppColors.secondaryColor
                            //       .withOpacity(0.9),
                            // ),
                          ],
                        ),
                        SizedBox(height: 17.h),
                        Text(
                          'You ${_selectedDate.isBefore(DateTime(now.year, now.month, now.day)) ? 'had' : 'have'} ${filteredTasks.where((task) => !task.isCompleted).length}\ntasks left ${_isToday(_selectedDate) ? 'for today' : 'for ${DateFormat('EEEE').format(_selectedDate)}'}',
                          style: semiBold.copyWith(
                            fontSize: 18.sp,
                            color: AppColors.secondaryColor
                                .withOpacity(0.9),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 17.h),

                        // Tasks List
                        ...filteredTasks.map(
                          (task) => TaskCard(
                            task: task,
                            isLast:
                                task == filteredTasks.last,
                            onTaskStatusChanged: (
                              isCompleted,
                              updatedSubtasks,
                            ) {
                              setState(() {
                                final index = allTasks
                                    .indexWhere(
                                      (t) =>
                                          t.id == task.id,
                                    );
                                if (index != -1) {
                                  final updatedTask = task
                                      .copyWith(
                                        isCompleted:
                                            isCompleted,
                                        subtasks:
                                            updatedSubtasks,
                                      );
                                  allTasks[index] =
                                      updatedTask;
                                }
                                _filterTasksByDate();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final bool isLast;
  final Function(bool, List<SubTaskModel>)
  onTaskStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    this.isLast = false,
    required this.onTaskStatusChanged,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late List<SubTaskModel> _subtasks;
  late AnimationController _animationController;

  // Check if description is too long and needs expanding
  bool get _hasLongDescription {
    // This checks if the description is longer than what can fit in 2 lines
    return widget.task.description.length > 100;
  }

  // Check if we need to show the arrow (for long text or subtasks)
  bool get _shouldShowArrow {
    return _hasLongDescription ||
        widget.task.subtasks.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _subtasks = List.from(widget.task.subtasks);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task != widget.task) {
      _subtasks = List.from(widget.task.subtasks);
    }
  }

  // Handle task completion without animation or expansion
  void _handleTaskCompletion(bool isCompleted) {
    // If task is marked complete, automatically mark all subtasks as complete
    if (isCompleted) {
      final updatedSubtasks =
          _subtasks
              .map(
                (subtask) => SubTaskModel(
                  task: subtask.task,
                  isCompleted: true,
                ),
              )
              .toList();

      // Update without animation and collapse if expanded
      if (_expanded) {
        setState(() {
          _expanded = false;
          _animationController.reverse();
        });
      }

      widget.onTaskStatusChanged(true, updatedSubtasks);
      setState(() {
        _subtasks = updatedSubtasks;
      });
    } else {
      widget.onTaskStatusChanged(false, _subtasks);
    }
  }

  void _handleSubtaskCompletion(
    int index,
    bool isCompleted,
  ) {
    setState(() {
      final updatedSubtasks = List<SubTaskModel>.from(
        _subtasks,
      );
      updatedSubtasks[index] = SubTaskModel(
        task: _subtasks[index].task,
        isCompleted: isCompleted,
      );
      _subtasks = updatedSubtasks;
      widget.onTaskStatusChanged(
        widget.task.isCompleted,
        updatedSubtasks,
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: widget.isLast ? 0 : 15.h,
      ),
      decoration: BoxDecoration(
        color: Color(
          0xFFE0EBFE,
        ).withOpacity(0.85), // Same as parent container
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(0xFF8597B6).withOpacity(0.5),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Checkmark for task
                    GestureDetector(
                      onTap: () {
                        _handleTaskCompletion(
                          !widget.task.isCompleted,
                        );
                      },
                      child: Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              widget.task.isCompleted
                                  ? AppColors.secondaryColor
                                      .withOpacity(0.9)
                                  : Colors.transparent,
                          border: Border.all(
                            color: AppColors.secondaryColor
                                .withOpacity(0.9),
                            width: 1,
                          ),
                        ),
                        child:
                            widget.task.isCompleted
                                ? Icon(
                                  Icons.check,
                                  size: 10.w,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      widget.task.title,
                      style: medium.copyWith(
                        fontSize: 15.sp,
                        color: AppColors.secondaryColor,
                        decoration:
                            widget.task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                      ),
                    ),
                    Spacer(),
                    // Show arrow icon for tasks with subtasks or long descriptions
                    if (_shouldShowArrow)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _expanded = !_expanded;
                            if (_expanded) {
                              _animationController
                                  .forward();
                            } else {
                              _animationController
                                  .reverse();
                            }
                          });
                        },
                        child: RotationTransition(
                          turns: Tween(
                            begin: 0.0,
                            end: 0.5,
                          ).animate(_animationController),
                          child: SvgPicture.asset(
                            'assets/svg/arrow_down.svg',
                            height: 8.w,
                            width: 8.w,
                            colorFilter: ColorFilter.mode(
                              AppColors.secondaryColor
                                  .withOpacity(0.9),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 7.h),
                Padding(
                  padding: EdgeInsets.only(left: 22.w),
                  child: Text(
                    widget.task.description,
                    style: regular.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.secondaryColor
                          .withOpacity(0.7),
                      height: 1.2,
                      decoration:
                          widget.task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                    maxLines: _expanded ? null : 2,
                    overflow:
                        _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                  ),
                ),

                // Show subtasks if expanded and subtasks exist
                if (_expanded && _subtasks.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  // Subtasks
                  ..._subtasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final subtask = entry.value;

                    return Padding(
                      padding: EdgeInsets.only(
                        left: 22.w,
                        top: 4.h,
                        bottom: 4.h,
                      ),
                      child: Row(
                        children: [
                          // Checkmark for subtask
                          GestureDetector(
                            onTap: () {
                              if (!widget
                                  .task
                                  .isCompleted) {
                                _handleSubtaskCompletion(
                                  index,
                                  !subtask.isCompleted,
                                );
                              }
                            },
                            child: Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    subtask.isCompleted
                                        ? AppColors
                                            .secondaryColor
                                            .withOpacity(
                                              0.9,
                                            )
                                        : Colors
                                            .transparent,
                                border: Border.all(
                                  color: AppColors
                                      .secondaryColor
                                      .withOpacity(0.9),
                                  width: 0.8,
                                ),
                              ),
                              child:
                                  subtask.isCompleted
                                      ? Icon(
                                        Icons.check,
                                        size: 8.w,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            subtask.task,
                            style: regular.copyWith(
                              fontSize: 14.sp,
                              color: AppColors
                                  .secondaryColor
                                  .withOpacity(0.7),
                              decoration:
                                  subtask.isCompleted
                                      ? TextDecoration
                                          .lineThrough
                                      : TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                SizedBox(height: 10.h),
                Row(
                  children: [
                    SizedBox(width: 22.w),
                    SvgPicture.asset(
                      'assets/svg/clock.svg',
                      height: 14.h,
                      width: 14.w,
                      colorFilter: ColorFilter.mode(
                        AppColors.secondaryColor
                            .withOpacity(0.8),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      DateFormat(
                        'h:mm a',
                      ).format(widget.task.dueDate),
                      style: medium.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.secondaryColor
                            .withOpacity(0.8),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(
                          0xFF9EC2FF,
                        ).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(
                          6.r,
                        ),
                      ),
                      child: Text(
                        widget.task.category,
                        style: medium.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressCard extends StatefulWidget {
  final List<TaskModel> allTasks;
  final DateTime selectedDate;

  const ProgressCard({
    super.key,
    required this.allTasks,
    required this.selectedDate,
  });

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  bool _isDailySelected = true;

  // Calculate daily progress based on today's tasks and subtasks
  double calculateDailyProgress() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get today's tasks
    final todayTasks =
        widget.allTasks
            .where(
              (task) =>
                  task.dueDate.year == today.year &&
                  task.dueDate.month == today.month &&
                  task.dueDate.day == today.day,
            )
            .toList();

    if (todayTasks.isEmpty) return 0.0;

    // Count total tasks and subtasks
    int totalTasks = todayTasks.length;
    int totalSubtasks = todayTasks.fold(
      0,
      (sum, task) => sum + task.subtasks.length,
    );
    int totalItems = totalTasks + totalSubtasks;

    if (totalItems == 0) return 0.0;

    // Count completed tasks and subtasks
    int completedTasks =
        todayTasks.where((task) => task.isCompleted).length;
    int completedSubtasks = todayTasks.fold(
      0,
      (sum, task) =>
          sum +
          task.subtasks
              .where((subtask) => subtask.isCompleted)
              .length,
    );
    int completedItems = completedTasks + completedSubtasks;

    return (completedItems / totalItems) * 100;
  }

  // Calculate weekly progress based on this week's tasks and subtasks
  double calculateWeeklyProgress() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate the start of the week (Monday)
    final int weekday = now.weekday;
    final startOfWeek = today.subtract(
      Duration(days: weekday - 1),
    );
    final endOfWeek = startOfWeek.add(
      Duration(days: 6),
    ); // Sunday

    // Get this week's tasks
    final weekTasks =
        widget.allTasks
            .where(
              (task) =>
                  task.dueDate.isAfter(
                    startOfWeek.subtract(Duration(days: 1)),
                  ) &&
                  task.dueDate.isBefore(
                    endOfWeek.add(Duration(days: 1)),
                  ),
            )
            .toList();

    if (weekTasks.isEmpty) return 0.0;

    // Count total tasks and subtasks
    int totalTasks = weekTasks.length;
    int totalSubtasks = weekTasks.fold(
      0,
      (sum, task) => sum + task.subtasks.length,
    );
    int totalItems = totalTasks + totalSubtasks;

    if (totalItems == 0) return 0.0;

    // Count completed tasks and subtasks
    int completedTasks =
        weekTasks.where((task) => task.isCompleted).length;
    int completedSubtasks = weekTasks.fold(
      0,
      (sum, task) =>
          sum +
          task.subtasks
              .where((subtask) => subtask.isCompleted)
              .length,
    );
    int completedItems = completedTasks + completedSubtasks;

    return (completedItems / totalItems) * 100;
  }

  String getMood(double progress) {
    if (progress >= 75) {
      return "excited";
    } else if (progress >= 35) {
      return "happy";
    } else {
      return "smile";
    }
  }

  String getProgressMessage(double progress) {
    if (progress >= 75) {
      return "You are doing\nwell ";
    } else if (progress >= 50) {
      return "You are on\ntrack ";
    } else if (progress >= 25) {
      return "Keep up the\neffort ";
    } else {
      return "Let's get\nstarted ";
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        _isDailySelected
            ? calculateDailyProgress()
            : calculateWeeklyProgress();

    final progressRounded = progress.round();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0xFFCFE6ED).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle switch between Daily and Weekly
          SizedBox(
            // alignment: Alignment.centerRight,
            child: Row(
              children: [
                Container(
                  height: 34.h,
                  width: 34.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/svg/line.svg',
                      height: 20.h,
                      width: 20.h,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  height: 34.h,
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(
                      24.r,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Daily Toggle
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDailySelected = true;
                          });
                        },
                        child: Container(
                          width: 100.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color:
                                _isDailySelected
                                    ? Colors.white
                                        .withOpacity(0.9)
                                    : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(24.r),
                          ),
                          child: Center(
                            child: Text(
                              'Daily',
                              style: medium.copyWith(
                                fontSize: 14.sp,
                                color:
                                    _isDailySelected
                                        ? Colors.black
                                        : Colors.black
                                            .withOpacity(
                                              0.7,
                                            ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Weekly Toggle
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDailySelected = false;
                          });
                        },
                        child: Container(
                          width: 100.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color:
                                !_isDailySelected
                                    ? Colors.black
                                    : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(24.r),
                          ),
                          child: Center(
                            child: Text(
                              'Weekly',
                              style: medium.copyWith(
                                fontSize: 14.sp,
                                color:
                                    !_isDailySelected
                                        ? Colors.white
                                        : Colors.black
                                            .withOpacity(
                                              0.7,
                                            ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Your progress title
          Text(
            'Your progress',
            style: medium.copyWith(
              fontSize: 16.sp,
              color: Colors.black.withOpacity(0.8),
            ),
          ),

          SizedBox(height: 4.h),

          // Progress status and percentage
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Progress message with emoji
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    getProgressMessage(
                      progress,
                    ).split('\n')[0],
                    style: semiBold.copyWith(
                      fontSize: 22.sp,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      Text(
                        getProgressMessage(
                          progress,
                        ).split('\n')[1],
                        style: semiBold.copyWith(
                          fontSize: 22.sp,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      SvgPicture.asset(
                        'assets/svg/${getMood(progress)}.svg',
                        height: 26.h,
                        width: 26.h,
                      ),
                    ],
                  ),
                ],
              ),

              // Percentage
              Text(
                '$progressRounded%',
                style: semiBold.copyWith(
                  fontSize: 42.sp,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
