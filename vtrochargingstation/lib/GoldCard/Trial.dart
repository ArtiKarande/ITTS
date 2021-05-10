/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtrochargingstation/GoogleMapData/MapView.dart';
import 'file:///D:/vTroProjects/vtrochargingstation/vtrochargingstation/lib/Invoice/Invoice.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';

/// dialog box
/// used in
///     - success [green color]
///     - failure [red color]

class TrialDialog extends StatefulWidget {
  String msg = "", title;
  Color color;

  TrialDialog({Key key, this.msg,this.title, this.color}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TrialDialogState();
}

class TrialDialogState extends State<TrialDialog> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
              width: w / 1,
              height: h / 13,
              decoration: ShapeDecoration(
                  color: widget.color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0))),
              child: Row(
                children: <Widget>[

                  SizedBox(width: w/30,),

                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      widget.title,
                      style: TextStyle(fontSize: h / 54,fontWeight: FontWeight.bold, color: AppTheme.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
