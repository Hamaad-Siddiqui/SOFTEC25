import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_keys.dart';

class AIService {
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  // Parse natural language to task
  Future<Map<String, dynamic>> parseNaturalLanguageTask(String input) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.openAIKey}',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an AI assistant that helps parse natural language task descriptions into structured task data. Extract the task title, description, due date, and category (academic, social, personal, health, or other).',
            },
            {'role': 'user', 'content': input},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content);
      } else {
        throw Exception('Failed to parse task: ${response.body}');
      }
    } catch (e) {
      print('Error in AI parsing: $e');
      // Fallback with basic parsing
      return {
        'title': input,
        'description': '',
        'dueDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
        'category': 'other',
      };
    }
  }

  // Generate checklist from goal
  Future<List<String>> generateChecklistFromGoal(String goal) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.openAIKey}',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an AI assistant that helps break down goals into actionable subtasks. Generate a list of 3-5 concrete steps.',
            },
            {'role': 'user', 'content': 'Break this goal into steps: $goal'},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        // Parse the response into a list of steps
        List<String> steps = [];
        content.split('\n').forEach((line) {
          if (line.trim().isNotEmpty) {
            // Remove numbering and bullet points
            String cleanedLine =
                line.replaceAll(RegExp(r'^\d+\.\s*|\-\s*'), '').trim();
            if (cleanedLine.isNotEmpty) {
              steps.add(cleanedLine);
            }
          }
        });
        return steps;
      } else {
        throw Exception('Failed to generate checklist: ${response.body}');
      }
    } catch (e) {
      print('Error in AI checklist generation: $e');
      return ['Step 1', 'Step 2', 'Step 3'];
    }
  }

  // Summarize notes
  Future<List<String>> summarizeNotes(String notes) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.openAIKey}',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an AI assistant that summarizes notes into 3-5 bullet points.',
            },
            {
              'role': 'user',
              'content': 'Summarize these notes into 3-5 key points: $notes',
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        // Parse the response into bullet points
        List<String> bulletPoints = [];
        content.split('\n').forEach((line) {
          if (line.trim().isNotEmpty) {
            // Remove bullet points
            String cleanedLine =
                line.replaceAll(RegExp(r'^\s*\-\s*|\•\s*'), '').trim();
            if (cleanedLine.isNotEmpty) {
              bulletPoints.add(cleanedLine);
            }
          }
        });
        return bulletPoints;
      } else {
        throw Exception('Failed to summarize notes: ${response.body}');
      }
    } catch (e) {
      print('Error in AI summarization: $e');
      return ['Failed to summarize notes'];
    }
  }
}
