/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ioskitouchnew/models/home.dart';


class SharedPreference {
  Future<bool> putString(String key, String string) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, string);
    return prefs.commit();
  }

  Future<bool> putStringList(String key,List<dynamic> string)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, string);
    return prefs.commit();
  }

  Future<bool> putBool(String key, bool string) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, string);
    return prefs.commit();
  }

  Future<bool> putInt(String key, int val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, val);
    return prefs.commit();
  }

  Future<bool> getBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.
    getInstance();
    bool string = prefs.getBool(key);
    return string;
  }

  Future<String> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String string = prefs.getString(key);
    return string;
  }

  Future<List> getStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List string = prefs.getStringList(key);
    return string;
  }


  Future<int> getInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int val = prefs.getInt(key);
    return val;
  }

  Future<bool> clearData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.get(key);
    prefs.clear();
    return true;
  }

  Future<bool> removeValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
    return true;
  }

  Future<bool> clearDataOnLogout() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove(SharedKey().BASIC_AUTH);
    prefs.clear();
    return true;
  }
}
