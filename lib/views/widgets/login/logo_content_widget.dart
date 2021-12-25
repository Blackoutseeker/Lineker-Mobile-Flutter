import 'package:flutter/material.dart';

import '../../../views/widgets/title_widget.dart';

class LogoContentWidget extends StatelessWidget {
  const LogoContentWidget({Key? key}) : super(key: key);

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
        const SizedBox(
          width: 250,
          child: Text(
            'Access links between your devices',
            textAlign: TextAlign.center,
            style: TextStyle(
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
