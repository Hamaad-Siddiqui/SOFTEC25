import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:softec25/models/user_model.dart';
import 'package:softec25/utils/utils.dart';

class MainBloc extends ChangeNotifier {
  late Box box;

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  bool get isLoggedIn => auth.currentUser != null;

  UserModel? user;

  final googleSignIn = GoogleSignIn(
    clientId:
        (Platform.isIOS)
            ? '1074530652876-9eeongqb1jai8ui1njqic3jlok57aafl.apps.googleusercontent.com'
            : null,
  );

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
}
