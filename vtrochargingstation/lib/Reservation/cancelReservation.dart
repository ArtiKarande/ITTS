/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:vtrochargingstation/Reservation/RefundDetails.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';

class CancelReservation extends StatefulWidget {
  @override
  _CancelReservationState createState() => _CancelReservationState();
}

class _CancelReservationState extends State<CancelReservation> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  APICall apiCall = new APICall();

  AppTheme utils = new AppTheme();
  bool _checkbox = false;
  bool _loading = true;

  String _reasonName;
  List _reasonList = new List();

  @override
  void initState() {
    super.initState();

    print('rID:: ' + FlutterApp.reservationID);
    cancelReasonList();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,
      key: _scaffoldKey,
      /// UI
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Colors.green,
          size: 50,
        ),
        dismissible: false,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
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
                            padding: EdgeInsets.only(left: h / 90),
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: w / 6 ),   //w / 6
                        child: Text('Cancel Reservation'
                            + '[Rid: ' + FlutterApp.reservationID + ']',
                            style: utils.textStyleRegular1(context, FontWeight.normal)),
                      ),
                    ],
                  ),

                  Container(
                    width: w,
                    color: AppTheme.greenShade3,
                          child: Padding(
                            padding: EdgeInsets.all(h / 35),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text('HOW CANCELLATION  WORKS ?', style: utils.textStyleRegular4(context, FontWeight.w400)),

                                  SizedBox(height: h/40,),
                                  Text('1. Before 24 hrs 0% deduction ie. you’ll get full amount.', style: utils.textStyleRegular3(context, FontWeight.w400)),
                                  Text('2. Within 16 hrs 10% deduction based upon your time', style: utils.textStyleRegular3(context, FontWeight.w400)),
                                  Text('3. you can cancel reservation before 1hr of time slot that time 25% amount will be deducted', style: utils.textStyleRegular3(context, FontWeight.w400)),
                                  Text('4. If you doesn’t cancel reservation and you are able to go to the station 30% amount will be deduted', style: utils.textStyleRegular3(context, FontWeight.w400)),
                                  Text('5. Refund will be transferred within 5 to 7 days',
                                      style: utils.textStyleRegular3(context, FontWeight.w700)),
                    ],
                  ),
               )),

                  Padding(
                    padding: EdgeInsets.all(h / 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select reason for cancellation', style: utils.textStyleRegular1(context, FontWeight.w400)),
                        Text('Please tell us correct reason for cancellation, to improve our services ', style: utils.textStyleRegular4(context, FontWeight.w400)),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: w/20.0, right: w/20),
                    child: Neumorphic(
                      style: NeumorphicStyle(
                        depth: -7,
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),  // side border
                        shadowDarkColorEmboss: AppTheme.bottomShadow,  //  inner top shadow
                        shadowLightColorEmboss: Colors.white, // inner bottom shadow
                        disableDepth: false,
                        surfaceIntensity: 5,
                        color: AppTheme.background,
                        shape: NeumorphicShape.convex,
                        intensity: 0.99,
                      ),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    dropdownColor: Colors.deepOrangeAccent[50],
                                    value: _reasonName,

                                    iconSize: 30,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    style:utils.textStyleRegular(context,48, AppTheme.text2,FontWeight.w400, 0.0,''),
                                    hint: Text('Select Reason',style:utils.textStyleRegular(context,55, AppTheme.text4,FontWeight.w400, 0.0,'')),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        _reasonName = newValue;
                                        print('...');
                                        print(_reasonName);
                                      });
                                    },
                                    items: _reasonList?.map((item) {
                                      return new DropdownMenuItem(
                                        child: new Text(item['reason']),
                                        value: item['reason'].toString(),
                                      );
                                    })?.toList() ??
                                        [],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: h/30, top: h/13),
                    child: Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black87,
                          activeColor: AppTheme.greenShade1,

                          value: _checkbox,
                          onChanged: (value) {
                            setState(() {
                              print(value);
                              _checkbox = !_checkbox;
                            });
                          },
                        ),

                        Text('I agree terms & condition.', style: utils.textStyleRegular4(context, FontWeight.w400)),

                      ],
                    ),
                  ),

                  ///REVIEW REFUND DETAILS button
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: h / 25),
                        child: Container(
                          //  color: Color(0xFFF2F2F2),
                          height: h/14,
                          margin: EdgeInsets.symmetric(horizontal: h/15, ), // horizontal = width, vertical = kiti varun khali

                          child: NeumorphicButton(
                            onPressed: (){

                              if(_reasonName == null){
                                ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please select appropriate reason');
                              }

                              else if(_checkbox == false){
                                ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please select above Terms and Conditions');

                              }else{
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RefundDetails(_reasonName)));
                              }
                            },

                            style: NeumorphicStyle(
                                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                color: AppTheme.background,
                                depth: 5,
                                surfaceIntensity: 0.20,
                                intensity: 0.95,
                                shadowDarkColor: AppTheme.bottomShadow,  //outer bottom shadow
                                shadowLightColor: Colors.white  // outer top shadow
                            ),

                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Text('REVIEW REFUND DETAILS', style:utils.textStyleRegular(context,55, AppTheme.text2,FontWeight.w700, 0.0,'')),

                                Padding(
                                  padding: const EdgeInsets.only(left:10.0),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: Color(0xFF808080),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// API - reason list
  void cancelReasonList() {

    apiCall.getReasonList().then((response) {
      setState(() {
        _loading = false;
      });
      if(response['status'] == true){
        setState(() {
          _reasonList = response['reason'];
        });
      }else{
        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'API false');
      }
    });
  }
}
