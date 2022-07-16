import 'package:flutter/material.dart';

import '../widgets/login/logo_content_widget.dart';
import '../widgets/login/login_form_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFF005884),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                LogoContentWidget(),
                const LoginFormWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
