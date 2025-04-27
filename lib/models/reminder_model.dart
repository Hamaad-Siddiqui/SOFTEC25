import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String category;
  final DateTime createdAt;
  final bool isCompleted;
  final String userId;

  ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    required this.createdAt,
    this.isCompleted = false,
    required this.userId,
  });

  // Create a ReminderModel from a Firestore document
  factory ReminderModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    Map<String, dynamic> data =
        doc.data() as Map<String, dynamic>;
    return ReminderModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      category: data['category'] ?? 'Personal',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      userId: data['userId'] ?? '',
    );
  }

  // Convert ReminderModel to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }

  // Create a copy of the reminder with some fields updated
  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
    DateTime? createdAt,
    bool? isCompleted,
    String? userId,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
    );
  }
}
