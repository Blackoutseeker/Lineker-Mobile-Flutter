import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../stores/user_store.dart';
import '../stores/theme_store.dart';

import '../../models/interfaces/services/authentication.dart';
import '../../models/shared_preferences/storaged_values.dart';
import '../../models/routes/app_routes.dart';

class Authentication implements IAuthentication {
  static final Authentication instance = Authentication();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<Widget> _presentDialog(
    String title,
    String content,
    BuildContext context,
  ) async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <TextButton>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUserSession(String email, BuildContext context) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final UserStore userStore = GetIt.I.get<UserStore>();
    final ThemeStore themeStore = GetIt.I.get<ThemeStore>();
    userStore.signInUser(email, _firebaseAuth.currentUser!.uid);
    themeStore.changeTheme(false);
    await preferences.setString(
        StoragedValues.userUID, _firebaseAuth.currentUser!.uid);
    await preferences.setString(StoragedValues.userEmail, email).then(
        (_) async =>
            await Navigator.of(context).pushReplacementNamed(AppRoutes.main));
  }

  void _createUserInDatabase(
    String? uid,
    String? email,
    BuildContext context,
  ) async {
    if (uid != null && email != null) {
      await _database.reference().child('users/$uid').set({
        'email': email,
        'filters': {
          'Default': {
            'filter': 'Default',
          }
        }
      }).then((_) => _saveUserSession(email, context));
    }
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (email.isNotEmpty && password.length >= 6) {
      await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((_) async {
        final bool? userHaveEmailVerified =
            _firebaseAuth.currentUser?.emailVerified;
        if (!userHaveEmailVerified!) {
          await _firebaseAuth.currentUser
              ?.sendEmailVerification()
              .then((_) async {
            await _presentDialog(
              'Check your inbox!',
              'I sent you an email to verify your account.',
              context,
            );
          });
        } else {
          _saveUserSession(email, context);
        }
      }).catchError((error) async {
        await _presentDialog(
          'Error!',
          error.message,
          context,
        );
      });
    }
  }

  Future<bool> _checkIfUserAlreadyIsStoredInDatabase(String? userUID) async {
    if (userUID == null) return false;

    final user =
        await _database.reference().child('users').child(userUID).once();
    return user.exists;
  }

  @override
  Future<void> signInWithGoogle(BuildContext context, bool mounted) async {
    final googleAccount = await _googleSignIn.signIn();
    if (googleAccount == null) return;

    final googleAuthentication = await googleAccount.authentication;
    final googleAuthenticationProviderCredential =
        GoogleAuthProvider.credential(
      accessToken: googleAuthentication.accessToken,
      idToken: googleAuthentication.idToken,
    );

    await FirebaseAuth.instance
        .signInWithCredential(googleAuthenticationProviderCredential)
        .then((userCredential) async {
      final user = userCredential.user;
      if (user == null) return;

      final bool userAlreadyExists =
          await _checkIfUserAlreadyIsStoredInDatabase(user.uid);
      if (userAlreadyExists) {
        if (mounted) {
          _saveUserSession(user.email!, context);
        }
      } else {
        if (mounted) {
          _createUserInDatabase(user.uid, user.email, context);
        }
      }
    }).catchError((error) async {
      await _presentDialog(
        'Error!',
        error.message,
        context,
      );
    });
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (email.isNotEmpty && password.length >= 6) {
      await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((_) async {
        await _firebaseAuth.currentUser?.sendEmailVerification().then((_) {
          _createUserInDatabase(_firebaseAuth.currentUser?.uid, email, context);
        });
      }).catchError((error) async {
        await _presentDialog(
          'Error!',
          error.message,
          context,
        );
      });
    }
  }

  @override
  Future<void> signOut(BuildContext context, bool mounted) async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
    await _firebaseAuth.signOut();

    final UserStore userStore = GetIt.I.get<UserStore>();
    final ThemeStore themeStore = GetIt.I.get<ThemeStore>();

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear().then((_) async {
      await themeStore.changeTheme(false);
      if (mounted) {
        await Navigator.of(context)
            .pushReplacementNamed(AppRoutes.login)
            .then((_) {
          userStore.signOutUser();
        });
      }
    });
  }

  @override
  Future<void> resetPassword(String email, BuildContext context) async {
    if (email.isNotEmpty) {
      await _firebaseAuth.sendPasswordResetEmail(email: email).then((_) async {
        await _presentDialog(
          'Check your inbox!',
          'I sent you an email to reset your password.',
          context,
        );
      }).catchError((error) async {
        await _presentDialog('Error!', error.message, context);
      });
    }
  }
}
