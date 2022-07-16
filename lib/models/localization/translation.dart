abstract class Translation {
  final String slogan = '';
  final String passwordRule = '';
  final String voidLink = '';
  final String addLink = '';
  final String voidHistory = '';
  final String switchTheme = '';
  final String cameraPermission = '';

  final Map<String, dynamic> button = {
    'forgot_password': '',
    'sign_in': '',
    'sign_up': '',
    'sign_in_with_google': '',
    'accept_policy_privacy1': '',
    'accept_policy_privacy2': '',
    'accept_terms_of_use1': '',
    'accept_terms_of_use2': '',
    'dont_have_account': '',
    'have_account': '',
    'save_to_gallery': '',
    'open_link': '',
    'save_link': '',
    'copy_link': '',
    'add_link': '',
  };

  final Map<String, dynamic> titles = {
    'filters': '',
    'history': '',
  };

  final Map<String, dynamic> placeholder = {
    'email': '',
    'password': '',
    'search': '',
    'add_link_title': '',
    'add_link_url': '',
    'add_filter': '',
  };

  final Map<String, dynamic> snackbar = {
    'launch_url': '',
    'copy_url': '',
    'qr_saved': '',
    'storage_permission': '',
  };

  final Map<String, dynamic> dialog = {
    'accept_privacy_policy': '',
    'title': '',
    'filter_content': '',
    'history_content': '',
    'buttons': {
      'yes': '',
      'no': '',
    },
  };

  final Map<String, dynamic> drawer = {
    'history': '',
    'web_version': '',
    'about': '',
    'sign_out': '',
  };
}
