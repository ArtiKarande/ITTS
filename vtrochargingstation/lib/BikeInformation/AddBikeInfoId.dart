/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:vtrochargingstation/GoogleMapData/MapView.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/neo/text_field.dart';

class AddBikeInfoId extends StatefulWidget {

  String pageRedirect;
  AddBikeInfoId(this.pageRedirect);

  @override
  _AddBikeInfoIdState createState() => _AddBikeInfoIdState();
}

/// for new design purpose implemented
/// API is on hold

class _AddBikeInfoIdState extends State<AddBikeInfoId> {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  APICall apiCall = APICall();
  AppTheme utils = new AppTheme();

  TextEditingController _emailIDController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    getBikeData();
  }

  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false, /// keyboard issue handled

        /// UI
        body: SafeArea(
          child: Stack(
            children: [
              Center(child: Container(
                  height: h/1.3,
                  child: Padding(
                    padding: EdgeInsets.only(right:h/5),
                    child: Image.asset("images/loginCircle.png",fit: BoxFit.cover,),
                  ))),

              Padding(
                padding: EdgeInsets.only(left:w/30, right: w/30),
                child: Container(
                  height: h,
                  width: w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      SizedBox(height: h/20,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('images/vtrologo.png', height: h/11,),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('BIKE DETAILS', style:utils.textStyleRegular2(context,FontWeight.w400)),
                        ],
                      ),
                      SizedBox(height: h/30,),

                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('Enter bike ID to  check your bike details, you can not edit it its only read-only purpose.',
                            style: utils.textStyleRegular(context, 60, AppTheme.text2,FontWeight.w400, 0.0,'')),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NeumorphicTextField(
                          textSize: 48,
                          height: 15.0,
                          text: _emailIDController.text,
                          hint: 'Enter Bike ID',
                          onChanged: itemTitleChange,
                        ),
                      ),

                      SizedBox(height: h/30,),

                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FDottedLine(
                          color: AppTheme.text4,
                          width: 160.0,
                          strokeWidth: 1.0,
                          dottedLength: 10.0,
                          space: 0.0,
                          corner: FDottedLineCorner.all(20),
                          child: Container(
                        //    color: AppTheme.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Bike ID', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                      Text('ID', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                    ],
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Bike Name', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                      Text('Name', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Bike Series', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                      Text('Series', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Battery Company', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                      Text('VTRO', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Battery Model', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                      Text('Model', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Battery KW', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                      Text('KW', style: utils.textStyleRegular2(context, FontWeight.w400)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// LET’S GO button
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: h / 25),
                            child: Container(
                              height: h/14,
                              margin: EdgeInsets.symmetric(horizontal: h/15),  // horizontal = width, vertical = kiti varun khali

                              child: NeumorphicButton(
                                onPressed: (){

                                  ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please add data, at admin side');

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

                                    Text('DONE', style:utils.textStyleRegular(context,45, AppTheme.text2,FontWeight.w700, 0.0,'')),

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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void itemTitleChange(String title) {
    setState(() {
      this._emailIDController.text = title;
      print(_emailIDController.text);

    });
  }

  /// on press of android back button action
  Future<bool> _onWillPop() {

    if(widget.pageRedirect == 'profile'){
      Navigator.pop(context);
    }else{
      return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          content: new Text('Do you want to exit an App'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: new Text('No'),
            ),
            new FlatButton(
              //   onPressed: () => exit(0),
              onPressed: (){
                SystemNavigator.pop();
              },
              child: new Text('Yes'),
            ),
          ],
        ),
      ) ??
          false;
    }
  }

  /// API
  void getBikeData() {
    apiCall.getBikeDataById().then((response) {
      if(response['status'] == true){
        print('bike_serial_no');
        print(response);
      }else{
        print('---get bike name API -> False');
      }
    });
  }
}
