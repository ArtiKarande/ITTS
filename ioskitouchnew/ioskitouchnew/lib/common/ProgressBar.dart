/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/common/StyleColor.dart';

///loader to show some data is loading so that user can wait until loader is dismissed

class ProgressBar {
  static void show(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        child: new Center(
          child: new CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorCode.SECONDARY_COLOR),
          ),
        ));
  }

  static void showColored(BuildContext context, Color color) {
    showDialog(
        context: context,
        barrierDismissible: false,
        child: new Center(
          child: new CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ));
  }


  /// to dismiss loader
  static void dismiss(BuildContext context){
    Navigator.of(context).pop();
  }
}
