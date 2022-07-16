import 'package:mobx/mobx.dart';

import '../services/localization.dart';

part 'localization_store.g.dart';

class LocalizationStore = LocalizationStoreModel with _$LocalizationStore;

abstract class LocalizationStoreModel with Store {
  @observable
  Localization localization = Localization.instance;

  @action
  void setCurrentLocale(String localeName) {
    localization.currentLocale = localeName;
  }
}
