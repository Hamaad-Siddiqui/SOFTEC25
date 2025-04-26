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

class _NoteDetailScreenState
    extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool _isEditing;
  bool _isProcessing = false;
  bool _isSummaryGenerated = false;
  List<String> _summary = [];
  List<String> _tags = [];

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
    return Scaffold(
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
              onPressed: _isProcessing ? null : _saveNote,
            ),
        ],
      ),
      body:
          _isProcessing
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Title
                    if (_isEditing)
                      TextField(
                        controller: _titleController,
                        style: semiBold.copyWith(
                          fontSize: 24.sp,
                          color: AppColors.darkTextColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                          hintStyle: semiBold.copyWith(
                            fontSize: 24.sp,
                            color: AppColors.grayTextColor
                                .withOpacity(0.6),
                          ),
                        ),
                      )
                    else
                      Text(
                        _titleController.text,
                        style: semiBold.copyWith(
                          fontSize: 24.sp,
                          color: AppColors.darkTextColor,
                        ),
                      ),

                    SizedBox(height: 8.h),

                    // Last modified date
                    Row(
                      children: [
                        Text(
                          'Last Modified',
                          style: regular.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.grayTextColor,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          widget.note != null
                              ? DateFormat(
                                'dd MMMM yyyy, HH:mm',
                              ).format(
                                widget.note!.lastModified,
                              )
                              : DateFormat(
                                'dd MMMM yyyy, HH:mm',
                              ).format(DateTime.now()),
                          style: medium.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.grayTextColor,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Tags
                    if (_tags.isNotEmpty)
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children:
                            _tags.map((tag) {
                              return Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                decoration: BoxDecoration(
                                  color: AppColors
                                      .secondaryColor
                                      .withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(
                                        16.r,
                                      ),
                                ),
                                child: Text(
                                  tag,
                                  style: medium.copyWith(
                                    fontSize: 12.sp,
                                    color:
                                        AppColors
                                            .secondaryColor,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),

                    SizedBox(height: 24.h),

                    // Divider
                    Divider(
                      color: AppColors.grayTextColor
                          .withOpacity(0.2),
                      thickness: 1,
                    ),

                    SizedBox(height: 16.h),

                    // Content
                    if (_isEditing)
                      TextField(
                        controller: _contentController,
                        style: regular.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.darkTextColor,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Start writing your note...',
                          border: InputBorder.none,
                          hintStyle: regular.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.grayTextColor
                                .withOpacity(0.6),
                          ),
                        ),
                        maxLines: null,
                        keyboardType:
                            TextInputType.multiline,
                      )
                    else
                      Text(
                        _contentController.text,
                        style: regular.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.darkTextColor,
                          height: 1.5,
                        ),
                      ),

                    SizedBox(height: 40.h),

                    // Summary section (only if available and not editing)
                    if (_summary.isNotEmpty &&
                        !_isEditing) ...[
                      Text(
                        'Summary',
                        style: semiBold.copyWith(
                          fontSize: 18.sp,
                          color: AppColors.darkTextColor,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor
                              .withOpacity(0.05),
                          borderRadius:
                              BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.secondaryColor
                                .withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children:
                              _summary.map((point) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 8.h,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        '•',
                                        style: medium.copyWith(
                                          fontSize: 16.sp,
                                          color:
                                              AppColors
                                                  .secondaryColor,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          point,
                                          style: regular
                                              .copyWith(
                                                fontSize:
                                                    15.sp,
                                                color:
                                                    AppColors
                                                        .darkTextColor,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ],

                    SizedBox(height: 32.h),
                  ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note title
            Padding(
              padding: EdgeInsets.all(12.w),
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
                horizontal: 12.w,
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
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Display up to 3 tags
                  if (note.tags.isNotEmpty)
                    Row(
                      children: [
                        for (
                          int i = 0;
                          i < note.tags.length && i < 3;
                          i++
                        )
                          Container(
                            margin: EdgeInsets.only(
                              right: 6.w,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors
                                  .secondaryColor
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(
                                    12.r,
                                  ),
                            ),
                            child: Text(
                              note.tags[i],
                              style: medium.copyWith(
                                fontSize: 10.sp,
                                color:
                                    AppColors
                                        .secondaryColor,
                              ),
                            ),
                          ),
                        if (note.tags.length > 3)
                          Text(
                            '+${note.tags.length - 3}',
                            style: regular.copyWith(
                              fontSize: 10.sp,
                              color:
                                  AppColors.grayTextColor,
                            ),
                          ),
                      ],
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
    );
  }
}
