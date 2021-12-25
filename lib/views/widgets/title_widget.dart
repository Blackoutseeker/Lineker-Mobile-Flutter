import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({Key? key, required this.textSize}) : super(key: key);

  final double textSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: textSize,
        ),
        children: <TextSpan>[
          const TextSpan(
            text: 'Lin',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
            ),
          ),
          TextSpan(
            text: 'e',
            style: TextStyle(
              color: Theme.of(context).textTheme.headline3?.color,
            ),
          ),
          const TextSpan(
            text: 'k',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
            ),
          ),
          TextSpan(
            text: 'er',
            style: TextStyle(
              color: Theme.of(context).textTheme.headline3?.color,
            ),
          ),
        ],
      ),
    );
  }
}
