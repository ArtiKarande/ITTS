/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FToast{
  static void show(String message){
    Fluttertoast.showToast(msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,   //SUB_TITLE_COLOR   BUTTON_TEXT_COLOR
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static void showCenter(String message){
    Fluttertoast.showToast(msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static void showLong(String message){
    Fluttertoast.showToast(msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  TextStyle textStyle1;
  textStyle(BuildContext context, height, Color color, fontWeight, letterSpacing) {
    textStyle1 = new TextStyle(
        fontSize: MediaQuery.of(context).size.height/height,
      color: color,fontWeight: fontWeight, letterSpacing: letterSpacing, fontFamily: 'Nunito',);
    return textStyle1;
  }

  TextStyle textStyleParam;
  textStyle2(BuildContext context, fontSize, fontColor, fontWeight, letterSpacing, fontFamily) {
    textStyleParam = new TextStyle(
      fontSize: MediaQuery.of(context).size.height/fontSize,
      color: fontColor,fontWeight: fontWeight, letterSpacing: letterSpacing, fontFamily: 'SofiaProRegular',);
    return textStyleParam;
  }


}