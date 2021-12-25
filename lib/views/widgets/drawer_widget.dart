import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/stores/user_store.dart';
import '../../controllers/stores/theme_store.dart';
import '../../controllers/services/authentication.dart';

class DrawerWidget extends StatelessWidget {
  DrawerWidget({Key? key}) : super(key: key);

  final UserStore _userStore = GetIt.I.get<UserStore>();
  final ThemeStore _themeStore = GetIt.I.get<ThemeStore>();
  final Authentication _authentication = Authentication.instance;

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
            title: const Text(
              'Switch theme',
              style: TextStyle(
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
            onTap: () async => await launch('https://lineker.vercel.app'),
            leading: const Icon(
              Icons.web,
              color: Color(0xFFFFFFFF),
              size: 28,
            ),
            title: const Text(
              'Web version',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              showAboutDialog(
                context: context,
                applicationIcon: Image.asset(
                  'assets/images/Lineker Logo.png',
                  height: 50,
                ),
                applicationLegalese: '© 2021 Felip\'s Tudio',
                applicationName: 'Lineker',
                applicationVersion: 'v2.1.3',
              );
            },
            leading: const Icon(
              Icons.info_outline,
              color: Color(0xFFFFFFFF),
              size: 28,
            ),
            title: const Text(
              'About the app',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            onTap: () async => await _authentication.signOut(context),
            leading: const Icon(
              Icons.logout,
              color: Color(0xFFFFFFFF),
              size: 28,
            ),
            title: const Text(
              'Sign out',
              style: TextStyle(
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
