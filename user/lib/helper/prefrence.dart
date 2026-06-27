import 'package:shared_preferences/shared_preferences.dart';

class Preference {
  static final Preference preference = Preference();
  Future<bool> saveString(String key, String value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(key, value);
  }

  Future<String?> getString(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  getString_new(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  Future<bool> saveBool(String key, bool value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setBool(key, value);
  }

  Future<bool?> getBool({String? key, bool? defVal}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(key!) ?? defVal;
  }

  Future<bool> saveInt(String key, int value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setInt(key, value);
  }

  Future<int?> getInt(String? key, int? defVal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key!) ?? defVal;
  }

  Future<bool> saveStringList(String key, List<String> value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getStringList(key);
  }
}

class prefrenceKey {
  static String isLogin = 'Login';
  static String isaccresstoken = 'Accesstoken';
  static String userid = 'Userid';
  static String devicetoken = 'Devicetoken';
  static String cartdata = 'Cartdata';
}
