/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'StyleColor.dart';


class FToast{
  static void show(String message){
    Fluttertoast.showToast(msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 3,
        backgroundColor: AppTheme.SUB_TITLE_COLOR,   //SUB_TITLE_COLOR   BUTTON_TEXT_COLOR
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static void showCenter(String message){
    Fluttertoast.showToast(msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3,
        backgroundColor: AppTheme.SUB_TITLE_COLOR,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  TextStyle textStyle1;
  textStyle(BuildContext context, height, Color color, fontWeight, letterSpacing) {
    textStyle1 = new TextStyle(
        fontSize: MediaQuery.of(context).size.height/height, fontFamily: 'Nunito', color: color,fontWeight: fontWeight, letterSpacing: letterSpacing);
    return textStyle1;
  }



}