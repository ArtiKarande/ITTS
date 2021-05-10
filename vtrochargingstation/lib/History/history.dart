/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:vtrochargingstation/History/historyView.dart';
import 'package:vtrochargingstation/common/app_theme.dart';

class History extends StatefulWidget {
  @override
  HistoryView createState() => HistoryView();
}

abstract class HistoryState extends State<History> {

  AppTheme utils = new AppTheme();

}
