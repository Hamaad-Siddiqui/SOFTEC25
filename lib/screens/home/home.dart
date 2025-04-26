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

  // Create dummy tasks
  late List<TaskModel> tasks;

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

    // Initialize dummy tasks with SubTaskModel objects
    tasks = [
      TaskModel(
        id: '1',
        title: 'Email back Mrs James',
        description:
            'For the new intern we have next week from Alex Carter, a marketing student from Brookfield University. Confirm their arrival time and make sure the orientation package is prepared. Also, check if they need any accommodation assistance during their stay.',
        dueDate: DateTime.now().add(
          const Duration(hours: 2),
        ),
        category: 'Academics',
        createdAt: DateTime.now().subtract(
          const Duration(days: 1),
        ),
        subtasks: [
          SubTaskModel(task: 'Review email contents'),
          SubTaskModel(task: 'Check attachments'),
        ],
      ),
      TaskModel(
        id: '2',
        title: 'Email back Mrs James',
        description:
            'For the new intern we have next week from Alex Carter, a marketing student from Brookfield University. Confirm their arrival time and ensure all documents are properly prepared.',
        dueDate: DateTime.now().add(
          const Duration(hours: 4),
        ),
        category: 'Academics',
        createdAt: DateTime.now().subtract(
          const Duration(days: 1),
        ),
      ),
      TaskModel(
        id: '3',
        title: 'Email back Mrs James',
        description:
            'For the new intern we have next week from Alex Carter, a marketing student from Brookfield University. Confirm their arrival and coordinate with department heads for introductions.',
        dueDate: DateTime.now().add(
          const Duration(hours: 6),
        ),
        category: 'Academics',
        createdAt: DateTime.now().subtract(
          const Duration(days: 1),
        ),
        subtasks: [
          SubTaskModel(task: 'Check intern details'),
          SubTaskModel(task: 'Verify documentation'),
          SubTaskModel(task: 'Schedule orientation'),
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
    });

    // Here you would typically filter tasks based on the selected date
    // For this demo, we'll just keep the same tasks
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
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height:
                      ScreenUtil().statusBarHeight + 40.h,
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
                          '${bloc.user!.fullName} ! 👋 ',
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

                SizedBox(height: 30.h),

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
                                  color:
                                      isSelected
                                          ? AppColors
                                              .secondaryColor
                                          : (isToday
                                              ? Color(
                                                0xFFE0EBFE,
                                              ).withOpacity(
                                                0.5,
                                              )
                                              : Colors
                                                  .transparent),
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

                Container(
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
                            height: 14.h,
                            width: 14.w,
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
                              fontSize: 12.sp,
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
                        'You have ${tasks.length}\ntasks left for today',
                        style: semiBold.copyWith(
                          fontSize: 18.sp,
                          color: AppColors.secondaryColor
                              .withOpacity(0.9),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 17.h),

                      // Tasks List
                      ...tasks
                          .map(
                            (task) => TaskCard(
                              task: task,
                              isLast: task == tasks.last,
                              onTaskStatusChanged: (
                                isCompleted,
                                updatedSubtasks,
                              ) {
                                setState(() {
                                  final index = tasks
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
                                    tasks[index] =
                                        updatedTask;
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ],
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
                        fontSize: 12.sp,
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
                      fontSize: 11.sp,
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
                              fontSize: 10.sp,
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
                  }).toList(),
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
                      '${DateFormat('h:mm a').format(widget.task.dueDate)}',
                      style: medium.copyWith(
                        fontSize: 10.sp,
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
                          fontSize: 10.sp,
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
