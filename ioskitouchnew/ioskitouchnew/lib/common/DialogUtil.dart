/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/common/StringConstants.dart';
import 'package:ioskitouchnew/common/Style.dart';

class DialogUtil {
   void willPopSingleOptionDialog(BuildContext context, String title,
      String textTitle, VoidCallback onPressed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return new WillPopScope(
            child: new AlertDialog(
              title: new Text(
                title,
                style: CommonStyle().dialogTitle,
              ),
              content: new Text(
                textTitle,
                style: CommonStyle().dialogSubTitle,
              ),
              actions: <Widget>[
                new FlatButton(
                    onPressed: onPressed,
                    child: new Text(StringConstants.OK,
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.blue))),
              ],
            ),
            onWillPop: () {
              // Do nothing
            });
      },
    );
  }

  static void singleOptionDialog(BuildContext context, String title,
      String textTitle, VoidCallback onPressed) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return new AlertDialog(
            title: new Text(
              title,
              style: CommonStyle().dialogTitle,
            ),
            content: new Text(
              textTitle,
              style: CommonStyle().dialogSubTitle,
            ),
            actions: <Widget>[
              new FlatButton(
                  key: Key('singleOptionDialogButton'),
                  onPressed: onPressed,
                  child: new Text(StringConstants.OK,
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.blue))),
            ],
          );
        });
  }

  static void multipleOptionDialog(BuildContext context, String textName,
      VoidCallback onPressed1, VoidCallback onPressed2) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return new AlertDialog(
            title: new Text(
              StringConstants.SUCCESS,
              style: CommonStyle().dialogTitle,
            ),
            content: new Text(
              textName,
              style: CommonStyle().dialogSubTitle,
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    onPressed1();
                  },
                  child: new Text(StringConstants.YES,
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.blue))),
              new FlatButton(
                  onPressed: () {
                    onPressed2();
                  },
                  child: new Text(StringConstants.NO,
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.blue))),
            ],
          );
        });
  }

  static void deleteOptionDialog(BuildContext context, String textName,
      VoidCallback onPressed1, VoidCallback onPressed2) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return new AlertDialog(
            title: new Text(
              StringConstants.ALERT,
              style: CommonStyle().dialogTitle,
            ),
            content: new Text(
              textName,
              style: CommonStyle().dialogSubTitle,
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    onPressed1();
                  },
                  child: new Text(StringConstants.YES,
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.blue))),
              new FlatButton(
                  onPressed: () {
                    onPressed2();
                  },
                  child: new Text(StringConstants.NO,
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.blue))),
            ],
          );
        });
  }
}
