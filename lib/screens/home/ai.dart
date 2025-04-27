import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:softec25/bloc/main_bloc.dart';
import 'package:softec25/models/reminder_model.dart';
import 'package:softec25/models/task_model.dart';
import 'package:softec25/screens/home/planner.dart';
import 'package:softec25/styles.dart';
import 'package:softec25/utils/utils.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:video_player/video_player.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  static const String routeName = '/aiScreen';

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  late VideoPlayerController _videoController;
  final TextEditingController _messageController =
      TextEditingController();

  // Speech to text variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isRecording = false;
  bool _speechEnabled = false;
  String _lastRecognizedWords = '';
  bool _isProcessing =
      false; // Flag to track if we're currently processing a task

  // Type flags to determine if we're creating a task or checklist
  bool _isTask = true; // Default to task
  bool _isChecklist = false;
  bool _isReminder = false;

  @override
  void initState() {
    super.initState();

    // Initialize the video player
    _videoController = VideoPlayerController.asset(
        'assets/video/voice_orb.mp4',
      )
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });

    // Initialize speech recognition
    _initSpeech();

    // Check route arguments after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if we have arguments to determine if we're creating a task, checklist or reminder
      final args =
          ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _isTask = args['type'] == 'task';
          _isChecklist = args['type'] == 'checklist';
          _isReminder = args['type'] == 'reminder';
        });
      }
    });
  }

  /// Initialize speech recognition functionality
  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError:
          (error) =>
              print('Speech recognition error: $error'),
    );
    setState(() {});
  }

  /// Callback when speech recognition status changes
  void _onSpeechStatus(String status) {
    // Update UI based on speech recognition status
    print('Speech recognition status: $status');
    if (status == 'notListening') {
      setState(() {
        _isRecording = false;
      });
    }
  }

  /// Callback when speech is recognized
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastRecognizedWords = result.recognizedWords;
      _messageController.text = _lastRecognizedWords;
    });

    // When speech recognition finishes with final result, process the task
    if (result.finalResult &&
        _lastRecognizedWords.isNotEmpty &&
        !_isProcessing) {
      _processUserInput(_lastRecognizedWords);
    }
  }

  /// Start or stop speech recognition
  void _toggleRecording() {
    if (_speech.isNotListening) {
      setState(() {
        _isRecording = true;
      });

      // Increase video playback speed to give visual feedback
      _videoController.setPlaybackSpeed(1.5);

      // Start listening
      _speech.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(
          seconds: 30,
        ), // Listen for 30 seconds max
        pauseFor: const Duration(
          seconds: 3,
        ), // Auto stop after 3 seconds of silence
        partialResults: true, // Get results as user speaks
        localeId: 'en_US', // Use English
      );
    } else {
      // Stop listening
      _speech.stop();
      _videoController.setPlaybackSpeed(1.0);
      setState(() {
        _isRecording = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _messageController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && !_isProcessing) {
      // Process the user input text for task creation
      _processUserInput(text);
      _messageController.clear();
    }
  }

  /// Process user input (either from speech or manual text)
  Future<void> _processUserInput(String input) async {
    // Prevent multiple simultaneous submissions
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Show processing dialog that will be updated with success message
      _showProcessingDialog();

      final mainBloc = context.read<MainBloc>();

      // Handle different input types (task, checklist, or reminder)
      if (_isReminder) {
        // Process as a reminder
        final response = await mainBloc.reminderCreation(
          input,
        );

        // Create a reminder from the AI response
        final reminder = await mainBloc
            .createReminderFromAI(response);

        // Update dialog to show success
        if (mounted) {
          Navigator.of(
            context,
          ).pop(); // Close current dialog
          _showSuccessDialog(
            reminder.title,
          ); // Show success dialog
        }

        // Navigate to planner screen after brief delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // Pop back to previous screen first
            Navigator.of(context).pop();

            // Navigate to planner screen if not already there
            Navigator.of(
              context,
            ).pushReplacementNamed(PlannerScreen.routeName);
          }
        });
      } else {
        // Process as a task or checklist
        final response =
            _isChecklist
                ? await mainBloc.checklistCreation(input)
                : await mainBloc.taskCreation(input);

        // Create a new task from the AI response
        final String taskId =
            FirebaseFirestore.instance
                .collection('users')
                .doc(mainBloc.auth.currentUser!.uid)
                .collection('tasks')
                .doc()
                .id;

        final taskModel = TaskModel.fromAIResponse(
          response,
          taskId,
        );

        // Save the task to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(mainBloc.auth.currentUser!.uid)
            .collection('tasks')
            .doc(taskId)
            .set(taskModel.toMap());

        // Update dialog to show success
        if (mounted) {
          Navigator.of(
            context,
          ).pop(); // Close current dialog
          _showSuccessDialog(
            taskModel.title,
          ); // Show success dialog
        }

        // Close the AI screen after a brief delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(
              context,
            ).pop(); // Return to the previous screen

            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(
                context,
              ).pop(); // Return to the previous screen
            }
          }
        });
      }
    } catch (e) {
      // Hide loading dialog if showing
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error dialog
      _showErrorDialog(e.toString());

      print('Error processing user input: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// Show a processing dialog while creating the task
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
                'Creating your ${_isChecklist ? 'checklist' : 'task'}...',
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

  /// Show a success dialog after creation
  void _showSuccessDialog(String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: Colors.white,
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
                _isReminder
                    ? 'Reminder Created'
                    : _isChecklist
                    ? 'Checklist Created'
                    : 'Task Created',
                style: semiBold.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.darkTextColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
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

  /// Show an error dialog if task creation fails
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
            'Failed to create task: $errorMessage',
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

  /// Show a loading dialog while processing
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  AppColors.secondaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Creating your task...',
                style: medium.copyWith(fontSize: 16.sp),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show a success message after task creation
  void _showSuccessMessage(String taskTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Task "$taskTitle" created successfully!',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
        title: Text(
          'AI Assistant',
          style: semiBold.copyWith(
            fontSize: 18.sp,
            color: AppColors.darkTextColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // Voice orb video and listening indicator
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Voice orb video
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.2.sw,
                  ),
                  child: Center(
                    child:
                        _videoController.value.isInitialized
                            ? AspectRatio(
                              aspectRatio:
                                  _videoController
                                      .value
                                      .aspectRatio,
                              child: VideoPlayer(
                                _videoController,
                              ),
                            )
                            : const CircularProgressIndicator(),
                  ),
                ),

                // Listening text indicator
                if (_isRecording)
                  Positioned(
                    bottom: 30.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(
                          20.r,
                        ),
                      ),
                      child: Text(
                        'Listening...',
                        style: medium.copyWith(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Input field at bottom
          Container(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom:
                  16.h +
                  MediaQuery.of(context).padding.bottom,
              top: 16.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Microphone button
                GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color:
                          _isRecording
                              ? Colors.redAccent
                                  .withOpacity(0.2)
                              : const Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svg/mic.svg',
                        height: 20.h,
                        width: 20.w,
                        colorFilter: ColorFilter.mode(
                          _isRecording
                              ? Colors.redAccent
                              : Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // Text input field
                Expanded(
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(
                        24.r,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ),
                    child: Center(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Chat with Chatbot...',
                          hintStyle: regular.copyWith(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: regular.copyWith(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // Camera button
                GestureDetector(
                  onTap: () {
                    // Handle camera functionality
                  },
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svg/camera.svg',
                        height: 20.h,
                        width: 20.w,
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // Send button
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svg/send.svg',
                        height: 20.h,
                        width: 20.w,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
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
    );
  }
}
