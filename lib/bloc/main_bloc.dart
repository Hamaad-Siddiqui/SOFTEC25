import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:softec25/models/notes_model.dart';
import 'package:softec25/models/user_model.dart';
import 'package:softec25/utils/utils.dart';

class MainBloc extends ChangeNotifier {
  late Box box;

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  List createdCategories = ["Academics"];

  // Notes list
  List<NoteModel> _notes = [];
  List<NoteModel> get notes => _notes;

  bool get isLoggedIn => auth.currentUser != null;

  UserModel? user;

  final googleSignIn = GoogleSignIn(
    clientId:
        (Platform.isIOS)
            ? '1074530652876-9eeongqb1jai8ui1njqic3jlok57aafl.apps.googleusercontent.com'
            : null,
  );

  // Initialize with some sample notes for demo purposes
  void initializeSampleNotes() {
    final now = DateTime.now();

    _notes = [
      NoteModel(
        id: '1',
        title: 'Database Systems Week 4',
        content:
            'Normalization is the process of ordering basic data structures to ensure that the basic data created is of good quality. Used to minimize data redundancy and data inconsistencies.\n\nNormalization stage starts from the lightest stage (1NF) to the strictest (5NF). Usually only up to the 3NF or BCNF level as they are sufficient to produce good quality tables.',
        lastModified: DateTime(2021, 4, 19, 20, 39),
        tags: [
          'College',
          'Lecture',
          'Daily',
          'Productivity',
        ],
        summary: [
          'Normalization organizes data structures to ensure data quality',
          'It reduces data redundancy and inconsistencies',
          'Process goes from 1NF to 5NF with increasing strictness',
          'Most databases only need to be normalized to 3NF or BCNF level',
        ],
      ),
      NoteModel(
        id: '2',
        title: 'Exploration Ideas',
        content:
            'Exploring potential projects for the upcoming hackathon:\n\n• Ticket App - Mobile application for event ticket purchasing and management\n• Travel Website - Interactive travel planning and booking platform\n• Digital Marketing Website - Website showcasing digital marketing services and analytics',
        lastModified: DateTime(
          now.year,
          now.month,
          now.day - 7,
        ),
        tags: ['Design', 'Productivity'],
        summary: [
          'Potential hackathon project ideas',
          'Mobile ticket management application concept',
          'Travel planning website platform idea',
          'Digital marketing services website concept',
        ],
      ),
      NoteModel(
        id: '3',
        title: 'Grocery List',
        content:
            'Today\'s shopping list:\n\n• Cereal\n• Shampoo\n• Toothpaste\n• Apple\n• Cup Noodles',
        lastModified: DateTime(
          now.year,
          now.month,
          now.day - 9,
        ),
        tags: ['Shopping', 'List'],
        summary: [
          'Shopping items including personal care products',
          'Food items including cereal, fruit, and instant meals',
          'Household essentials purchase list',
        ],
      ),
      NoteModel(
        id: '4',
        title: 'Meeting Notes',
        content:
            'Meeting with the team to discuss project updates and next steps:\n\n• Review of last week\'s progress\n• Discussion of challenges faced\n• Planning for next week\'s tasks',
        lastModified: DateTime(
          now.year,
          now.month,
          now.day - 10,
        ),
        tags: ['Work', 'Meeting'],
        summary: [
          'Team meeting to review project updates',
          'Discussion of challenges faced in the past week',
          'Planning for next week\'s tasks and goals',
        ],
      ),
    ];

    notifyListeners();
  }

  // Create a new note
  Future<NoteModel> createNote(NoteModel note) async {
    // In a real app, you would save to Firestore here
    // await db.collection('notes').doc(note.id).set(note.toJson());
    _notes.add(note);
    notifyListeners();
    return note;
  }

  // Update an existing note
  Future<void> updateNote(NoteModel updatedNote) async {
    // In a real app, you would update Firestore here
    // await db.collection('notes').doc(updatedNote.id).update(updatedNote.toJson());
    final index = _notes.indexWhere(
      (note) => note.id == updatedNote.id,
    );
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    // In a real app, you would delete from Firestore here
    // await db.collection('notes').doc(noteId).delete();
    _notes.removeWhere((note) => note.id == noteId);
    notifyListeners();
  }

  // Fetch notes for the current user
  Future<void> fetchNotes() async {
    // In a real app, you would fetch from Firestore here
    // final snapshot = await db.collection('notes').where('userId', isEqualTo: auth.currentUser!.uid).get();
    // _notes = snapshot.docs.map((doc) => NoteModel.fromJson(doc.data())).toList();

    // For demo, we'll just initialize some sample notes if empty
    if (_notes.isEmpty) {
      initializeSampleNotes();
    }

    notifyListeners();
  }

  Future<void> getUserDetails() async {
    if (!isLoggedIn) return;

    try {
      final doc =
          await db
              .collection('users')
              .doc(auth.currentUser!.uid)
              .get();
      user = UserModel.fromJson(doc.data()!);
    } catch (e) {
      warn(e);
    }
  }

  Future<String> loginWithGoogle() async {
    late OAuthCredential credential;
    GoogleSignInAccount? googleUser;
    try {
      console('Trying to sign in with Google...');
      // Trigger the authentication flow
      googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return 'User cancelled the operation.';
      }
      console('Google User: ${googleUser.email}');
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    } catch (e) {
      return 'An error occured, please try again';
    }

    try {
      final userCreds = await auth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCreds.user;

      if (firebaseUser == null) {
        return 'An error occured, please try again';
      }

      user = UserModel(
        uid: firebaseUser.uid,
        email: googleUser.email,
        fullName:
            googleUser.displayName ??
            firebaseUser.displayName ??
            'User',
        photoUrl:
            googleUser.photoUrl ??
            firebaseUser.photoURL ??
            '',
        authType: AuthType.google,
      );

      if (userCreds.additionalUserInfo?.isNewUser ??
          false) {
        console('IS A NEW USER!');
        final data = user!.toJson();
        data['createdAt'] = FieldValue.serverTimestamp();
        data['updatedAt'] = FieldValue.serverTimestamp();

        await db
            .collection('users')
            .doc(user!.uid)
            .set(data);

        return 'ok';
      } else {
        console('IS AN OLD USER!');
        await getUserDetails();

        return 'ok';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-disabled') {
        return 'The user account has been disabled by an administrator.';
      } else if (e.code == 'user-not-found') {
        return 'There is no user record corresponding to this identifier. The user may have been deleted.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is invalid.';
      } else if (e.code == 'wrong-password') {
        return 'The password is invalid or the user does not have a password.';
      } else if (e.code == 'weak-password') {
        return 'The password is not strong enough.';
      } else if (e.code == 'email-already-in-use') {
        return 'The email is already in use by a different account.';
      } else if (e.code ==
          'account-exists-with-different-credential') {
        return 'The email is already in use by email login. Try logging in with email instead.';
      } else {
        // FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
        return e.code;
      }
    } catch (e) {
      // FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return e.toString();
    }
  }

  Future<String> loginUser(
    String email,
    String password,
  ) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await getUserDetails();

      return 'ok';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Invalid email or password';
      } else if (e.code == 'wrong-password') {
        return 'Invalid email or password';
      } else if (e.code == 'invalid-email') {
        return 'Enter a valid email';
      } else if (e.code == 'user-disabled') {
        return 'banned';
      } else {
        return 'An error occured, please try again. Error code: ${e.code}';
      }
    } catch (e) {
      return 'An error occured, please try again. Error code: ${e.toString()}';
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return 'ok';
    } catch (e) {
      warn(e);
      return 'An error occured, please try again';
    }
  }

  Future<String> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = UserModel(
        uid: auth.currentUser!.uid,
        fullName: name,
        email: email,
        authType: AuthType.email,
      );

      final data = user!.toJson();

      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await db
          .collection('users')
          .doc(auth.currentUser!.uid)
          .set(data);

      return 'ok';
    } on FirebaseAuthException catch (e) {
      warn(e);
      if (e.code == 'email-already-in-use') {
        return 'Email already in use';
      } else if (e.code == 'weak-password') {
        return 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email entered';
      } else {
        return 'An unknown error occured, please try again';
      }
    } catch (e) {
      warn(e);
      return 'An unknown error occured, please try again';
    }
  }

  Future<Map<String, dynamic>> checklistCreation(
    String checklist,
  ) async {
    final String prompt = '''
Please make sure that you return JSON because whatever you give back goes directly to my codebase. So you will be given an input from the user that will be the task they want to create. Let's say that they give you the task: "Apply for internships" so you will return the response like:

{
  "title": "Apply for internship",
  "time" : "", 
  "timestamp": "1714123456123",
  "timeString": "",
  "category": "Career",
  "description": "",
  "completed": false,
  "timed": false,
  "subtasks": 
	[
		{
			title: "Update and tailor resume and cover letter",
			completed: false,
		},
		{
			title: "Research and shortlist companies",
			completed: false,
		},
		{
			title: "Submit applications with required documents",
			completed: false,
		},
		{
			title: "Track applications and follow up if needed",
			completed: false,
		},
	], 
}

The timestamp is the milliseconds from flutter firestore like this. Timestamp timestamp = Timestamp.now(); int millis = timestamp.millisecondsSinceEpoch; In this example the task is assumed for today because now deadline was given in he prompt by the user. If a future date is given then give the timestamp for that. If a task is big it can be broken down and you can generate its description too and a title. I will also give a set of categories if the task fits one of those categories then pick one from there. If not then generate a category for the task and return it. A task can have a single category. You have to break the task into subtasks as well. By default they wont be completed. If they said something like apply for internships tonight you would've assumed today at 8pm. if 8pm hasn't already happened. so pls use common sense there. something like: time: "20:00", timeString: "8 PM", timed: true, and the timestamp for 8pm today. You dont have to essentially give 4 subtasks. just give as many as you think are needed. if the user says something like I want to do X on 21st which is an example date then dont set timed to true, But add the timestamp for the start of that day, also empty time and timeString. If the user gives a vague task like "party tmrw" then make sure that you would clean up the title so it would be "Have a party" and it would be set for tomorrow accordingly. 


Here are the existing categories: $createdCategories

Here is the prompt by the user $checklist.
''';

    final systemMessage =
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "You are an AI assistant.",
            ),
          ],
          role: OpenAIChatMessageRole.system,
        );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          prompt,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final requestMessages = [systemMessage, userMessage];

    OpenAIChatCompletionModel chatCompletion = await OpenAI
        .instance
        .chat
        .create(
          model: "gpt-4o-mini",
          responseFormat: {"type": "json_object"},
          messages: requestMessages,
        );
    notifyListeners();
    return jsonDecode(
      chatCompletion.choices[0].message.content![0].text!,
    );
  }

  Future<Map<String, dynamic>> taskCreation(
    String task,
  ) async {
    final String prompt = '''
Please make sure that you return JSON because whatever you give back goes directly to my codebase. So you will be given an input from the user that will be the task they want to create. Let's say that they give you the task: "Apply for internships" so you will return the response like:

{
  "title": "Apply for internship",
  "time" : "", 
  "timestamp": "1714123456123",
  "timeString": "",
  "category": "Career",
  "description": "",
  "completed": false,
  "timed": false,
  "subtasks": [], 
}


The timestamp is the milliseconds from flutter firestore like this. Timestamp timestamp = Timestamp.now(); int millis = timestamp.millisecondsSinceEpoch; In this example the task is assumed for today because now deadline was given in he prompt by the user. If a future date is given then give the timestamp for that. If a task is big it can be broken down and you can generate its description too and a title. I will also give a set of categories if the task fits one of those categories then pick one from there. If not then generate a category for the task and return it. A task can have a single category. completed is always false and subtasks is always empty u dont need to gen those.  If they said something like apply for internships tonight you would've assumed today at 8pm. if 8pm hasn't already happened. so pls use common sense there. something like: time: "20:00", timeString: "8 PM", timed: true, and the timestamp for 8pm today. You dont have to essentially give 4 subtasks. just give as many as you think are needed. if the user says something like I want to do X on 21st which is an example date then dont set timed to true, But add the timestamp for the start of that day, also empty time and timeString. If the user gives a vague task like "party tmrw" then make sure that you would clean up the title so it would be "Have a party" and it would be set for tomorrow accordingly.


Here are the existing categories: $createdCategories

Here is the prompt by the user $task.
''';

    final systemMessage =
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "You are an AI assistant.",
            ),
          ],
          role: OpenAIChatMessageRole.system,
        );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          prompt,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final requestMessages = [systemMessage, userMessage];

    OpenAIChatCompletionModel chatCompletion = await OpenAI
        .instance
        .chat
        .create(
          model: "gpt-4o-mini",
          responseFormat: {"type": "json_object"},
          messages: requestMessages,
        );
    notifyListeners();
    return jsonDecode(
      chatCompletion.choices[0].message.content![0].text!,
    );
  }

  Future<Map<String, dynamic>> noteSummary(
    String note,
  ) async {
    final String prompt = '''
Please make sure that you return JSON only because whatever you give back goes directly to my codebase. So you will be given an input from the user that will be their notes and I want you to summarize it in 3 to 4 bullet points (MAX). Also label it in tags. Feel free to add as many tags as appropriate minimum 1, maximum 3 Here is the basic json format which you will return:

{
	summary:
	[
		"bullet 1",
		"bullet 2",
		"bullet 3",
		"bullet 4",
	],
	tags: ["tag 1", "tag 2"]
}

Here is the users note: $note
''';

    final systemMessage =
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "You are an AI assistant.",
            ),
          ],
          role: OpenAIChatMessageRole.system,
        );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          prompt,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final requestMessages = [systemMessage, userMessage];

    OpenAIChatCompletionModel chatCompletion = await OpenAI
        .instance
        .chat
        .create(
          model: "gpt-4o-mini",
          responseFormat: {"type": "json_object"},
          messages: requestMessages,
        );
    notifyListeners();
    return jsonDecode(
      chatCompletion.choices[0].message.content![0].text!,
    );
  }

  Future<Map<String, dynamic>> dailyAffirmation(
    String mood,
    String reflection,
  ) async {
    final String prompt = '''
Please make sure that you return JSON only because whatever you give back goes directly to my codebase. So you will be given an input from the user that will be their mood for today. The mood can be angry, sad, neutral, happy, excited. These have the score from 1 to 5 respectively angry being the lowest i.e. 1 and excited being the highest i.e. 5. I want you to take that and the reflection the user will give you about their day and give them affirmation and a motivational message. Here is the basic JSON format which you will return:

{
	affirmation: "<return data here>"
}

Here is the users mood: $mood
Here is the users reflection: $reflection


''';

    final systemMessage =
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "You are an AI assistant.",
            ),
          ],
          role: OpenAIChatMessageRole.system,
        );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          prompt,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final requestMessages = [systemMessage, userMessage];

    OpenAIChatCompletionModel chatCompletion = await OpenAI
        .instance
        .chat
        .create(
          model: "gpt-4o-mini",
          responseFormat: {"type": "json_object"},
          messages: requestMessages,
        );
    notifyListeners();
    return jsonDecode(
      chatCompletion.choices[0].message.content![0].text!,
    );
  }
}
