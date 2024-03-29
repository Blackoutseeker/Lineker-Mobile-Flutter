import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import './controllers/stores/theme_store.dart';
import './controllers/stores/user_store.dart';
import './controllers/stores/filter_store.dart';
import './controllers/stores/localization_store.dart';

import './models/shared_preferences/storaged_values.dart';
import './models/themes/light_theme.dart';
import './models/themes/dark_theme.dart';
import './models/routes/app_routes.dart';

import './views/screens/login_screen.dart';
import './views/screens/main_screen.dart';
import './views/screens/filters_screen.dart';
import './views/screens/scan_screen.dart';
import './views/screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  await MobileAds.instance.initialize();

  final GetIt getIt = GetIt.I;
  getIt.registerLazySingleton<UserStore>(() => UserStore());
  getIt.registerLazySingleton<ThemeStore>(() => ThemeStore());
  getIt.registerLazySingleton<FilterStore>(() => FilterStore());
  getIt.registerLazySingleton<LocalizationStore>(() => LocalizationStore());

  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final String? isLogged = preferences.getString(StoragedValues.userUID);

  runApp(App(isLogged: isLogged));
}

class App extends StatelessWidget {
  App({Key? key, required this.isLogged}) : super(key: key);

  final String? isLogged;
  final ThemeStore theme = GetIt.I.get<ThemeStore>();
  final LocalizationStore localizationStore = GetIt.I.get<LocalizationStore>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    localizationStore.localization.currentLocale = Platform.localeName;

    return Observer(
      builder: (_) => MaterialApp(
        title: 'Lineker',
        themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
        theme: LightTheme().lightThemeData,
        darkTheme: DarkTheme().darkThemeData,
        localizationsDelegates: const [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('pt', 'BR'),
        ],
        home: isLogged == null ? const LoginScreen() : const MainScreen(),
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.main: (_) => const MainScreen(),
          AppRoutes.filters: (_) => const FiltersScreen(),
          AppRoutes.scan: (_) => const ScanScreen(),
          AppRoutes.history: (_) => const HistoryScreen(),
        },
      ),
    );
  }
}
