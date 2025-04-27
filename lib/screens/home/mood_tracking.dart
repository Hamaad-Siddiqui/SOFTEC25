import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:softec25/bloc/main_bloc.dart';
import 'package:softec25/models/mood_model.dart';
import 'package:softec25/styles.dart';
import 'package:softec25/utils/utils.dart';

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  static const String routeName = '/moodTracking';

  @override
  State<MoodTrackingScreen> createState() =>
      _MoodTrackingScreenState();
}

class _MoodTrackingScreenState
    extends State<MoodTrackingScreen> {
  // Index of the currently selected mood (0-4)
  int _selectedMoodIndex =
      2; // Default to neutral/slightly happy (middle option)

  // Controller for notes input
  final TextEditingController _notesController =
      TextEditingController();

  // Flag to track if we're currently processing
  bool _isProcessing = false;

  // List of mood SVGs from assets
  final List<String> _moodSvgs = [
    'assets/svg/moods/angry.svg',
    'assets/svg/moods/sad.svg',
    'assets/svg/moods/neutral.svg',
    'assets/svg/moods/happy.svg',
    'assets/svg/moods/excited.svg',
  ];

  // List of mood labels
  final List<String> _moodLabels = [
    'Angry',
    'Sad',
    'Neutral',
    'Happy',
    'Excited',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: SvgPicture.asset(
            'assets/svg/back.svg',
            height: 24.h,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              // Mood selection header
              Text(
                'How did you feel today?',
                style: semiBold.copyWith(
                  fontSize: 24.sp,
                  color: AppColors.darkTextColor,
                ),
              ),
              SizedBox(height: 30.h),

              // Mood selection slider
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 20.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Column(
                  children: [
                    // Mood icons
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        _moodSvgs.length,
                        (index) => _buildMoodIcon(index),
                      ),
                    ),

                    // Dotted line
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15.w,
                            ),
                            child: CustomPaint(
                              painter: DottedLinePainter(),
                              size: Size(
                                double.infinity,
                                2.h,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Labels below icons - using individual columns for precise alignment
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        _moodLabels.length,
                        (index) => SizedBox(
                          width:
                              50.w, // Same width as the mood icon container
                          child: Center(
                            child: Text(
                              _moodLabels[index],
                              textAlign: TextAlign.center,
                              style: medium.copyWith(
                                fontSize: 12.sp,
                                color:
                                    _selectedMoodIndex ==
                                            index
                                        ? AppColors
                                            .secondaryColor
                                        : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // Additional content can be added here
              Text(
                'Reflect on your day (optional)',
                style: medium.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.darkTextColor,
                ),
              ),
              SizedBox(height: 10.h),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Write your thoughts here...',
                  hintStyle: regular.copyWith(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12.r,
                    ),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12.r,
                    ),
                    borderSide: BorderSide(
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ),
                maxLines: 4,
              ),

              SizedBox(height: 30.h),

              // Save button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _saveMood();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.secondaryColor,
                    minimumSize: Size(
                      double.infinity.w,
                      50.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12.r,
                      ),
                    ),
                  ),
                  child: Text(
                    'Save Mood',
                    style: semiBold.copyWith(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Building individual mood icons
  Widget _buildMoodIcon(int index) {
    final isSelected = _selectedMoodIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMoodIndex = index;
        });
      },
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Color(0xFFCFE6ED).withOpacity(
                    0.9,
                  ) // Light yellow background for selected mood
                  : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // SVG Mood Icon
            SvgPicture.asset(
              _moodSvgs[index],
              width: 30.w,
              height: 30.w,
            ),

            // Green checkmark for selected mood
            if (isSelected)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12.w,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Save the user's mood to Firestore
  Future<void> _saveMood() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Show processing dialog
      _showProcessingDialog();

      // Get the current user
      final mainBloc = context.read<MainBloc>();
      final userId = mainBloc.auth.currentUser!.uid;

      // Create a document reference
      final moodDocRef =
          mainBloc.db
              .collection('users')
              .doc(userId)
              .collection('moods')
              .doc();

      // Create the mood model
      final moodType = MoodModel.getMoodTypeFromIndex(
        _selectedMoodIndex,
      );

      // Generate affirmation first, before saving to Firestore
      String affirmation = await _generateAffirmation(
        userId,
        moodType,
      );

      final mood = MoodModel(
        id: moodDocRef.id,
        mood: moodType,
        score: MoodModel.getScoreFromMoodType(moodType),
        notes: _notesController.text.trim(),
        affirmation:
            affirmation, // Include the generated affirmation
        createdAt: DateTime.now(),
      );

      // Save to Firestore with affirmation already included
      await moodDocRef.set(mood.toMap());

      mainBloc.usersMoodToday = mood;

      mainBloc.notifyAll();

      // Close processing dialog and show success
      if (mounted) {
        Navigator.of(
          context,
        ).pop(); // Close processing dialog
        _showSuccessDialog('Mood saved successfully!');
      }

      // Return to previous screen after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      // Handle error
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error dialog
      _showErrorDialog(e.toString());

      print('Error saving mood: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Generate AI affirmation based on mood
  Future<String> _generateAffirmation(
    String userId,
    MoodType moodType,
  ) async {
    try {
      final mb = context.read<MainBloc>();
      final res = await mb.dailyAffirmation(
        moodType.name,
        _notesController.text.trim(),
      );

      return res['affirmation'] ?? "You are doing great!";
    } catch (e) {
      warn('Error generating affirmation: $e');
      return "Take a moment to breathe and be present."; // Fallback affirmation
    }
  }

  /// Show a processing dialog while saving the mood
  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              SizedBox(
                height: 40.h,
                width: 40.h,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.secondaryColor,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Saving your mood...',
                style: medium.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.darkTextColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show a success dialog after saving the mood
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60.h,
                width: 60.h,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.secondaryColor,
                  size: 40.h,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Mood Saved',
                style: semiBold.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.darkTextColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: medium.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.grayTextColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show an error dialog if saving fails
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Error',
            style: semiBold.copyWith(
              fontSize: 18.sp,
              color: Colors.red,
            ),
          ),
          content: Text(
            'Failed to save mood: $errorMessage',
            style: regular.copyWith(
              fontSize: 14.sp,
              color: AppColors.darkTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: medium.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.secondaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for drawing dotted line
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

    final dashWidth = 5;
    final dashSpace = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
