import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../model/user_model.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();
  factory StorageService() => instance;

  SharedPreferences? _preferences;

  Future<SharedPreferences> init() async =>
      _preferences = await SharedPreferences.getInstance();

  Future<void> setString(String key, String value) async =>
      _preferences!.setString(key, value);

  String? getString(String key) => _preferences!.getString(key);

  // set token
  Future<void> setToken(String value) async =>
      _preferences!.setString('token', value);

  // get token
  String? getToken() => _preferences?.getString('token');

  // add more methods here
  UserModel? getUserId() {
    var val = _preferences!.getString('userKey');
    print("Called getUserId");
    if (val != null) {
      return UserModel.fromJson(jsonDecode(val));
    } else {
      return null;
    }
  }

  Future<void> setUserId(UserModel user) async {
    _preferences?.setString('userKey', jsonEncode(user.toJson()));
  }

  Future<void> clear() async {
    await _preferences!.clear();
    await _preferences!.reload();
  }
}
