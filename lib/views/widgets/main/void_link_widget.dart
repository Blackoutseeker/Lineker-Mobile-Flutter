import 'package:flutter/material.dart';

class VoidLinkWidget extends StatelessWidget {
  const VoidLinkWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 40),
          const Text(
            'No link found!',
            style: TextStyle(
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
          const Text(
            'Add a link to get started!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
