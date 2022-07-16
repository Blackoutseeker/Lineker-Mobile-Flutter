import '../../models/localization/translation.dart';
import '../../models/localization/en_US/translation.dart';
import '../../models/localization/pt_BR/translation.dart';

class Localization {
  static final Localization instance = Localization();

  String _currentLocale = 'en_US';
  final List<String> _supportedLocales = const [
    'en_US',
    'pt_BR',
  ];

  set currentLocale(String localeName) => _currentLocale = localeName;

  List<String> get supportedLocales => _supportedLocales;

  Translation get translation {
    if (_supportedLocales.contains(_currentLocale)) {
      if (_currentLocale == _supportedLocales[0]) {
        return TranslationEnUs();
      } else if (_currentLocale == _supportedLocales[1]) {
        return TranslationPtBr();
      }
    }
    return TranslationEnUs();
  }
}
