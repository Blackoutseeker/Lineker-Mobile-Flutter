import 'package:flutter/material.dart';

class VoidHistory extends StatelessWidget {
  const VoidHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      heightFactor: 10,
      child: Text(
        'No recent activity to show here!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 20,
        ),
      ),
    );
  }
}
