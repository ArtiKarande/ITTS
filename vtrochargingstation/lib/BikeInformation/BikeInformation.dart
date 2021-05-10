/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:vtrochargingstation/BikeInformation/BikeInformationView.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedPreferneces.dart';

/// old design code
/// not in used

class BikeInformation extends StatefulWidget {

  String pageRedirect;
  BikeInformation(this.pageRedirect);

  @override
  BikeInformationView createState() => BikeInformationView();
}

abstract class BikeInformationState extends State<BikeInformation> {

  AppTheme utils = new AppTheme();
  //APICall apiCall = new APICall();
  SharedPreference pref = new SharedPreference();
}
