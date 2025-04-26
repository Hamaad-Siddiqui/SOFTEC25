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
    };
  }

  static TaskModel fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
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
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
      category: map['category']?.toString() ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      subtasks: subtasks,
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
    );
  }
}
