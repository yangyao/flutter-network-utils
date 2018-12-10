library network_utils;

import 'package:shared_preferences/shared_preferences.dart';

getCache(String key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return  await preferences.getString(key);
}


setCache(String key,value) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString(key, (value != null && value.length > 0) ? value : "");

}