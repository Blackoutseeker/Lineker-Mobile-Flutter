abstract class IThemeStore {
  bool isDark = false;
  Future<void> changeTheme(bool value);
}
