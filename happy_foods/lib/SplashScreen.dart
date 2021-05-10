/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:happyfoods/Admin/adminDashboard.dart';
import 'package:happyfoods/Dashboard/DashboardTab.dart';
import 'package:happyfoods/productionHouse/productionDashboard.dart';
import 'package:happyfoods/utils/StyleColor.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

import 'login/LoginOption.dart';
import 'login/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPreferences _preferences;
  String userId = '',roleId = '';

  @override
  void initState() {
    preferencesUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.BUTTON_TEXT_COLOR,
        body: /*Center(
          child: new Container(
            child: Text("Hashtag Happy Foods",style: TextStyle(color: AppTheme.WHITE_COLOR,fontSize: 45,fontWeight: FontWeight.bold),),
          ),
        ));*/

        Stack(
          children: <Widget>[
            new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage('images/doodle.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: new BackdropFilter(
                filter: new ImageFilter.blur(
                  sigmaX: 0,
                  sigmaY: 0,
                ),
                child: new Container(
                  decoration: new BoxDecoration(
                    color: AppTheme.BUTTON_TEXT_COLOR.withOpacity(0.5),
                  ),
                ),
              ),
            ),

            Center(
              child: Text("Hashtag Happy Foods",style: TextStyle(color: AppTheme.WHITE_COLOR,fontSize: 45,fontWeight: FontWeight.bold),),
            ),
          ],
        ));
  }

  void preferencesUserId() async{
    _preferences = await SharedPreferences.getInstance();

    setState(() {

      userId = _preferences.getString("user_id");
      roleId = _preferences.getString("roleId");
      print("pref user_id = $userId");
      print(roleId);

    });
    if (userId != null) {
      Future.delayed(Duration(seconds: 1), () {

        Navigator.pop(context);

        if(roleId == '2'){
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DashboardTab(0)));
        }else if(roleId == '1'){
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AdminDashboard()));
        }else{
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProductionDashboard()));
        }

      });
    } else {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => LoginOption())); //LoginOption
      });
    }
  }
}
