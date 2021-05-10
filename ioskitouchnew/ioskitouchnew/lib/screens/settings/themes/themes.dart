/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */
import 'package:flutter/material.dart';
import 'package:ioskitouchnew/FlutterApp.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/screens/settings/themes/themesView.dart';

class Themes extends StatefulWidget{
  static final String tag = 'Themes';
  @override
  ThemesView createState()=>new ThemesView();
}

abstract class ThemesState extends State<Themes>{
  int setValue,themeVal;
  @protected
  Map<String, int> mapSet = new Map();
  SharedPreference pref = new SharedPreference();

  void onValue(int val,var id){
    print("val::val::id::$id");
    int qId = int.parse('$id');
    setState(() {
      setValue = val;
//      if (mapSet.containsKey(qId)) {
//        setValue = mapSet['$qId'];
//        print('setValue if ::$setValue');
//      } else {
        setValue = val;
        mapSet['$qId'] = val;
        print('setValue::$setValue');
        FlutterApp.themeValue = val;
        pref.putString(SharedKey().THEME_VALUE, "$val");
    //  }
      print("mapset::$mapSet");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pref.getString(SharedKey().THEME_VALUE).then((val){
      if(val!=null) {
        themeVal = int.parse(val);
        setState(() {
          setValue = themeVal;
        });
        print("themeVal::$themeVal");
      }else{
        setValue = 1;
      }
    });
  }

  void onSelectedTheme(Brightness dark) {
    new ThemeData(
      brightness:Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark,
        primaryColor: Theme.of(context).primaryColor == Colors.black? Colors.white: Colors.black
    );
  }
}
