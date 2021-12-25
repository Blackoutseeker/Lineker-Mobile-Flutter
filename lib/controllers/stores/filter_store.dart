import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/interfaces/stores/filter_store.dart';
import '../../models/shared_preferences/storaged_values.dart';
part 'filter_store.g.dart';

class FilterStore = _FilterStore with _$FilterStore;

abstract class _FilterStore with Store implements IFilterStore {
  @observable
  @override
  String filter = 'Default';

  @action
  @override
  Future<void> changeFilter(String filter) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences
        .setString(StoragedValues.filter, filter)
        .then((_) => this.filter = filter);
  }
}
