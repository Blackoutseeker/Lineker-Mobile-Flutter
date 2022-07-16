import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/services/localization.dart';
import '../../../controllers/stores/localization_store.dart';

class VoidLinkWidget extends StatelessWidget {
  VoidLinkWidget({Key? key}) : super(key: key);

  final Localization _localization =
      GetIt.I.get<LocalizationStore>().localization;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 40),
          Text(
            _localization.translation.voidLink,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),
          Image.asset(
            'assets/images/Drawer.png',
            height: 100,
          ),
          const SizedBox(height: 20),
          Text(
            _localization.translation.addLink,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
