import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:softec25/bloc/main_bloc.dart';
import 'package:softec25/models/mood_model.dart';
import 'package:softec25/styles.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() =>
      _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // Fixed time range - 7 days only
  final String _timeRange = '7 days';

  // Stream for mood data from Firestore
  late Stream<QuerySnapshot<Map<String, dynamic>>>
  _moodsStream;

  // List to store mood data
  List<MoodModel> _moodData = [];

  // Today's mood affirmation
  String? _todayAffirmation;

  // Mood SVG asset paths
  final List<String> _moodIcons = [
    'assets/svg/moods/angry.svg',
    'assets/svg/moods/sad.svg',
    'assets/svg/moods/neutral.svg',
    'assets/svg/moods/happy.svg',
    'assets/svg/moods/excited.svg',
  ];

  @override
  void initState() {
    super.initState();
    _initMoodsStream();
  }

  // Initialize stream to fetch mood data from Firestore
  void _initMoodsStream() {
    final mainBloc = context.read<MainBloc>();
    final userId = mainBloc.user!.uid;

    // Create a stream to fetch moods from the current user's moods collection
    _moodsStream =
        mainBloc.db
            .collection('users')
            .doc(userId)
            .collection('moods')
            .orderBy('createdAt', descending: true)
            .snapshots();
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>
      >(
        stream: _moodsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading mood data: ${snapshot.error}',
                style: medium.copyWith(fontSize: 16.sp),
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.secondaryColor,
                ),
              ),
            );
          }

          // Convert snapshot to list of MoodModel objects
          _moodData =
              snapshot.data?.docs.map((doc) {
                return MoodModel.fromMap(
                  doc.data(),
                  doc.id,
                );
              }).toList() ??
              [];

          // Process today's mood for affirmation
          final now = DateTime.now();
          final today = DateTime(
            now.year,
            now.month,
            now.day,
          );
          final todayMood = _moodData.firstWhere(
            (mood) =>
                mood.createdAt.year == today.year &&
                mood.createdAt.month == today.month &&
                mood.createdAt.day == today.day,
            orElse:
                () => MoodModel(
                  id: '',
                  mood: MoodType.neutral,
                  score: 3,
                  createdAt: DateTime.now(),
                ),
          );

          // Get today's affirmation if available
          _todayAffirmation =
              todayMood.id.isNotEmpty
                  ? todayMood.affirmation
                  : null;

          final chartData = _getChartData();
          final xAxisLabels = _getXAxisLabels();

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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

                  // Affirmation card (if available)
                  if (_todayAffirmation != null &&
                      _todayAffirmation!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFE0EBFE,
                        ).withOpacity(0.85),
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
                                      'assets/svg/moods/${_getMoodSvgName(todayMood.mood)}',
                                      height: 24.h,
                                      width: 24.h,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Text(
                                  'Today\'s Affirmation',
                                  style: semiBold.copyWith(
                                    fontSize: 18.sp,
                                    color:
                                        AppColors
                                            .secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              '"${_todayAffirmation!}"',
                              style: medium.copyWith(
                                fontSize: 16.sp,
                                fontStyle: FontStyle.italic,
                                color: AppColors
                                    .secondaryColor
                                    .withOpacity(0.8),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Mood chart in a container with rounded corners and border
                  Container(
                    height:
                        300.h, // Fixed height for the chart
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
                      borderRadius: BorderRadius.circular(
                        25.r,
                      ),
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
                                      drawVerticalLine:
                                          true,
                                      horizontalInterval: 1,
                                      verticalInterval: 1,
                                      getDrawingHorizontalLine: (
                                        value,
                                      ) {
                                        return FlLine(
                                          color:
                                              Colors
                                                  .grey[200]!,
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
                                              Colors
                                                  .grey[200]!,
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
                                                value >=
                                                    1 &&
                                                value <=
                                                    5) {
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
                                              if (value ==
                                                      0 ||
                                                  value ==
                                                      chartData.length -
                                                          1) {
                                                return Padding(
                                                  padding:
                                                      EdgeInsets.only(
                                                        top:
                                                            8.h,
                                                      ),
                                                  child: Text(
                                                    value ==
                                                            0
                                                        ? xAxisLabels.first
                                                        : xAxisLabels.last,
                                                    style: TextStyle(
                                                      fontSize:
                                                          14.sp, // Larger font size like in image
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          Colors.grey[600],
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
                                    lineTouchData:
                                        LineTouchData(
                                          enabled:
                                              false, // Disable touch interactions
                                        ),
                                    backgroundColor:
                                        const Color(
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
                                        isStrokeCapRound:
                                            true,
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

                  // Weekly summary based on real data
                  _buildWeeklySummary(),

                  // ...rest of the content...
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          );
        },
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

  // Helper method to get SVG file name from mood type
  String _getMoodSvgName(MoodType mood) {
    switch (mood) {
      case MoodType.angry:
        return 'angry.svg';
      case MoodType.sad:
        return 'sad.svg';
      case MoodType.neutral:
        return 'neutral.svg';
      case MoodType.happy:
        return 'happy.svg';
      case MoodType.excited:
        return 'excited.svg';
      default:
        return 'neutral.svg';
    }
  }

  // Build weekly mood summary based on real Firestore data
  Widget _buildWeeklySummary() {
    // Get mood data for each day of the week
    final now = DateTime.now();
    List<MoodModel?> weekMoods = List.filled(7, null);

    // For each of the last 7 days, find the corresponding mood (if any)
    for (int i = 0; i < 7; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day - 6 + i,
      );
      final dayStart = DateTime(
        date.year,
        date.month,
        date.day,
      );
      final dayEnd = DateTime(
        date.year,
        date.month,
        date.day,
        23,
        59,
        59,
      );

      weekMoods[i] = _moodData.firstWhere(
        (mood) =>
            mood.createdAt.isAfter(
              dayStart.subtract(const Duration(seconds: 1)),
            ) &&
            mood.createdAt.isBefore(
              dayEnd.add(const Duration(seconds: 1)),
            ),
        orElse:
            () => MoodModel(
              id: '',
              mood: MoodType.neutral,
              score: 3,
              createdAt: DateTime.now(),
            ),
      );
    }

    // Day names for display
    final dayNames = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    // Calculate average mood score if there's data
    double averageMood = 0;
    int moodCount = 0;

    for (var mood in weekMoods) {
      if (mood != null) {
        averageMood += mood.score;
        moodCount++;
      }
    }

    if (moodCount > 0) {
      averageMood = averageMood / moodCount;
    }

    // Get most common mood
    MoodType? mostCommonMood;
    if (moodCount > 0) {
      final moodCounts = <MoodType, int>{};
      for (var mood in weekMoods) {
        if (mood != null) {
          moodCounts[mood.mood] =
              (moodCounts[mood.mood] ?? 0) + 1;
        }
      }

      int maxCount = 0;
      for (var entry in moodCounts.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          mostCommonMood = entry.key;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly mood indicators
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This Week',
                style: semiBold.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.darkTextColor,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final mood = weekMoods[index];
                  final moodIcon =
                      mood != null
                          ? 'assets/svg/moods/${_getMoodSvgName(mood.mood)}'
                          : 'assets/svg/moods/neutral.svg';

                  return _buildDayMoodIndicator(
                    dayNames[index],
                    moodIcon,
                  );
                }),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // Mood insights cards
        Row(
          children: [
            // Average mood score card
            Expanded(
              child: Container(
                height: 100.h,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFE0EBFE,
                  ).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Avg. Mood',
                      style: medium.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.darkTextColor,
                      ),
                    ),
                    moodCount > 0
                        ? Row(
                          children: [
                            Text(
                              averageMood.toStringAsFixed(
                                1,
                              ),
                              style: semiBold.copyWith(
                                fontSize: 24.sp,
                                color:
                                    AppColors
                                        .secondaryColor,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            SvgPicture.asset(
                              'assets/svg/moods/${_getMoodSvgName(_getMoodTypeFromScore(averageMood.round()))}',
                              height: 24.h,
                              width: 24.h,
                            ),
                          ],
                        )
                        : Text(
                          'No data',
                          style: medium.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.darkTextColor,
                          ),
                        ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 16.w),

            // Most common mood card
            Expanded(
              child: Container(
                height: 100.h,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFF9ECA7,
                  ).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Most Common',
                      style: medium.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.darkTextColor,
                      ),
                    ),
                    mostCommonMood != null
                        ? Row(
                          children: [
                            Text(
                              _getMoodNameFromType(
                                mostCommonMood,
                              ),
                              style: semiBold.copyWith(
                                fontSize: 18.sp,
                                color:
                                    AppColors
                                        .secondaryColor,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            SvgPicture.asset(
                              'assets/svg/moods/${_getMoodSvgName(mostCommonMood)}',
                              height: 24.h,
                              width: 24.h,
                            ),
                          ],
                        )
                        : Text(
                          'No data',
                          style: medium.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.darkTextColor,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper to get mood type from score
  MoodType _getMoodTypeFromScore(int score) {
    switch (score) {
      case 1:
        return MoodType.angry;
      case 2:
        return MoodType.sad;
      case 3:
        return MoodType.neutral;
      case 4:
        return MoodType.happy;
      case 5:
        return MoodType.excited;
      default:
        return MoodType.neutral;
    }
  }

  // Helper to get mood name from type
  String _getMoodNameFromType(MoodType mood) {
    switch (mood) {
      case MoodType.angry:
        return 'Angry';
      case MoodType.sad:
        return 'Sad';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.happy:
        return 'Happy';
      case MoodType.excited:
        return 'Excited';
      default:
        return 'Neutral';
    }
  }
}
