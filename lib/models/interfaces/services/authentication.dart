import 'package:flutter/material.dart';

abstract class IAuthentication {
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  });

  Future<void> signInWithGoogle(BuildContext context);

  Future<void> signUp({
    required String email,
    required String password,
    required BuildContext context,
  });

  Future<void> signOut(BuildContext context);
  Future<void> resetPassword(String email, BuildContext context);
}
