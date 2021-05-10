/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itts/screens/AlertDialog.dart';
import 'package:itts/screens/SplashScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) async{
        print("msg::: onLaunch called ${(msg)}");
        print("onLaunch called");
      },
      onResume: (Map<String, dynamic> msg) async{
        print("msg::: onResume called ${(msg)}"); //when we click on notification

        final notification = msg['data'];
        setState(() {

          showDialog(
            context: context,
            builder: (_) => FunkyOverlay(
              title:notification['title'],
              msg: notification['body'],
            ),
          );
        });

      },
      onMessage: (Map<String, dynamic> msg) async{

        print("msg11::: onMessage called ${(msg)}");
        final notification = msg['notification'];
        setState(() {
          showDialog(
            context: context,
            builder: (_) => FunkyOverlay(
              title:notification['title'],
              msg: notification['body'],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ITTS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: SplashScreen(), // Demo(),    SplashScreen

      //   Login(),
    );
  }
}
