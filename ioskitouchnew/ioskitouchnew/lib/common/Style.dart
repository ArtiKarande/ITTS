/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/common/StyleColor.dart';

class CommonStyle {
  @protected
  final TextStyle textStyle =
      new TextStyle(fontSize: 15.0, color: Colors.black);
  final TextStyle textWhiteStyle =
      new TextStyle(fontSize: 14.0, color: Colors.white);
  final TextStyle textStyleWithLine = new TextStyle(
      fontSize: 14.0,
      color: Colors.black,
      decoration: TextDecoration.underline);
  final TextStyle largeText =
      new TextStyle(fontSize: 16.0, color: Colors.black);
  final TextStyle titleText =
      new TextStyle(fontSize: 14.0, color: Colors.black26);
  final TextStyle dialogTitle =
      new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
  final TextStyle dialogSubTitle =
  new TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal);

  final Decoration decoration = new BoxDecoration(
      border: new Border(
          top: new BorderSide(color: Colors.black26),
          right: new BorderSide(color: Colors.black26),
          left: new BorderSide(color: Colors.black26),
          bottom: new BorderSide(color: Colors.black26)));

  final ShapeDecoration shapeDecoration = new ShapeDecoration(
      shape: RoundedRectangleBorder(
    side:
        BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.black26),
  ));

 static final TextStyle blueText = new TextStyle(fontSize: 13.0,color: ColorCode.BUTTON_BG_COLOR,fontWeight: FontWeight.bold);
 static final TextStyle blackBoldText = new TextStyle(fontSize: 16.0,color: ColorCode.BLACK_COLOR,fontWeight: FontWeight.bold);
 static final TextStyle blackBoldSubText = new TextStyle(fontSize: 13.0,color: ColorCode.BLACK_COLOR,fontWeight: FontWeight.bold);
 static final TextStyle menuBlackBoldText = new TextStyle(fontSize: 18.0,color: ColorCode.BLACK_COLOR,fontWeight: FontWeight.bold);
 static final TextStyle titleBlackBoldText = new TextStyle(fontSize: 18.0,color: ColorCode.BLACK_COLOR,fontWeight: FontWeight.bold);
 static final TextStyle blackBoldTitleText = new TextStyle(fontSize: 21.0,color: ColorCode.BLACK_COLOR,fontWeight: FontWeight.bold);
 static final TextStyle subTitleText = new TextStyle(fontSize: 12.0,color: ColorCode.SUB_TITLE_COLOR,);
 static final TextStyle subTitleBlueText = new TextStyle(fontSize: 12.0,color: ColorCode.SECONDARY_COLOR,);
 static final TextStyle subRequiredTitleText = new TextStyle(fontSize: 12.0,color: ColorCode.BUTTON_TEXT_COLOR,);
 static final TextStyle whiteText = new TextStyle(fontSize: 16.0,color: ColorCode.WHITE_COLOR,);
 static final TextStyle whiteHeadingText = new TextStyle(fontSize: 16.0,color: ColorCode.WHITE_COLOR,);
 static final TextStyle whiteMenuHeadingText = new TextStyle(fontSize: 18.0,color: ColorCode.WHITE_COLOR,);
 static final TextStyle buttonText = new TextStyle(fontSize: 15.0,color: ColorCode.BUTTON_TEXT_COLOR,);
 static final TextStyle textColor = new TextStyle(fontSize: 15.0,color: ColorCode.BLACK_COLOR,);
 static final TextStyle textLargeColor = new TextStyle(fontSize: 16.0,color: ColorCode.BLACK_COLOR,);
 static final TextStyle textSubTitleColor = new TextStyle(fontSize: 15.0,color: ColorCode.TEXT_SUB_TITLE_COLOR,);
  static final Decoration boxDecoration = new BoxDecoration(
      border: new Border(
          top: new BorderSide(color: Colors.black26),
          right: new BorderSide(color: Colors.black26),
          left: new BorderSide(color: Colors.black26),
          bottom: new BorderSide(color: Colors.black26)));
}
