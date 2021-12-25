import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/interfaces/services/load.dart';
import '../../models/shared_preferences/storaged_values.dart';

import '../stores/user_store.dart';
import '../stores/theme_store.dart';
import '../stores/filter_store.dart';

class Load implements ILoad {
  static final Load instance = Load();

  @override
  Future<void> loadUser(BuildContext context) async {
    final UserStore userStore = GetIt.I.get<UserStore>();
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? userEmail = preferences.getString(StoragedValues.userEmail);
    final String? userUID = preferences.getString(StoragedValues.userUID);
    if (userEmail != null && userUID != null) {
      userStore.signInUser(userEmail, userUID);
    }
  }

  @override
  Future<void> loadTheme(BuildContext context) async {
    final ThemeStore themeStore = GetIt.I.get<ThemeStore>();
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool? isDark = preferences.getBool(StoragedValues.isDark);
    await themeStore.changeTheme(isDark ?? false);
  }

  Future<void> loadFilter(BuildContext context) async {
    final FilterStore filterStore = GetIt.I.get<FilterStore>();
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? filter = preferences.getString(StoragedValues.filter);
    await filterStore.changeFilter(filter ?? 'Default');
  }
}
