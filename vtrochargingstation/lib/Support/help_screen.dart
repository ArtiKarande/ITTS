/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:vtrochargingstation/Animation/DelayedAimation.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {

  AppTheme utils = AppTheme();

  List<String> options = ["Payment/ Refund","Gold Card","Wallets", "Reservation", "Vtro Services", "Contact Us"];
  List<String> subValue = ["Know about payments and Refunds ","know all about Wallets, ",
    "know all about Wallets", "Know all about reservation status", "Know all about vtro services", "Customer call"];

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

            /// Appbar
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
                  child: Text('Support',
                      style:utils.textStyleRegular1(context, FontWeight.w400)),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(left: w/40, right: w/40, top: h/90),
              child: Container(
                height: h/8.5,
                width: w,
                child: Neumorphic(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                    color: AppTheme.background,
                    depth: 5,
                    intensity: 0.99, //drop shadow
                    shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                    shadowLightColor: Colors.white,  // upper top shadow
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top:h/60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Padding(
                          padding: EdgeInsets.only(left: w/30, ),
                          child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Flexible(
                                fit: FlexFit.tight,
                                flex: 1,
                                child: Container(
                                  //  width: 50,
                                  height: h/10,
                                  child: Image.asset('images/techSupport.png', height: h/12, width: w/15,),
                                ),

                              ),
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 2,
                                child: Container(
                                  width: w/3,
                                  height: h/10,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('24X7 Customer Services',
                                              style:utils.textStyleRegular(context,48, AppTheme.greenShade1,FontWeight.normal, 0.0,'')),
                                          Text('Please get in touch and we \nwill be happy to help you',
                                              style:utils.textStyleRegular4(context, FontWeight.w400)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left:w/20, top: h/60),
              child: Text('Need Help?',
                  style:utils.textStyleRegular1(context, FontWeight.w400)),
            ),
            getOptions(),
          ],
        ),
      ),
    );
  }

  /// UI of list view [help screen]
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
                itemCount: options.length,
                itemBuilder:(context, index) {

                  return Padding(
                    padding: EdgeInsets.only(left: w/30, right: w/30, top: h/50),
                    child: GestureDetector(
                      onTap: (){
                        print(options[index]);

                        if(options[index] == 'Contact Us'){
                          showModalBottomSheet<void>(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (BuildContext context) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.background,
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(color: Colors.grey.withOpacity(0.6), offset: const Offset(4, 4), blurRadius: 8.0),
                                    ],
                                  ),

                                  child: getBottomSheet(),
                                  height: h / 4.5,
                                  //    color: Colors.red,
                                ),
                              );
                            },
                          );
                        }
                      },

                      child: Neumorphic(

                        style: NeumorphicStyle(

                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                          color: AppTheme.background,
                          depth: 5,
                          intensity: 0.99, //drop shadow
                          shadowDarkColor: AppTheme.bottomShadow, // upper bottom shadow
                          shadowLightColor: Colors.white,  // upper top shadow
                          //    surfaceIntensity: 0.20, // no use

                        ),

                        child:  Padding(
                          padding: EdgeInsets.all(h/55),
                          child: Container(
                            color: AppTheme.background,
                            child: Stack(

                              children: [

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: h/60),
                                      child: Icon(Icons.arrow_forward_ios, size: h/40,),
                                    ),
                                  ],
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(options[index],
                                        style:utils.textStyleRegular1(context, FontWeight.w400)),
                                    Text(subValue[index],
                                        style:utils.textStyleRegular(context,55, AppTheme.text4,FontWeight.normal, 0.0,'')),
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

  /// when click on contact us - open bottom sheet
  Widget getBottomSheet() {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: h/45, left: w/15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact Us', maxLines: 2, style: utils.textStyleRegular3(context, FontWeight.w400)),
              Text('How do you wish to contact us', maxLines: 2, style: utils.textStyleRegular4(context, FontWeight.w400)),

              SizedBox(height: h/40),

              Row(
                children: [
                  Icon(Icons.add_call, color: AppTheme.greenShade1,),
                  SizedBox(width: w/30,),
                  Text('Call now', maxLines: 2, style: utils.textStyleRegular3(context, FontWeight.w400)),
                ],
              ),

              SizedBox(height: h/40),

              Row(
                children: [
                  Icon(Icons.message_outlined, color: AppTheme.greenShade1,),
                  SizedBox(width: w/30,),
                  Text('Message', maxLines: 2, style: utils.textStyleRegular3(context, FontWeight.w400)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

}