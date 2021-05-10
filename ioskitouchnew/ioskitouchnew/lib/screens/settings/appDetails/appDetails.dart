/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/screens/settings/appDetails/AppDetailsView.dart';
import 'package:package_info/package_info.dart';

/// to get current version of app and project package name

class AppDetails extends StatefulWidget{
  static final String tag = 'appDetails';
  @override
  AppDetailsView createState()=> new AppDetailsView();
}

abstract class AppDetailsState extends State<AppDetails>{
  String version;

  getCurrentVersionOFApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    setState(() {
      version = packageInfo.version;
    });
    String buildNumber = packageInfo.buildNumber;
    print(
        "appName:${appName}:packageName:${packageName}:version:${version}:buildNumber:${buildNumber}");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentVersionOFApp();
  }
}