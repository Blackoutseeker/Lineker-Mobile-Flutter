import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../controllers/stores/user_store.dart';
import '../../controllers/stores/theme_store.dart';
import '../../controllers/stores/localization_store.dart';
import '../../controllers/services/localization.dart';
import '../../controllers/services/authentication.dart';

import '../../models/routes/app_routes.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final UserStore _userStore = GetIt.I.get<UserStore>();

  final ThemeStore _themeStore = GetIt.I.get<ThemeStore>();

  final Localization _localization =
      GetIt.I.get<LocalizationStore>().localization;

  final Authentication _authentication = Authentication.instance;

  void _navigateToHistoryScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.history);
  }

  void _showAboutTheAppDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationIcon: Image.asset(
        'assets/images/Lineker Logo.png',
        height: 50,
      ),
      applicationLegalese: '© 2022 Felip\'s Tudio',
      applicationName: 'Lineker',
      applicationVersion: 'v2.6.5',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 140,
            color: Theme.of(context).appBarTheme.backgroundColor,
            padding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/Lineker Logo.png',
                  height: 100,
                ),
                const SizedBox(height: 5),
                Observer(
                  builder: (_) => Text(
                    _userStore.user.email.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            onTap: () async =>
                await _themeStore.changeTheme(!_themeStore.isDark),
            leading: Observer(
              builder: (_) => Switch.adaptive(
                value: _themeStore.isDark,
                onChanged: _themeStore.changeTheme,
              ),
            ),
            title: Text(
              _localization.translation.switchTheme,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Divider(),
          ),
          ListTile(
            onTap: () => _navigateToHistoryScreen(context),
            leading: const Icon(
              Icons.history,
              color: Color(0xFFFFFFFF),
              size: 28,
            ),
            title: Text(
              _localization.translation.drawer['history'],
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            onTap: () async =>
                await launchUrlString('https://lineker.vercel.app'),
            leading: const Icon(
              Icons.web,
              color: Color(0xFFFFFFFF),
              size: 28,
            ),
            title: Text(
              _localization.translation.drawer['web_version'],
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            onTap: () => _showAboutTheAppDialog(context),
            leading: const Icon(
              Icons.info_outline,
              color: Color(0xFFFFFFFF),
              size: 28,
            ),
            title: Text(
              _localization.translation.drawer['about'],
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            onTap: () async => await _authentication.signOut(context, mounted),
            leading: const Icon(
              Icons.logout,
              color: Color(0xFFFFFFFF),
              size: 28,
            ),
            title: Text(
              _localization.translation.drawer['sign_out'],
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
