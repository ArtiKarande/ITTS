/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:vtrochargingstation/common/app_theme.dart';

class KnowMore extends StatefulWidget {
  @override
  _KnowMoreState createState() => _KnowMoreState();
}

class _KnowMoreState extends State<KnowMore> {
  AppTheme utils = new AppTheme();

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,

      /// UI
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
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
                      'Ooops! Something went wrong',
                      style: TextStyle(fontSize: h / 60,fontWeight: FontWeight.bold, color: AppTheme.white),
                    ),
                  ),

                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: w/20),
                      child: Icon(Icons.close, color: Colors.white,),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(
                          color: Colors.red.shade300,// set border color
                          width: 1.0),   // set border width
                      borderRadius: BorderRadius.all(
                          Radius.circular(10.0)), // set rounded corner radius

                  ),
          //      color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('The possibilities of this type of errors can be:', style: utils.textStyleRegular2(context, FontWeight.w400)),
                      Text('1) No electricity at charging stations', style: utils.textStyleRegular3(context, FontWeight.w400)),
                      Text('2) No internet connection at charging station ', style: utils.textStyleRegular3(context, FontWeight.w400)),
                      Text('3) Rainy / cloudy wheather outside', style: utils.textStyleRegular3(context, FontWeight.w400)),
                ],
              ),
                  )),
            ),

            SizedBox(
              height: h/15,
            ),

            ///SECURE pay button
            Container(
              height: h / 14,
              margin: EdgeInsets.symmetric(horizontal: h / 7),
              child: NeumorphicButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(30)),
                    color: AppTheme.background,
                    depth: 5,
                    surfaceIntensity: 0.20,
                    intensity: 0.95,
                    shadowDarkColor: AppTheme.bottomShadow,
                    //outer bottom shadow
                    shadowLightColor: Colors.white // outer top shadow
                    ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('OK',
                        style: utils.textStyleRegular(context, 50,
                            AppTheme.text2, FontWeight.w700, 0.0, '')),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF808080),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
