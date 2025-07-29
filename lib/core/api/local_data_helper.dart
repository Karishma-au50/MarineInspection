
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/user_model.dart';


class LocalDataHelper {
  late SharedPreferences _prefs;
  final String loginKey = 'isLoggedIn';
  final String userKey = 'userKey';
  // auth operations
  Future<void> setLoginStatus(bool status) async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setBool(loginKey, status);
  }

  Future<bool> getLoginStatus() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getBool(loginKey) ?? false;
  }

  Future<UserModel> getUserId() async {
    _prefs = await SharedPreferences.getInstance();
    return UserModel.fromJson(jsonDecode(_prefs.getString(userKey)!));
  }

  Future<void> setUserId(UserModel user) async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setString(userKey, jsonEncode(user.toJson()));
  }
}
