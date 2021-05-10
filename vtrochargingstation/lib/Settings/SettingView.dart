/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:vtrochargingstation/Animation/DelayedAimation.dart';
import 'package:vtrochargingstation/Settings/ChangeUrl.dart';
import 'package:vtrochargingstation/Settings/Setting.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class SettingView extends SettingsState{

  List<String> options = ["Notifications Settings","Application Settings","Account Settings","Change URL"];
  List<String> subValue = ["What alerts and notification you want to see","Manage your app settings",
    "Log out or Delete your account","URL"];

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: CircularSoftButton(
                    radius: 20,
                    icon: Padding(
                      padding: EdgeInsets.only(left:h/90),
                      child: Icon(Icons.arrow_back_ios, size: 20,),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: w / 4),
                  child: Text('Settings',
                      style:utils.textStyleRegular1(context, FontWeight.w400)),
                ),
              ],
            ),

            getOptions(),

          ],
        ),
      ),
    );
  }

  /// UI of list view [settings]
  getOptions() {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Flexible(
      child: DelayedAimation(
        child: Container(
          width: w,
          child: ScrollConfiguration(
            behavior: ScrollBehavior(),
            child: ListView.builder(

                scrollDirection: Axis.vertical,
                // itemCount: _planList.length,
                itemCount: options.length,
                itemBuilder:(context, index) {

                  return InkWell(
                    onTap: (){
                        print(options[index]);
                        if(options[index] == 'Change URL'){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeUrl()));//MapView  ChangeUrl
                        }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Neumorphic(

                        style: NeumorphicStyle(

                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                          color: AppTheme.background,
                          depth: 5,
                          intensity: 0.99, //drop shadow
                          shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                          shadowLightColor: Colors.white,  // upper top shadow

                        ),

                        child:  Padding(
                          padding: EdgeInsets.all(h/45),
                          child: Container(
                            color: AppTheme.background,
                            child: Stack(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: h/90),
                                      child: Icon(Icons.arrow_forward_ios, size: h/30,),
                                    ),
                                  ],
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(options[index], style:utils.textStyleRegular1(context, FontWeight.w400)),
                                    Text(subValue[index], style:utils.textStyleRegular(context,55, AppTheme.text4,FontWeight.normal, 0.0,'')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );

                }),
          ),
        ),
      ),
    );
  }

}