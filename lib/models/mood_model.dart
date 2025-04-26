import 'package:cloud_firestore/cloud_firestore.dart';

enum MoodType { great, good, neutral, bad, terrible }

class MoodModel {
  final String id;
  final MoodType mood;
  final String reflection;
  final DateTime createdAt;

  MoodModel({
    required this.id,
    required this.mood,
    this.reflection = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'mood': mood.toString().split('.').last,
      'reflection': reflection,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static MoodModel fromMap(Map<String, dynamic> map, String id) {
    return MoodModel(
      id: id,
      mood: MoodType.values.firstWhere(
        (e) => e.toString().split('.').last == map['mood'],
        orElse: () => MoodType.neutral,
      ),
      reflection: map['reflection'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
