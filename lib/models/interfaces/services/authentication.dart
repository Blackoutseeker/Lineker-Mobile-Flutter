import 'package:flutter/material.dart';

abstract class IAuthentication {
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  });

  Future<void> signInWithGoogle(BuildContext context, bool mounted);

  Future<void> signUp({
    required String email,
    required String password,
    required BuildContext context,
  });

  Future<void> signOut(BuildContext context, bool mounted);
  Future<void> resetPassword(String email, BuildContext context);
}
