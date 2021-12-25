import '../../database/user_model.dart';

abstract class IUserStore {
  late UserModel user;
  void signInUser(String email, String id);
  void signOutUser();
}
