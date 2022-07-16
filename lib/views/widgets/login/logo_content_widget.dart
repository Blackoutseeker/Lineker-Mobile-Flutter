import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/services/localization.dart';
import '../../../controllers/stores/localization_store.dart';

import '../../../views/widgets/title_widget.dart';

class LogoContentWidget extends StatelessWidget {
  LogoContentWidget({Key? key}) : super(key: key);

  final Localization _localization =
      GetIt.I.get<LocalizationStore>().localization;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        const TitleWidget(textSize: 36),
        const SizedBox(height: 12),
        LimitedBox(
          maxWidth: 140,
          maxHeight: 140,
          child: Image.asset(
            'assets/images/Lineker Logo.png',
            alignment: Alignment.center,
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: 250,
          child: Text(
            _localization.translation.slogan,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}
