import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  static setUserName(String userName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("USERNAME", userName);
  }

  static getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("USERNAME") ?? "";
  }

  static setPassword(String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("PASSWORD", password);
  }

  static getPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("PASSWORD") ?? "";
  }
}
