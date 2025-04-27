import 'package:cloud_firestore/cloud_firestore.dart';

class SubTaskModel {
  final String task;
  final bool isCompleted;

  SubTaskModel({
    required this.task,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {'task': task, 'isCompleted': isCompleted};
  }

  static SubTaskModel fromMap(Map<String, dynamic> map) {
    return SubTaskModel(
      task: map['task'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String category;
  final DateTime createdAt;
  final List<SubTaskModel> subtasks;
  final bool timed; // Whether the task has a specific time
  final String time; // The time in HH:MM format if timed
  final String
  timeString; // Human readable time string like "8 PM"

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.category,
    required this.createdAt,
    List<SubTaskModel>? subtasks,
    List<String>? subtaskStrings,
    this.timed = false,
    this.time = "",
    this.timeString = "",
  }) : subtasks =
           subtasks ??
           (subtaskStrings
                   ?.map((task) => SubTaskModel(task: task))
                   .toList() ??
               []);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'subtasks':
          subtasks
              .map((subtask) => subtask.toMap())
              .toList(),
      'timed': timed,
      'time': time,
      'timeString': timeString,
    };
  }

  static TaskModel fromMap(Map<String, dynamic> map) {
    final rawSubtasks = map['subtasks'];
    List<SubTaskModel> subtasks = [];

    if (rawSubtasks != null) {
      if (rawSubtasks is List<dynamic>) {
        // Handle both maps and strings for backward compatibility
        subtasks =
            rawSubtasks.map((item) {
              if (item is Map<String, dynamic>) {
                return SubTaskModel.fromMap(item);
              } else if (item is String) {
                return SubTaskModel(task: item);
              }
              return SubTaskModel(task: '');
            }).toList();
      }
    }

    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
      category: map['category']?.toString() ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      subtasks: subtasks,
      timed: map['timed'] ?? false,
      time: map['time'] ?? '',
      timeString: map['timeString'] ?? '',
    );
  }

  // Helper method to create a copy of this task with updated fields
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    String? category,
    DateTime? createdAt,
    List<SubTaskModel>? subtasks,
    bool? timed,
    String? time,
    String? timeString,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      subtasks: subtasks ?? this.subtasks,
      timed: timed ?? this.timed,
      time: time ?? this.time,
      timeString: timeString ?? this.timeString,
    );
  }

  // Factory method to create a TaskModel from AI response
  static TaskModel fromAIResponse(
    Map<String, dynamic> response,
    String id,
  ) {
    // Parse timestamp from string
    DateTime dueDate;
    try {
      String iso8601 = response['timestamp'].toString();
      dueDate = DateTime.parse(iso8601);
    } catch (e) {
      throw Exception(
        'Invalid timestamp format: ${response['timestamp']}',
      );
    }

    // Create subtasks from the response if they exist
    List<SubTaskModel> subtasks = [];
    if (response['subtasks'] != null &&
        response['subtasks'] is List) {
      subtasks =
          (response['subtasks'] as List).map((item) {
            return SubTaskModel(
              task: item['title'] ?? '',
              isCompleted: item['completed'] ?? false,
            );
          }).toList();
    }

    return TaskModel(
      id: id,
      title: response['title'] ?? '',
      description: response['description'] ?? '',
      dueDate: dueDate,
      isCompleted: response['completed'] ?? false,
      category: response['category'] ?? 'General',
      createdAt: DateTime.now(),
      subtasks: subtasks,
      timed: response['timed'] ?? false,
      time: response['time'] ?? '',
      timeString: response['timeString'] ?? '',
    );
  }
}
