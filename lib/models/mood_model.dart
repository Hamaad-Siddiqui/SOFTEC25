import 'package:cloud_firestore/cloud_firestore.dart';

enum MoodType { angry, sad, neutral, happy, excited }

class MoodModel {
  final String id;
  final MoodType mood;
  final int
  score; // 1-5 (Angry=1, Sad=2, Neutral=3, Happy=4, Excited=5)
  final String notes;
  final String
  affirmation; // Will be filled by AI based on mood trends
  final DateTime createdAt;

  MoodModel({
    required this.id,
    required this.mood,
    required this.score,
    this.notes = '',
    this.affirmation = '',
    required this.createdAt,
  });

  // Convert MoodModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'mood': mood.toString().split('.').last,
      'score': score,
      'notes': notes,
      'affirmation': affirmation,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create a MoodModel from a Firestore document
  static MoodModel fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return MoodModel(
      id: id,
      mood: _moodFromString(map['mood'] ?? 'neutral'),
      score: map['score'] ?? 3,
      notes: map['notes'] ?? '',
      affirmation: map['affirmation'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Helper method to convert a string to MoodType
  static MoodType _moodFromString(String moodStr) {
    switch (moodStr.toLowerCase()) {
      case 'angry':
        return MoodType.angry;
      case 'sad':
        return MoodType.sad;
      case 'neutral':
        return MoodType.neutral;
      case 'happy':
        return MoodType.happy;
      case 'excited':
        return MoodType.excited;
      default:
        return MoodType.neutral;
    }
  }

  // Helper method to get the score from MoodType
  static int getScoreFromMoodType(MoodType mood) {
    switch (mood) {
      case MoodType.angry:
        return 1;
      case MoodType.sad:
        return 2;
      case MoodType.neutral:
        return 3;
      case MoodType.happy:
        return 4;
      case MoodType.excited:
        return 5;
    }
  }

  // Helper method to get the MoodType from index
  static MoodType getMoodTypeFromIndex(int index) {
    switch (index) {
      case 0:
        return MoodType.angry;
      case 1:
        return MoodType.sad;
      case 2:
        return MoodType.neutral;
      case 3:
        return MoodType.happy;
      case 4:
        return MoodType.excited;
      default:
        return MoodType.neutral;
    }
  }
}
