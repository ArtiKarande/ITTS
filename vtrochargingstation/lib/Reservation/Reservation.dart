/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:vtrochargingstation/Reservation/ReservationView.dart';
import 'package:vtrochargingstation/common/app_theme.dart';

class Reservation extends StatefulWidget {
  @override
  ReservationView createState() => ReservationView();
}

abstract class ReservationState extends State<Reservation> {
  AppTheme utils = new AppTheme();
}
