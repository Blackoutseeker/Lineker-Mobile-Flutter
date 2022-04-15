import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static Constants instance = Constants();

  String get bannerAdUnitId =>
      dotenv.env['BANNER_AD_UNIT_ID'] ??
      'ca-app-pub-3940256099942544/6300978111';
}
