import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../controllers/services/authentication.dart';
import '../../../controllers/services/localization.dart';
import '../../../controllers/stores/localization_store.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({Key? key}) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Authentication _authentication = Authentication.instance;
  final Localization _localization =
      GetIt.I.get<LocalizationStore>().localization;

  bool _hidePassword = true;
  bool _createAccount = false;
  bool _hasAcceptedThePrivacyPolicy = false;
  bool _hasAcceptedTheTermsOfUse = false;

  void _changePasswordVisibility() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  void _switchCreateAccountState() {
    FocusScope.of(context).unfocus();
    setState(() {
      _createAccount = !_createAccount;
      _hasAcceptedThePrivacyPolicy = false;
      _hasAcceptedTheTermsOfUse = false;
    });
  }

  void _switcHasAcceptedThePrivacyPolicyState() {
    setState(() {
      _hasAcceptedThePrivacyPolicy = !_hasAcceptedThePrivacyPolicy;
    });
  }

  void _switcHasAcceptedTheTermsOfUseState() {
    setState(() {
      _hasAcceptedTheTermsOfUse = !_hasAcceptedTheTermsOfUse;
    });
  }

  void _signIn() {
    FocusScope.of(context).unfocus();
    _authentication.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
      context: context,
    );
  }

  void _notifyUserAboutPolicyPrivacyAndTermsOfUse() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(
          _localization.translation.dialog['accept_privacy_policy'],
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  void _createNewUser() {
    FocusScope.of(context).unfocus();

    if (_hasAcceptedThePrivacyPolicy && _hasAcceptedTheTermsOfUse) {
      _authentication.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        context: context,
      );
    } else {
      _notifyUserAboutPolicyPrivacyAndTermsOfUse();
    }
  }

  Future<void> _openUrl(String url) async {
    await launchUrlString(url);
  }

  void _handleButtonPress() {
    if (!_createAccount || _passwordController.text.length >= 6) {
      if (_createAccount) {
        _createNewUser();
      } else {
        _signIn();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: <Widget>[
            TextFormField(
              cursorColor: const Color(0xFFFFFFFF),
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              onEditingComplete: FocusScope.of(context).nextFocus,
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFFFFFFFF),
              ),
              decoration: InputDecoration(
                hintText: _localization.translation.placeholder['email'],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: 5,
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                prefixIcon: const Icon(
                  Icons.email,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 15),
            if (!_createAccount)
              TextFormField(
                cursorColor: const Color(0xFFFFFFFF),
                keyboardType: TextInputType.visiblePassword,
                controller: _passwordController,
                obscureText: _hidePassword,
                onEditingComplete: _signIn,
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFFFFFFFF),
                ),
                decoration: InputDecoration(
                  hintText: _localization.translation.placeholder['password'],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 2,
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      style: BorderStyle.solid,
                      color: Color(0xFFFFFFFF),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock,
                    size: 30,
                  ),
                  suffixIcon: IconButton(
                    highlightColor: Colors.transparent,
                    onPressed: _changePasswordVisibility,
                    icon: Icon(
                      _hidePassword ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF003048),
                      size: 30,
                    ),
                  ),
                ),
              ),
            if (_createAccount)
              Text(
                _localization.translation.passwordRule,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 15,
                ),
              ),
            const SizedBox(height: 15),
            if (!_createAccount)
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  highlightColor: Colors.transparent,
                  onTap: () => _authentication.resetPassword(
                      _emailController.text, context),
                  child: Text(
                    _localization.translation.button['forgot_password'],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            if (_createAccount)
              TextFormField(
                cursorColor: const Color(0xFFFFFFFF),
                keyboardType: TextInputType.visiblePassword,
                controller: _passwordController,
                obscureText: _hidePassword,
                onEditingComplete: _createNewUser,
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFFFFFFFF),
                ),
                decoration: InputDecoration(
                  hintText: _localization.translation.placeholder['password'],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 2,
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      style: BorderStyle.solid,
                      color: Color(0xFFFFFFFF),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock,
                    size: 30,
                  ),
                  suffixIcon: IconButton(
                    onPressed: _changePasswordVisibility,
                    highlightColor: Colors.transparent,
                    icon: Icon(
                      _hidePassword ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF003048),
                      size: 30,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 15),
            if (_createAccount)
              FittedBox(
                child: SizedBox(
                  height: 40,
                  child: TextButton(
                    onPressed: _switcHasAcceptedThePrivacyPolicyState,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Row(
                        children: <Widget>[
                          Radio(
                            groupValue: true,
                            value: _hasAcceptedThePrivacyPolicy,
                            onChanged: (_) =>
                                _switcHasAcceptedThePrivacyPolicyState(),
                          ),
                          Text(
                            _localization
                                .translation.button['accept_policy_privacy1'],
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openUrl(
                                'https://drive.google.com/file/d/1q7GrBEzORsehR6QjHI02b7OSki1llDCP/view'),
                            child: Text(
                              _localization
                                  .translation.button['accept_policy_privacy2'],
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_createAccount) const SizedBox(height: 15),
            if (_createAccount)
              FittedBox(
                child: SizedBox(
                  height: 40,
                  child: TextButton(
                    onPressed: _switcHasAcceptedTheTermsOfUseState,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Row(
                        children: <Widget>[
                          Radio(
                            groupValue: true,
                            value: _hasAcceptedTheTermsOfUse,
                            onChanged: (_) =>
                                _switcHasAcceptedTheTermsOfUseState(),
                          ),
                          Text(
                            _localization
                                .translation.button['accept_terms_of_use1'],
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openUrl(
                                'https://drive.google.com/file/d/1I2HiAlGYECNKSL7nvRh6Oui9fvk6kIpS/view'),
                            child: Text(
                              _localization
                                  .translation.button['accept_terms_of_use2'],
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_createAccount) const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ElevatedButton(
                  onPressed: _handleButtonPress,
                  child: Text(
                    !_createAccount
                        ? _localization.translation.button['sign_in']
                        : _localization.translation.button['sign_up'],
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ElevatedButton.icon(
                  onPressed: () => _authentication.signInWithGoogle(
                    context,
                    mounted,
                  ),
                  icon: const FaIcon(
                    FontAwesomeIcons.google,
                    color: Color(0xFF333333),
                  ),
                  label: Text(
                    _localization.translation.button['sign_in_with_google'],
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            InkWell(
              highlightColor: Colors.transparent,
              onTap: _switchCreateAccountState,
              child: Text(
                !_createAccount
                    ? _localization.translation.button['dont_have_account']
                    : _localization.translation.button['have_account'],
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
