import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/services/localization.dart';
import '../../../controllers/stores/localization_store.dart';

class VoidHistory extends StatelessWidget {
  VoidHistory({Key? key}) : super(key: key);

  final Localization _localization =
      GetIt.I.get<LocalizationStore>().localization;

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 10,
      child: Text(
        _localization.translation.voidHistory,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 20,
        ),
      ),
    );
  }
}
