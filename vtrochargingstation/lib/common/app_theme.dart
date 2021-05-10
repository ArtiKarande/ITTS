/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';

class AppTheme {

  /// neu background color
  static const Color background = Color(0xFFE8E8EA);

  /// neu shadow
  static const Color bottomShadow = Color(0xFFD3D3D3);

  static const Color greenShade1 = Color(0xFF81B855);  // old used color = 0xFF009E2B
  static const Color greenShade2 = Color(0xFFC7E0C6);
  static const Color greenShade3 = Color(0xFFE6EEE8);
  static const Color greenBottomShadow = Color(0xFFC7C7C7);
  static const Color buttonRippleShade = Color(0xFFcbcbcb);


  static const Color nearlyWhite = Color(0xFFFEFEFE);
  static const Color white = Color(0xFFFFFFFF);

  static const Color text1 = Color(0xFF3D3D3D);
  static const Color text2 = Color(0xFF808080);
  static const Color text3 = Color(0xFFEAEAEA);
  static const Color text4 = Color(0xFFB2B2B2);
  static const Color textBackground = Color(0xFFDBDBDF);
  static const Color buttonDisabled = Color(0xFFD4D5D6);

  static const Color line1 = Color(0xFFDFDFDF);
  static const Color tabLine = Color(0xFF96D1A5);

  static const Color red = Color(0xFFE55C46);//E64B33   old red=  0xFFFF4444
  static const Color red1 = Color(0xFFECB2AC);
  static const Color yellow1 = Color(0xFFD1C340);
  static const Color divider = Color(0xFFD2D2D5);
  static const Color blueShade1 = Color(0xFFEBF1FF);

  TextStyle textStyleParam;
  textStyleRegular(BuildContext context, fontSize, fontColor, fontWeight, letterSpacing, fontFamily) {
    textStyleParam = new TextStyle(
      fontSize: MediaQuery.of(context).size.height/fontSize,
      color: fontColor,fontWeight: fontWeight, letterSpacing: letterSpacing, fontFamily: 'SofiaProRegular',);
    return textStyleParam;
  }

  TextStyle textStyleBold;
  textStyleBold1(BuildContext context, fontSize, fontColor, letterSpacing, fontFamily) {
    textStyleBold = new TextStyle(
      fontSize: MediaQuery.of(context).size.height/fontSize,
      color: fontColor, letterSpacing: letterSpacing, fontFamily: 'SofiaProBold',);
    return textStyleBold;
  }


  ///3d3d3d, 14
  textStyleRegular1(BuildContext context, fontWeight) {
    textStyleParam = new TextStyle(
      fontSize: MediaQuery.of(context).size.height/50, //48
      color: AppTheme.text1,fontWeight: fontWeight, letterSpacing: 0.0, fontFamily: 'SofiaProRegular',);
    return textStyleParam;
  }

  /// 808080, 14
  textStyleRegular2(BuildContext context, fontWeight) {
    textStyleParam = new TextStyle(
      fontSize: MediaQuery.of(context).size.height/50, //48
      color: AppTheme.text2,fontWeight: fontWeight, letterSpacing: 0.0, fontFamily: 'SofiaProRegular',);
    return textStyleParam;
  }

  ///3d3d3d, 12
  textStyleRegular3(BuildContext context, fontWeight) {
    textStyleParam = new TextStyle(
      fontSize: MediaQuery.of(context).size.height/54, //52
      color: AppTheme.text1,fontWeight: fontWeight, letterSpacing: 0.0, fontFamily: 'SofiaProRegular',);
    return textStyleParam;
  }

  /// 808080, 12, text2
  textStyleRegular4(BuildContext context, fontWeight) {
    textStyleParam = new TextStyle(
      fontSize: MediaQuery.of(context).size.height/55, //52
      color: AppTheme.text2,fontWeight: fontWeight, letterSpacing: 0.0, fontFamily: 'SofiaProRegular',);
    return textStyleParam;
  }


  /// 808080, 14
  textStyleRegularUnderline(BuildContext context, fontSize, fontColor, fontWeight, letterSpacing, fontFamily) {
    textStyleParam = new TextStyle(
      fontSize: MediaQuery.of(context).size.height/fontSize,
      color: fontColor,fontWeight: fontWeight, letterSpacing: letterSpacing, fontFamily: 'SofiaProRegular',decoration: TextDecoration.underline,);
    return textStyleParam;
  }

}
