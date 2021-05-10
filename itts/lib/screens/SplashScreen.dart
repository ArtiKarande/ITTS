/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:itts/login/login.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'DashboardGrid.dart';
import 'searchTemperature.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPreferences _preferences;
  String userId = '';

  @override
  void initState() {

    preferencesUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.BUTTON_TEXT_COLOR,
        body: Center(
          child: new Container(
            child: Text("ITTS",style: TextStyle(color: AppTheme.WHITE_COLOR,fontSize: 45,fontWeight: FontWeight.bold),),
          ),
        ));
  }

  void preferencesUserId() async{
    _preferences = await SharedPreferences.getInstance();

    setState(() {

      userId = _preferences.getString("user_id");
      print("value =$userId");

    });
    if (userId != null) {
      Future.delayed(Duration(seconds: 1), () {

        Navigator.pop(context);

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Dashboard()));    // Dashboard  MyAppNew
      });
    } else {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Login())); //LoginOption
      });
    }
  }



}
