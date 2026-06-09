import 'package:creatoo/core.dart';

import '../../features/verify_otp/model/verify_otp_model.dart';

class SharedPreferencesService {
  static SharedPreferences? _preferences;

  /// Initialize SharedPreferences once before using any method
  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  Future<bool?> deleteAll({skip = true}) async {
    await init();
    bool? isDeleted = await _preferences?.clear();
    await saveOnboarding(skip);
    return isDeleted;
  }

  Future<void> saveToken(String token) async {
    await init();
    await _preferences!.setString('token', token);
  }

  Future<String?> getToken() async {
    await init();
    return _preferences!.getString('token');
  }

  Future<void> clearToken() async {
    await init();
    await _preferences!.remove('token');
  }

  Future<void> saveUserRoleId(int user) async {
    await init();
    await _preferences!.setInt('roleId', user);
  }

  Future<int?> getUserRoleId() async {
    await init();
    return _preferences!.getInt('roleId');
  }

  Future<void> clearUserRoleId() async {
    await init();
    await _preferences!.remove('roleId');
  }

  Future<void> saveLogin(bool isLogin) async {
    await init();
    await _preferences!.setBool('isLogin', isLogin);
  }

  Future<bool?> getLogin() async {
    await init();
    return _preferences!.getBool('isLogin');
  }

  Future<void> clearLogin() async {
    await init();
    await _preferences!.remove('isLogin');
  }

  Future<void> saveFcmToken(String token) async {
    await init();
    await _preferences!.setString('fcmToken', token);
  }

  Future<String?> getFcmToken() async {
    await init();
    return _preferences!.getString('fcmToken');
  }

  Future<void> clearFcmToken() async {
    await init();
    await _preferences!.remove('fcmToken');
  }

  Future<void> saveUserId(int userId) async {
    await init();
    await _preferences!.setInt('userId', userId);
  }

  Future<int?> getUserId() async {
    await init();
    return _preferences!.getInt('userId');
  }

  Future<void> clearUserId() async {
    await init();
    await _preferences!.remove('userId');
  }

  Future<void> saveOnboarding(bool isOnboarded) async {
    await init();
    await _preferences!.setBool('isOnboarded', isOnboarded);
  }

  Future<bool?> getOnboarding() async {
    await init();
    return _preferences!.getBool('isOnboarded');
  }

  Future<void> clearOnboarding() async {
    await init();
    await _preferences!.remove('isOnboarded');
  }

  Future<void> saveUserData(UserData userData, {bool skip = false}) async {
    await init();
    updateGlobal(userData, skip: skip);
    await _preferences!.setString('userData', jsonEncode(userData));
  }

  Future<UserData?> getUserData() async {
    await init();
    String? data = _preferences!.getString('userData');
    UserData? userData = data == null ? null : UserData.fromCreatorJson(jsonDecode(data));
    return userData;
  }

  Future<void> clearUserData() async {
    await init();
    await _preferences!.remove('userData');
  }

  void updateGlobal(UserData userData, {bool skip = false}) async {
    token = userData.token;
    userId = userData.id;
    roleId = userData.roleId;
    user = userData;
    if (!skip) {
      await saveToken(userData.token!);
      await saveUserId(userData.id!);
      if (userData.roleId != null) {
        await saveUserRoleId(userData.roleId!);
      }
    }
  }

  Future<void> saveProfileUpdatedDate(String value) async {
    await init();
    await _preferences!.setString('updated_at', value);
  }

  Future<String?> getProfileUpdatedDate() async {
    await init();
    return _preferences!.getString('updated_at');
  }

  Future<void> clearProfileUpdatedDate() async {
    await init();
    await _preferences!.remove('updated_at');
  }
}
