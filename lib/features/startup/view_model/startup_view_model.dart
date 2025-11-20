import 'package:creatoo/core.dart';

class StartupViewModel with ChangeNotifier {
  final SharedPreferencesService _preferencesService = SharedPreferencesService();
  bool? isUserLoggedIn;

  void saveUser(int role) async {
    roleId = role;
    await _preferencesService.saveUserRoleId(role);
    notifyListeners();
  }

  void checkUserLogIn() async {
    var myToken = await _preferencesService.getToken();

    if (myToken != null) {
      token = myToken;
      userId = await _preferencesService.getUserId();
      roleId = await _preferencesService.getUserRoleId();
      user = await _preferencesService.getUserData();
      if (kDebugMode) {
        print("UserId : $userId\nRoleId : $roleId\nJWT Token : $myToken\n\n");
      }

      isUserLoggedIn = true;
      Navigator.popUntil(navigatorKey.currentContext!, (route) => route.isFirst);
    } else {
      isUserLoggedIn = false;
    }
    notifyListeners();
  }
}
