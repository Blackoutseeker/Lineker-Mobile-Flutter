import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/shared_preferences/storaged_values.dart';
import '../../models/interfaces/stores/theme_store.dart';
part 'theme_store.g.dart';

class ThemeStore = _ThemeStore with _$ThemeStore;

abstract class _ThemeStore with Store implements IThemeStore {
  @observable
  @override
  bool isDark = false;

  @action
  @override
  Future<void> changeTheme(bool value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences
        .setBool(StoragedValues.isDark, value)
        .then((_) => isDark = value);
  }
}
