/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:vtrochargingstation/SplashScreen.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/app_theme.dart';

class ChangeUrl extends StatefulWidget {
  @override
  _ChangeUrlState createState() => _ChangeUrlState();
}

/// temporary purpose only UI
class _ChangeUrlState extends State<ChangeUrl> {

  AppTheme utils=new AppTheme();

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: h / 25),
            child: Container(
              height: h / 14,
              margin: EdgeInsets.symmetric(horizontal: h / 15),
              child: NeumorphicButton(
                onPressed: () {

                  setState(() {
                    FlutterApp.changeUrl = 'https://skromanglobal.com/EV_ChargeStation/';
                    FlutterApp.changeMqttUrl = '148.66.133.252';
                  });

                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SplashScreen()));
                },
                style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(30)),
                    color: AppTheme.background,
                    depth: 5,
                    surfaceIntensity: 0.20,
                    intensity:  0.95, //changed
                    shadowDarkColor: AppTheme.bottomShadow,
                    //outer bottom shadow
                    shadowLightColor: Colors.white // outer top shadow
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Old URL',
                        style: utils.textStyleRegular(context, 50,
                        AppTheme.text2, FontWeight.w700, 0.0, '')),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppTheme.text2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 30),

          Container(
            height: h / 14,
            margin: EdgeInsets.symmetric(horizontal: h / 15),
            child: NeumorphicButton(
              onPressed: () {

                setState(() {
                  FlutterApp.changeUrl = 'https://v-tro.in/EV_ChargeStation/';
                  FlutterApp.changeMqttUrl = 'v-tro.in';
                });

                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => SplashScreen()));
              },
              style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(30)),
                  color: AppTheme.background,
                  depth: 5,
                  surfaceIntensity: 0.20,
                  intensity: 0.95, //changed
                  shadowDarkColor: AppTheme.bottomShadow,
                  //outer bottom shadow
                  shadowLightColor: Colors.white // outer top shadow
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('New URL',
                      style: utils.textStyleRegular(context, 50,
                      AppTheme.text2, FontWeight.w700, 0.0, '')),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppTheme.text2,
                    ),
                  ),
                ],
              ),
            ),
          ),



        ],
      ),
    );
  }
}
