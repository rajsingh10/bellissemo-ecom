import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../ui/login/modal/loginModal.dart';

class SaveDataLocal {
  static SharedPreferences? prefs;
  static String userData = 'UserData';

  static saveLogInData(LoginModal logindata) async {
    prefs = await SharedPreferences.getInstance();
    String json = jsonEncode(logindata.toJson());
    await prefs?.setString(userData, json);
    print('dataStoared');
  }

  static getDataFromLocal() async {
    prefs = await SharedPreferences.getInstance();
    String? userString = prefs?.getString(userData);
    if (userString != null) {
      Map<String, dynamic> userMap = jsonDecode(
        userString,
      ); // Specify the type here
      LoginModal user = LoginModal.fromJson(userMap);
      return user;
    } else {
      return null;
    }
  }

  static clearUserData() async {
    prefs = await SharedPreferences.getInstance();
    log('Data Cleared');
    prefs?.clear();
  }
}
