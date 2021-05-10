/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:happyfoods/Dashboard/DashboardTab.dart';
import 'package:happyfoods/bloc_pattern.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:provider/provider.dart';
import 'Dashboard/imgdemo.dart';
import 'SplashScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  /// This widget is the root of your happyfood application.

  @override
  _MyAppState createState() => _MyAppState();
}




class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StateProviderManagement>.value(
      notifier: StateProviderManagement(),
      child: MaterialApp(
        title: 'HappyFoods',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,

        ),
        home: SplashScreen(), //  DashboardTab  SplashScreen

        //   Login(),
      ),
    );
  }
}
