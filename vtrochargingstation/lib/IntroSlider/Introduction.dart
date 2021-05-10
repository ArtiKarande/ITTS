/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:vtrochargingstation/Login/login.dart';
import 'package:vtrochargingstation/common/app_theme.dart';

class Introduction extends StatefulWidget {
  @override
  _IntroductionState createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {

  List<Slide> slides = new List();

  /// sets 3 slider to introduction screen
  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        pathImage: "images/slider/slider1.png",
        description: 'Find Near by\n Charging Stations',
        styleDescription: TextStyle(color: AppTheme.text1, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'SofiaProBold'),
        backgroundColor: Colors.transparent,
      ),
    );

    slides.add(
      Slide(
        pathImage: "images/slider/slider2.png",
        description: "Scan QR code\n for Battery Charging",
        backgroundColor: Colors.transparent,
        styleDescription: TextStyle(color: AppTheme.text1, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'SofiaProBold'),
      ),
    );
    slides.add(
      Slide(
        pathImage: "images/slider/slider3.png",
        backgroundColor: Colors.transparent,
        description: 'Bike\n Charging Status',
        styleDescription: TextStyle(color: AppTheme.text1, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'SofiaProBold'),
      ),
    );
  }

  void onDonePress() {
    login();
  }

  void onSkipPress() {
    login();
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,

      /// UI
      body: SafeArea(
        child: Stack(

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/vtrologo.png', height: h/7 ),
              ],
            ),

            Center(child: Container(
                height: h/1.3,
                child: Padding(
                  padding: EdgeInsets.only(right:h/5),
                  child: Image.asset("images/loginCircle.png",fit: BoxFit.cover,),
                ))),

            IntroSlider(
              colorDot: AppTheme.greenShade2,
             // colorSkipBtn: AppTheme.greenShade1,
              colorActiveDot: AppTheme.greenShade1,
              slides: this.slides,
              onDonePress: this.onDonePress,
              onSkipPress: this.onSkipPress,
            //  highlightColorSkipBtn: AppTheme.red,
              styleNameSkipBtn: TextStyle(color: AppTheme.text1,),
              styleNameDoneBtn: TextStyle(color: AppTheme.text1),
            ),
          ],
        ),
      ),
    );
  }

  void login() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }
}