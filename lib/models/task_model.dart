import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskCategory { academic, social, personal, health, other }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final TaskCategory category;
  final DateTime createdAt;
  final List<String> subtasks;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.category,
    required this.createdAt,
    this.subtasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'category': category.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'subtasks': subtasks,
    };
  }

  static TaskModel fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
      category: TaskCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => TaskCategory.other,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      subtasks: List<String>.from(map['subtasks'] ?? []),
    );
  }
}
