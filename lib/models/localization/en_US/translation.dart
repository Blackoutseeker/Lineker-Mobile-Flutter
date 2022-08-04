import '../translation.dart';

class TranslationEnUs implements Translation {
  @override
  final String slogan = 'Access links between your devices';
  @override
  final String passwordRule = 'The password must have 6 or more characters';
  @override
  final String voidLink = 'No link found!';
  @override
  final String addLink = 'Add a link to get started!';
  @override
  final String voidHistory = 'No recent activity to show here!';
  @override
  final String switchTheme = 'Switch theme';
  @override
  final String cameraPermission = 'Grant camera permission';

  @override
  final Map<String, dynamic> button = {
    'forgot_password': 'Forgot your password?',
    'sign_in': 'Sign in',
    'sign_up': 'Sign up',
    'sign_in_with_google': 'Sign in with Google',
    'accept_policy_privacy1': 'I have read and agree to the ',
    'accept_policy_privacy2': 'Policy Privacy',
    'accept_terms_of_use1': 'I have read and agree to the ',
    'accept_terms_of_use2': 'Terms of Use',
    'dont_have_account': 'Don\'t have an account? Do it now!',
    'have_account': 'Have an account? So, sign in!',
    'save_to_gallery': 'SAVE TO GALLERY',
    'open_link': 'Open link',
    'save_link': 'Save link',
    'copy_link': 'Copy link',
    'add_link': 'Add link',
  };

  @override
  final Map<String, dynamic> titles = {
    'filters': 'Filters',
    'history': 'History',
  };

  @override
  final Map<String, dynamic> placeholder = {
    'email': 'Email',
    'password': 'Password',
    'search': 'Title, URL, date...',
    'add_link_title': 'Title',
    'add_link_url': 'URL',
    'add_filter': 'Filter',
  };

  @override
  final Map<String, dynamic> snackbar = {
    'launch_url': 'Can\'t open this URL!',
    'copy_url': 'URL copied to the clipboard!',
    'qr_saved': 'QR code saved in gallery!',
    'storage_permission':
        'Unable to save QR code! Have you given permission for storage?',
  };

  @override
  final Map<String, dynamic> dialog = {
    'accept_privacy_policy':
        'You must accept the Privacy Policy and Terms of Use to create an account!',
    'title': 'Are you sure?',
    'filter_content': 'All your links within this filter will be deleted!',
    'history_content':
        'This will delete the entire timeline from your history!',
    'buttons': {
      'yes': 'Yes',
      'no': 'No',
    },
  };

  @override
  final Map<String, dynamic> drawer = {
    'history': 'History',
    'web_version': 'Web version',
    'about': 'About the app',
    'sign_out': 'Sign out',
  };
}
