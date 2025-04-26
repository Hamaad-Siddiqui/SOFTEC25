import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime lastModified;
  final List<String> tags;
  final List<String> summary;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.lastModified,
    this.tags = const [],
    this.summary = const [],
  });

  // Create a copy of the note with updated fields
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? lastModified,
    List<String>? tags,
    List<String>? summary,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      lastModified: lastModified ?? this.lastModified,
      tags: tags ?? this.tags,
      summary: summary ?? this.summary,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'lastModified': Timestamp.fromDate(lastModified),
      'tags': tags,
      'summary': summary,
    };
  }

  // Create from Firestore Map
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      lastModified:
          (json['lastModified'] as Timestamp).toDate(),
      tags: List<String>.from(json['tags'] ?? []),
      summary: List<String>.from(json['summary'] ?? []),
    );
  }
}
