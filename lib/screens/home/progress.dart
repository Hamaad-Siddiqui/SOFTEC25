import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:softec25/models/mood_model.dart';
import 'package:softec25/styles.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() =>
      _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // Fixed time range - 7 days only
  final String _timeRange = '7 days';

  // Generate dummy mood data for demonstration
  late List<MoodModel> _moodData;

  // Mood SVG asset paths
  final List<String> _moodIcons = [
    'assets/svg/moods/angry.svg',
    'assets/svg/moods/sad.svg',
    'assets/svg/moods/neutral.svg',
    'assets/svg/moods/happy.svg',
    'assets/svg/moods/excited.svg',
  ];

  // Motivational quotes for the affirmation cards
  final List<Map<String, dynamic>> _motivationalContent = [
    {
      'title': 'Daily Affirmation',
      'content':
          'I am capable of managing my emotions and finding balance in all situations.',
      'icon': 'assets/svg/moods/excited.svg',
      'color': Color(0xFFE0EBFE),
      'borderColor': Color(0xFF8597B6),
    },
    {
      'title': 'Mood Insight',
      'content':
          'Your mood has improved by 15% over the last week. Keep up the great work!',
      'icon': 'assets/svg/progress.svg',
      'color': Color(0xFFCFE6ED),
      'borderColor': Color(0xFF8597B6),
    },
  ];

  @override
  void initState() {
    super.initState();
    _generateDummyMoodData();
  }

  // Generate dummy mood data for the last 90 days
  void _generateDummyMoodData() {
    final now = DateTime.now();
    _moodData = [];

    // Generate 90 days of data
    for (int i = 90; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // Create some patterns in the mood data for visual interest
      int moodIndex;

      if (i % 10 == 0) {
        moodIndex = 4; // Excited
      } else if (i % 7 == 0) {
        moodIndex = 0; // Angry
      } else if (i % 5 == 0) {
        moodIndex = 1; // Sad
      } else if (i % 3 == 0) {
        moodIndex = 3; // Happy
      } else {
        moodIndex = 2; // Neutral
      }

      final moodType = MoodModel.getMoodTypeFromIndex(
        moodIndex,
      );

      _moodData.add(
        MoodModel(
          id: 'dummy_$i',
          mood: moodType,
          score: MoodModel.getScoreFromMoodType(moodType),
          notes:
              'Sample note for ${DateFormat('MMM d').format(date)}',
          createdAt: date,
        ),
      );
    }
  }

  // Filter mood data to show only last 7 days
  List<MoodModel> _getFilteredMoodData() {
    final now = DateTime.now();
    return _moodData
        .where(
          (mood) =>
              now.difference(mood.createdAt).inDays <= 7,
        )
        .toList();
  }

  // Get data for chart
  List<FlSpot> _getChartData() {
    final filteredData = _getFilteredMoodData();

    // Sort by date ascending
    filteredData.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );

    // Convert data to FlSpot list for the chart
    final spots = <FlSpot>[];

    for (int i = 0; i < filteredData.length; i++) {
      spots.add(
        FlSpot(
          i.toDouble(),
          filteredData[i].score.toDouble(),
        ),
      );
    }

    return spots;
  }

  // Get x-axis labels based on time range
  List<String> _getXAxisLabels() {
    final filteredData = _getFilteredMoodData();
    filteredData.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );

    final labels = <String>[];

    if (filteredData.isNotEmpty) {
      // Add first date
      labels.add(
        DateFormat(
          'E, d MMM',
        ).format(filteredData.first.createdAt),
      );

      // Add last date
      labels.add(
        DateFormat(
          'E, d MMM',
        ).format(filteredData.last.createdAt),
      );
    }

    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData();
    final xAxisLabels = _getXAxisLabels();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 45.h),
              Text(
                'Mood Progress',
                style: semiBold.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.darkTextColor,
                ),
              ),
              SizedBox(height: 15.h),
              // Mood chart in a container with rounded corners and border
              Container(
                height: 300.h, // Fixed height for the chart
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(
                    20.r,
                  ), // More rounded corners to match image
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.r),
                  child:
                      chartData.isEmpty
                          ? Center(
                            child: Text(
                              'No mood data available',
                              style: medium.copyWith(
                                fontSize: 16.sp,
                              ),
                            ),
                          )
                          : Padding(
                            padding: EdgeInsets.only(
                              top: 16.h,
                              right: 16.w,
                            ),
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: 1,
                                  verticalInterval: 1,
                                  getDrawingHorizontalLine: (
                                    value,
                                  ) {
                                    return FlLine(
                                      color:
                                          Colors.grey[200]!,
                                      strokeWidth: 1,
                                      dashArray: [
                                        5,
                                        5,
                                      ], // Make grid lines dashed
                                    );
                                  },
                                  getDrawingVerticalLine: (
                                    value,
                                  ) {
                                    return FlLine(
                                      color:
                                          Colors.grey[200]!,
                                      strokeWidth: 1,
                                      dashArray: [
                                        5,
                                        5,
                                      ], // Make grid lines dashed
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  rightTitles:
                                      const AxisTitles(
                                        sideTitles:
                                            SideTitles(
                                              showTitles:
                                                  false,
                                            ),
                                      ),
                                  topTitles:
                                      const AxisTitles(
                                        sideTitles:
                                            SideTitles(
                                              showTitles:
                                                  false,
                                            ),
                                      ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (
                                        value,
                                        meta,
                                      ) {
                                        // Show grey SVG icons for integer mood scores (1-5)
                                        if (value % 1 ==
                                                0 &&
                                            value >= 1 &&
                                            value <= 5) {
                                          // Adjust index for zero-based array
                                          final iconIndex =
                                              value
                                                  .toInt() -
                                              1;
                                          if (iconIndex >=
                                                  0 &&
                                              iconIndex <
                                                  _moodIcons
                                                      .length) {
                                            return SideTitleWidget(
                                              axisSide:
                                                  meta.axisSide,
                                              child: ColorFiltered(
                                                colorFilter: const ColorFilter.mode(
                                                  AppColors
                                                      .darkTextColor,
                                                  BlendMode
                                                      .srcIn,
                                                ),
                                                child: SvgPicture.asset(
                                                  _moodIcons[iconIndex],
                                                  width:
                                                      20.w,
                                                  height:
                                                      20.h,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (
                                        value,
                                        meta,
                                      ) {
                                        // Show only first and last date
                                        if (xAxisLabels
                                            .isNotEmpty) {
                                          if (value == 0 ||
                                              value ==
                                                  chartData
                                                          .length -
                                                      1) {
                                            return Padding(
                                              padding:
                                                  EdgeInsets.only(
                                                    top:
                                                        8.h,
                                                  ),
                                              child: Text(
                                                value == 0
                                                    ? xAxisLabels
                                                        .first
                                                    : xAxisLabels
                                                        .last,
                                                style: TextStyle(
                                                  fontSize:
                                                      14.sp, // Larger font size like in image
                                                  fontWeight:
                                                      FontWeight
                                                          .w400,
                                                  color:
                                                      Colors
                                                          .grey[600],
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                        return const SizedBox.shrink();
                                      },
                                      reservedSize:
                                          40, // Give more space to date text
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show:
                                      false, // No border inside the chart
                                ),
                                minX: 0,
                                maxX:
                                    chartData.length
                                        .toDouble() -
                                    1,
                                minY: 0,
                                maxY: 6,
                                lineTouchData: LineTouchData(
                                  enabled:
                                      false, // Disable touch interactions
                                ),
                                backgroundColor: const Color(
                                  0xFFF0F4FF,
                                ).withOpacity(
                                  0.3,
                                ), // Light blue background like in image
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: chartData,
                                    isCurved: true,
                                    color: const Color(
                                      0xFF4285F4,
                                    ), // Google blue color
                                    barWidth:
                                        4, // Thicker line as in image
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show:
                                          false, // No dots on the line in the reference image
                                    ),
                                    belowBarData: BarAreaData(
                                      show:
                                          true, // Show area below the line
                                      color: const Color(
                                        0xFF4285F4,
                                      ).withOpacity(
                                        0.15,
                                      ), // Light blue fill
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                ),
              ),

              SizedBox(height: 24.h),

              // Mood summary title
              Text(
                'Mood Insights',
                style: semiBold.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.darkTextColor,
                ),
              ),

              SizedBox(height: 16.h),

              // Motivational Cards
              ..._motivationalContent.map((content) {
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: content['color'].withOpacity(
                      0.85,
                    ),
                    borderRadius: BorderRadius.circular(
                      16.r,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.03,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40.h,
                          width: 40.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              content['icon'],
                              height: 24.h,
                              width: 24.h,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                content['title'],
                                style: semiBold.copyWith(
                                  fontSize: 18.sp,
                                  color:
                                      AppColors
                                          .secondaryColor,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                content['content'],
                                style: medium.copyWith(
                                  fontSize: 15.sp,
                                  color: AppColors
                                      .secondaryColor
                                      .withOpacity(0.8),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Weekly Mood Pattern Card
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Color(
                    0xFFf9eca7,
                  ).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16.r),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40.h,
                            width: 40.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/svg/calendar.svg',
                                height: 24.h,
                                width: 24.h,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Text(
                            'Weekly Pattern',
                            style: semiBold.copyWith(
                              fontSize: 18.sp,
                              color:
                                  AppColors.darkTextColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [
                          _buildDayMoodIndicator(
                            'M',
                            _moodIcons[3],
                          ), // Happy
                          _buildDayMoodIndicator(
                            'T',
                            _moodIcons[2],
                          ), // Neutral
                          _buildDayMoodIndicator(
                            'W',
                            _moodIcons[2],
                          ), // Neutral
                          _buildDayMoodIndicator(
                            'T',
                            _moodIcons[3],
                          ), // Happy
                          _buildDayMoodIndicator(
                            'F',
                            _moodIcons[4],
                          ), // Excited
                          _buildDayMoodIndicator(
                            'S',
                            _moodIcons[3],
                          ), // Happy
                          _buildDayMoodIndicator(
                            'S',
                            _moodIcons[2],
                          ), // Neutral
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Your mood tends to improve towards the end of the week. Consider planning rewarding activities for those days.',
                        style: regular.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.darkTextColor
                              .withOpacity(0.8),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayMoodIndicator(
    String day,
    String moodIcon,
  ) {
    return Column(
      children: [
        Text(
          day,
          style: semiBold.copyWith(
            fontSize: 14.sp,
            color: AppColors.darkTextColor,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 36.h,
          width: 36.h,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              moodIcon,
              height: 20.h,
              width: 20.h,
            ),
          ),
        ),
      ],
    );
  }
}
