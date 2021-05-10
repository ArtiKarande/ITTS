/*
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vtrochargingstation/InternetConnectivity/KnowMore.dart';
import 'package:vtrochargingstation/common/app_theme.dart';

class NetworkInfo extends StatefulWidget {

  String title;
  NetworkInfo({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NetworkInfoState();
}

class NetworkInfoState extends State<NetworkInfo> with SingleTickerProviderStateMixin {
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
          child: Container(
            width: w / 1,
            height: h / 13,
            decoration: ShapeDecoration(
                color: AppTheme.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.only(left: w/20),
                  child: Text(
                      widget.title,
                    style: TextStyle(fontSize: h / 60,fontWeight: FontWeight.bold, color: AppTheme.white),
                  ),
                ),

                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => KnowMore()));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: w/20),
                    child: Text(
                      'Know more',
                      style: TextStyle(fontSize: h / 60,fontWeight: FontWeight.bold, color: AppTheme.white, decoration: TextDecoration.underline,),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
