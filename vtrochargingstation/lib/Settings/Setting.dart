/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:vtrochargingstation/Settings/SettingView.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/app_theme.dart';

class Settings extends StatefulWidget {
  @override
  SettingView createState() => SettingView();
}

abstract class SettingsState extends State<Settings> {

  @protected
  APICall apiCall = APICall();
  AppTheme utils = new AppTheme();

}
