/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/common/StringConstants.dart';
import 'package:ioskitouchnew/screens/settings/themes/customTheme.dart';
import 'package:ioskitouchnew/screens/settings/themes/themes.dart';
import 'package:ioskitouchnew/screens/settings/themes/themesKeys.dart';

import '../../../FlutterApp.dart';

class ThemesView extends ThemesState {

  void _changeTheme(BuildContext buildContext, MyThemeKeys key) {
    CustomTheme.instanceOf(buildContext).changeTheme(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: new Text("Themes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
            textContainer(),
              radioList()
            ],
        ),
      ),
    );
  }
  Widget radioList() {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Container(
          child: new RadioListTile(
            value: 1,
            groupValue: setValue,
            onChanged: (val) {
              print("val:::${val}");
              onValue(val,1);
              _changeTheme(context, MyThemeKeys.DARK);
              // onSelectedTheme(Brightness.dark);
            },
            title: new Text(StringConstants.DARK_THEME),
          ),
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.06,
          alignment: Alignment.topCenter,
        ),
        new Container(
          child: new RadioListTile(
            value: 2,
            groupValue: setValue,
            onChanged: (val) {
              print("val:::${val}");
              onValue(val,2);
              _changeTheme(context, MyThemeKeys.LIGHT);
              // onSelectedTheme(Brightness.light);
            },
            title: new Text(StringConstants.LIGHT_THEME),
          ),
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.06,
          alignment: Alignment.topCenter,
        ),new Container(
          child: new RadioListTile(
            value: 3,
            groupValue: setValue,
            onChanged: (val) {
              print("val:::${val}");
              onValue(val,3);
              _changeTheme(context, MyThemeKeys.DARKER);
              // onSelectedTheme(Brightness.light);
            },
            title: new Text(StringConstants.DARKER_THEME),
          ),
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.06,
          alignment: Alignment.topCenter,
        )
      ],
    );
  }

  Widget textContainer(){
    return new Padding(padding: const EdgeInsets.only(left:0.0,top: 10.0),
    child: new Container(child: new Text("Personalize your app with following themes"),),);
  }
}