abstract class IFilterStore {
  String filter = 'Default';
  Future<void> changeFilter(String filter);
}
