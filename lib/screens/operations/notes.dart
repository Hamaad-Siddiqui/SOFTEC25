import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:softec25/bloc/main_bloc.dart';
import 'package:softec25/models/notes_model.dart';
import 'package:softec25/styles.dart';
import 'package:softec25/utils/utils.dart';
import 'package:uuid/uuid.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteModel? note;
  final bool isEditing;

  const NoteDetailScreen({
    super.key,
    this.note,
    this.isEditing = false,
  });

  static const String routeName = '/noteDetailScreen';

  @override
  State<NoteDetailScreen> createState() =>
      _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool _isEditing;
  bool _isProcessing = false;
  bool _isSummaryGenerated = false;
  List<String> _summary = [];
  List<String> _tags = [];

  // Animation controller for UI elements
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.note == null || widget.isEditing;
    _titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    if (widget.note != null) {
      _summary = widget.note!.summary;
      _tags = widget.note!.tags;
      _isSummaryGenerated = _summary.isNotEmpty;
    }

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    // Create animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    // Validate inputs
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
        ),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some content'),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final bloc = Provider.of<MainBloc>(
      context,
      listen: false,
    );

    try {
      // Generate summary and tags using AI
      if (!_isSummaryGenerated ||
          widget.note?.content != _contentController.text) {
        final summaryResult = await bloc.noteSummary(
          _contentController.text,
        );

        if (summaryResult.containsKey('summary') &&
            summaryResult.containsKey('tags')) {
          _summary = List<String>.from(
            summaryResult['summary'],
          );
          _tags = List<String>.from(summaryResult['tags']);
          _isSummaryGenerated = true;
        }
      }

      // Create or update note
      final note = NoteModel(
        id: widget.note?.id ?? const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        lastModified: DateTime.now(),
        tags: _tags,
        summary: _summary,
      );

      // Here you would typically save to Firestore
      // await bloc.db.collection('notes').doc(note.id).set(note.toJson());

      setState(() {
        _isProcessing = false;
        _isEditing = false;
      });

      if (mounted) {
        // Return the note to caller
        Navigator.pop(context, note);
      }
    } catch (e) {
      warn(e);
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving note: ${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag:
          widget.note != null
              ? 'note_${widget.note!.id}'
              : 'new_note',
      child: Material(
        type: MaterialType.transparency,
        child: Scaffold(
          backgroundColor: AppColors.scaffoldLightBgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: SvgPicture.asset(
                'assets/svg/back.svg',
                width: 24.w,
                height: 24.h,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.secondaryColor,
                    size: 24.sp,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
              if (_isEditing)
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: AppColors.secondaryColor,
                    size: 24.sp,
                  ),
                  onPressed:
                      _isProcessing ? null : _saveNote,
                ),
            ],
          ),
          body:
              _isProcessing
                  ? const Center(
                    child: CircularProgressIndicator(),
                  )
                  : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // Title with background
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                      16.r,
                                    ),
                                border: Border.all(
                                  color: Colors.grey
                                      .withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  // Title
                                  if (_isEditing)
                                    TextField(
                                      controller:
                                          _titleController,
                                      style: semiBold.copyWith(
                                        fontSize: 24.sp,
                                        color:
                                            AppColors
                                                .darkTextColor,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Title',
                                        border:
                                            InputBorder
                                                .none,
                                        contentPadding:
                                            EdgeInsets.zero,
                                        hintStyle: semiBold.copyWith(
                                          fontSize: 24.sp,
                                          color: AppColors
                                              .grayTextColor
                                              .withOpacity(
                                                0.6,
                                              ),
                                        ),
                                      ),
                                    )
                                  else
                                    Text(
                                      _titleController.text,
                                      style: semiBold.copyWith(
                                        fontSize: 24.sp,
                                        color:
                                            AppColors
                                                .darkTextColor,
                                      ),
                                    ),

                                  SizedBox(height: 12.h),

                                  // Last modified date
                                  Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .access_time_rounded,
                                        size: 16.sp,
                                        color:
                                            AppColors
                                                .grayTextColor,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        widget.note != null
                                            ? DateFormat(
                                              'dd MMMM yyyy, HH:mm',
                                            ).format(
                                              widget
                                                  .note!
                                                  .lastModified,
                                            )
                                            : DateFormat(
                                              'dd MMMM yyyy, HH:mm',
                                            ).format(
                                              DateTime.now(),
                                            ),
                                        style: medium.copyWith(
                                          fontSize: 14.sp,
                                          color:
                                              AppColors
                                                  .grayTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Tags
                            if (_tags.isNotEmpty)
                              Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(
                                        16.r,
                                      ),
                                  border: Border.all(
                                    color: Colors.grey
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      'Tags',
                                      style: medium.copyWith(
                                        fontSize: 14.sp,
                                        color:
                                            AppColors
                                                .grayTextColor,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Wrap(
                                      spacing: 8.w,
                                      runSpacing: 8.h,
                                      children:
                                          _tags.map((tag) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    12.w,
                                                vertical:
                                                    6.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(
                                                  0xFFFED4E9,
                                                ), // Pink for tags
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      16.r,
                                                    ),
                                              ),
                                              child: Text(
                                                tag,
                                                style: medium.copyWith(
                                                  fontSize:
                                                      12.sp,
                                                  color: Color(
                                                    0xFFB86684,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                ),
                              ),

                            if (_tags.isNotEmpty)
                              SizedBox(height: 20.h),

                            // Content
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                      16.r,
                                    ),
                                border: Border.all(
                                  color: Colors.grey
                                      .withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  if (!_isEditing)
                                    Text(
                                      'Content',
                                      style: medium.copyWith(
                                        fontSize: 14.sp,
                                        color:
                                            AppColors
                                                .grayTextColor,
                                      ),
                                    ),
                                  if (!_isEditing)
                                    SizedBox(height: 8.h),

                                  if (_isEditing)
                                    TextField(
                                      controller:
                                          _contentController,
                                      style: regular.copyWith(
                                        fontSize: 16.sp,
                                        color:
                                            AppColors
                                                .darkTextColor,
                                        height: 1.5,
                                      ),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Start writing your note...',
                                        border:
                                            InputBorder
                                                .none,
                                        contentPadding:
                                            EdgeInsets.zero,
                                        hintStyle: regular.copyWith(
                                          fontSize: 16.sp,
                                          color: AppColors
                                              .grayTextColor
                                              .withOpacity(
                                                0.6,
                                              ),
                                        ),
                                      ),
                                      maxLines: null,
                                      keyboardType:
                                          TextInputType
                                              .multiline,
                                    )
                                  else
                                    Text(
                                      _contentController
                                          .text,
                                      style: regular.copyWith(
                                        fontSize: 16.sp,
                                        color:
                                            AppColors
                                                .darkTextColor,
                                        height: 1.5,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Summary section (only if available and not editing)
                            if (_summary.isNotEmpty &&
                                !_isEditing) ...[
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(
                                  16.w,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Colors
                                          .white, // Changed to white
                                  borderRadius:
                                      BorderRadius.circular(
                                        16.r,
                                      ),
                                  border: Border.all(
                                    color: Colors.grey
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .summarize_rounded,
                                          size: 20.sp,
                                          color:
                                              AppColors
                                                  .darkTextColor, // Changed to dark text color
                                        ),
                                        SizedBox(
                                          width: 8.w,
                                        ),
                                        Text(
                                          'Summary',
                                          style: semiBold
                                              .copyWith(
                                                fontSize:
                                                    18.sp,
                                                color:
                                                    AppColors
                                                        .darkTextColor, // Changed to dark text color
                                              ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 16.h),

                                    ...List.generate(_summary.length, (
                                      index,
                                    ) {
                                      return Padding(
                                        padding:
                                            EdgeInsets.only(
                                              bottom: 12.h,
                                            ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Container(
                                              width: 20.w,
                                              height: 20.h,
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .grey
                                                    .withOpacity(
                                                      0.1,
                                                    ), // Light grey background
                                                shape:
                                                    BoxShape
                                                        .circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${index + 1}',
                                                  style: semiBold.copyWith(
                                                    fontSize:
                                                        12.sp,
                                                    color:
                                                        AppColors.darkTextColor, // Dark text color
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            Expanded(
                                              child: Text(
                                                _summary[index],
                                                style: regular.copyWith(
                                                  fontSize:
                                                      15.sp,
                                                  color:
                                                      AppColors
                                                          .darkTextColor, // Dark text color
                                                  height:
                                                      1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],

                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}

// Component for displaying a note card in the home screen
class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'note_${note.id}',
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Note title
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    note.title,
                    style: semiBold.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.darkTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Note content preview
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                  ),
                  child: Text(
                    note.content,
                    style: regular.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.grayTextColor,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const Spacer(),

                // Tags and date
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Display up to 2 tags
                      if (note.tags.isNotEmpty)
                        SizedBox(
                          height: 28.h,
                          child: ListView.builder(
                            scrollDirection:
                                Axis.horizontal,
                            itemCount:
                                note.tags.length > 2
                                    ? 2
                                    : note.tags.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(
                                  right: 6.w,
                                ),
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                decoration: BoxDecoration(
                                  color: Color(
                                    0xFFFED4E9,
                                  ), // Only pink for tags as requested
                                  borderRadius:
                                      BorderRadius.circular(
                                        12.r,
                                      ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    Text(
                                      note.tags[index],
                                      style: medium
                                          .copyWith(
                                            fontSize: 11.sp,
                                            color: Color(
                                              0xFFB86684,
                                            ),
                                          ),
                                    ),
                                    if (index == 1 &&
                                        note.tags.length >
                                            2)
                                      Text(
                                        " +${note.tags.length - 2}",
                                        style: medium
                                            .copyWith(
                                              fontSize:
                                                  11.sp,
                                              color: Color(
                                                0xFFB86684,
                                              ),
                                            ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      SizedBox(height: 8.h),

                      // Last modified date
                      Text(
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(note.lastModified),
                        style: regular.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grayTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
