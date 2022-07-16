import 'package:mobx/mobx.dart';
import '../../models/interfaces/stores/user_store.dart';
import '../../models/database/user_model.dart';
part 'user_store.g.dart';

class UserStore = UserStoreModel with _$UserStore;

abstract class UserStoreModel with Store implements IUserStore {
  @observable
  @override
  UserModel user = UserModel(email: null, id: null);

  @action
  @override
  void signInUser(String email, String id) {
    user = UserModel(email: email, id: id);
  }

  @action
  @override
  void signOutUser() {
    user = UserModel(email: null, id: null);
  }
}
