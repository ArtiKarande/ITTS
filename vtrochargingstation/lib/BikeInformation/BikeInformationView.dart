/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:vtrochargingstation/BikeInformation/BikeInformation.dart';
import 'package:vtrochargingstation/GoogleMapData/MapView.dart';
import 'package:vtrochargingstation/Profile/editProfile/EditProfile.dart';
import 'package:vtrochargingstation/common/ApiCall.dart';
import 'package:vtrochargingstation/common/FToast.dart';
import 'package:vtrochargingstation/common/FlutterApp.dart';
import 'package:vtrochargingstation/common/Messages.dart';
import 'package:vtrochargingstation/common/ProgressBar.dart';
import 'package:vtrochargingstation/common/ShowCustomSnack.dart';
import 'package:vtrochargingstation/common/app_theme.dart';
import 'package:vtrochargingstation/common/sharedPreferece/SharedKeys.dart';
import 'package:vtrochargingstation/models/bikeName.dart';
import 'package:vtrochargingstation/mqtt/MQTTAppState.dart';
import 'package:vtrochargingstation/neo/soft_control.dart';
import 'package:http/http.dart' as http;

/// old design code
/// not in used

class BikeInformationView extends BikeInformationState{

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  APICall apiCall = APICall();

  ///mqtt
  MQTTAppState currentAppState;

  /// dropdown list 1
  List _bikeNameList = new List();
  List _bikeSeriesList;
  List _batteryCompanyList;
  List _batteryModelList;
  List _batteryKWList ;
  String _bikeName , _bikeSeries, _batteryComapny, _batteryModel, _batteryKW;

  String kwId = '0';

  bool status = true;

  @override
  void initState() {
    super.initState();
    getBikeDetails();
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
        /// UI
        body: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [

                Visibility(
                  visible: widget.pageRedirect == 'profile' ? true : false,  // skip/delete status
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top:h/12, right: w/20),
                        child: GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                              FToast.show(Messages.upcoming);
                            },
                            child: Text('Delete', style:utils.textStyleRegularUnderline(context,48, AppTheme.text2,FontWeight.w400, 0.0,''),)),
                      ),
                    ],
                  ),
                ),

                Visibility(
                  visible: widget.pageRedirect == 'login' ? true : false,  // skip/delete status
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top:h/12, right: w/20),
                        child: GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Text('Skip', style:utils.textStyleRegularUnderline(context,48, AppTheme.text2,FontWeight.w400, 0.0,''),)),
                      ),
                    ],
                  ),
                ),


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
               //         Text('Select Bike information', style:utils.textStyleRegular1(context,FontWeight.w400)),
              //          SizedBox(height: h/30,),

                        /// select bike name

                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text('Bike Name', style:utils.textStyleRegular1(context,FontWeight.w400)),
                        ),
                        Neumorphic(
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
                                        value: _bikeName,

                                        iconSize: 30,
                                        icon: Icon(Icons.keyboard_arrow_down),
                                          style:utils.textStyleRegular(context,48, AppTheme.text2,FontWeight.w400, 0.0,''),
                                        hint: Text('Bike Name',style:utils.textStyleRegular(context,48, AppTheme.text4,FontWeight.w400, 0.0,'')),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            _bikeSeries = null;
                                            _batteryComapny = null;
                                            _batteryModel = null;
                                            _batteryKW = null;

                                            _bikeSeriesList = null;
                                            _batteryCompanyList = null;
                                            _batteryModelList = null;
                                            _batteryKWList = null;


                                            _bikeName = newValue;
                                            print('...');
                                            print(_bikeName);
                                            _bikeName = newValue;

                                            getSeriesList(_bikeName);
                                          });
                                        },
                                        items: _bikeNameList?.map((item) {
                                          return new DropdownMenuItem(
                                            child: new Text(item['bike_name']),
                                            value: item['bike_name'].toString(),
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

                        SizedBox(height: h/30,),

                        /// select bike series - 2

                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text('Bike Series', style:utils.textStyleRegular1(context,FontWeight.w400)),
                        ),
                        Neumorphic(
                          style: NeumorphicStyle(
                            depth: -7,
                            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),  // side border
                            shadowDarkColorEmboss: AppTheme.bottomShadow,  //  inner top shadow
                            shadowLightColorEmboss: Colors.white, // inner bottom shadow
                            disableDepth: false,
                            surfaceIntensity: 5,
                            color: AppTheme.background,
                            shape: NeumorphicShape.convex,
                            intensity: 0.99,// inner shadow effect

                          ),
                          child: Container(
                            //     padding: EdgeInsets.only(left: 5, right: 15, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton<String>(
                                        dropdownColor: Colors.deepOrangeAccent[50],
                                        value: _bikeSeries,

                                        iconSize: 30,
                                        icon: Icon(Icons.keyboard_arrow_down),
                                        style:utils.textStyleRegular(context,48, AppTheme.text2,FontWeight.w400, 0.0,''),
                                        hint: Text('Bike Series',style:utils.textStyleRegular(context,48, AppTheme.text4,FontWeight.w400, 0.0,'')),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            _batteryComapny = null;
                                            _batteryModel = null;
                                            _batteryKW = null;

                                            _batteryCompanyList = null;
                                            _batteryModelList = null;
                                            _batteryKWList = null;

                                            _bikeSeries = newValue;
                                            print(_bikeSeries);

                                            if(_bikeSeries != null){
                                              print(' trying to call');
                                              getCompanyList(_bikeName ,_bikeSeries);
                                            }else{
                                              print('not trying to call');
                                            }


                                          });
                                        },
                                        items: _bikeSeriesList?.map((item) {
                                          return new DropdownMenuItem(
                                            child: new Text(item['bike_series']),
                                            value: item['bike_series'].toString(),
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

                        SizedBox(height: h/30,),

                 //      Text('Select Battery information', style:utils.textStyleRegular1(context,FontWeight.w400)),

                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text('Battery Company', style:utils.textStyleRegular1(context,FontWeight.w400)),
                        ),
                        SizedBox(height: h/40,),

                        /// battery company - 3
                        Neumorphic(
                          style: NeumorphicStyle(
                            depth: -7,
                            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),  // side border
                            shadowDarkColorEmboss: AppTheme.bottomShadow,  //  inner top shadow
                            shadowLightColorEmboss: Colors.white, // inner bottom shadow
                            disableDepth: false,
                            surfaceIntensity: 5,
                            color: AppTheme.background,
                            shape: NeumorphicShape.convex,
                            intensity: 0.99,// inner shadow effect

                          ),
                          child: Container(
                            //     padding: EdgeInsets.only(left: 5, right: 15, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton<String>(
                                        dropdownColor: Colors.deepOrangeAccent[50],
                                        value: _batteryComapny,
                                        iconSize: 30,
                                        icon: Icon(Icons.keyboard_arrow_down),
                                        style:utils.textStyleRegular(context,48, AppTheme.text2,FontWeight.w400, 0.0,''),
                                        hint: Text('Battery Company',style:utils.textStyleRegular(context,48, AppTheme.text4,FontWeight.w400, 0.0,'')),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            _batteryModel = null;
                                            _batteryKW = null;

                                            _batteryModelList = null;
                                            _batteryKWList = null;

                                            _batteryComapny = newValue;
                                            print(_batteryComapny);
                                            getModelList(_bikeName, _bikeSeries, _batteryComapny);

                                          });
                                        },
                                        items: _batteryCompanyList?.map((item) {
                                          return new DropdownMenuItem(
                                            child: new Text(item['bike_company']),
                                            value: item['bike_company'].toString(),
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

                        SizedBox(height: h/30,),

                        /// battery model - 4th
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text('Battery Model', style:utils.textStyleRegular1(context,FontWeight.w400)),
                        ),
                        Neumorphic(
                          style: NeumorphicStyle(
                            depth: -7,
                            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),  // side border
                            shadowDarkColorEmboss: AppTheme.bottomShadow,  //  inner top shadow
                            shadowLightColorEmboss: Colors.white, // inner bottom shadow
                            disableDepth: false,
                            surfaceIntensity: 5,
                            color: AppTheme.background,
                            shape: NeumorphicShape.convex,
                            intensity: 0.99,// inner shadow effect

                          ),
                          child: Container(
                            //     padding: EdgeInsets.only(left: 5, right: 15, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton<String>(
                                        dropdownColor: Colors.deepOrangeAccent[50],
                                        value: _batteryModel,
                                        iconSize: 30,
                                        icon: Icon(Icons.keyboard_arrow_down),
                                        style:utils.textStyleRegular(context,48, AppTheme.text2,FontWeight.w400, 0.0,''),
                                        hint: Text('Battery Model',style:utils.textStyleRegular(context,48, AppTheme.text4,FontWeight.w400, 0.0,'')),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            _batteryModel = newValue;
                                            _batteryKW = null;
                                            _batteryKWList = null;
                                            print(_batteryModel);

                                            getKWList(_bikeName, _bikeSeries, _batteryComapny, _batteryModel);
                                          });
                                        },
                                        items: _batteryModelList?.map((item) {
                                          return new DropdownMenuItem(
                                            child: new Text(item['bike_model']),
                                            value: item['bike_model'].toString(),
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

                        SizedBox(height: h/30,),

                        /// select Battery KW - 5th

                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text('Battery KW', style:utils.textStyleRegular1(context,FontWeight.w400)),
                        ),
                        Neumorphic(
                          style: NeumorphicStyle(
                            depth: -7,
                            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),  // side border
                            shadowDarkColorEmboss: AppTheme.bottomShadow,  //  inner top shadow
                            shadowLightColorEmboss: Colors.white, // inner bottom shadow
                            disableDepth: false,
                            surfaceIntensity: 5,
                            color: AppTheme.background,
                            shape: NeumorphicShape.convex,
                            intensity: 0.99,// inner shadow effect

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
                                        focusColor: AppTheme.text2,
                              //          iconEnabledColor: Colors.green,
                                        value: _batteryKW,
                                        iconSize: 30,
                                        icon: Icon(Icons.keyboard_arrow_down),
                                        style:utils.textStyleRegular(context,48, AppTheme.text2,FontWeight.w400, 0.0,''),
                                        hint: Text('Battery KW',style:utils.textStyleRegular(context,48, AppTheme.text4,FontWeight.w400, 0.0,'')),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            _batteryKW = newValue;


                                            print('here..');
                                            print(_batteryKW);
                                            print(kwId);
                                          });
                                        },
                                        items: _batteryKWList?.map((item) {

                                          setState(() {
                                            kwId = item['id'];
                                          });

                                          return new DropdownMenuItem(
                                            child: new Text(item['bike_kw']),
                                            value: item['bike_kw'].toString(),
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

                                    if(_bikeName == null){

                                      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please select name of bike');

                                    }else if(_bikeSeries == null){

                                      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please select series of bike');

                                    }else if(_batteryComapny == null){
                                      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please select battery company');

                                    }else if(_batteryModel == null){

                                      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please select battery model');

                                    }else if(_batteryKW == null){

                                      ShowCustomSnack.getCustomSnack(context, _scaffoldKey, 'Please select battery KW');

                                    }else{
                                      addUserBikeDetails();
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
      ),
    );
  }

  /// 1st API
  void getBikeDetails() {

    apiCall.getBikeName().then((response) {
      if(response['status'] == true){

        setState(() {
          _bikeNameList = response['bike_name'];
        });
        print('---get bike name API -> True');
        print(response);

      }else{
        print('---get bike name API -> False');
      }
    });
  }

  /// 2nd API
  void getSeriesList(bikeName) {

    apiCall.getBikeSeries(bikeName).then((response) {
      if(response['status'] == true){

        setState(() {
          _bikeSeriesList = response['bike_series'];
        });
        print('---get bike series name API - True');
        print(response);

      }else{
        print('---get bike name API - False');
      }
    });

  }

  /// 3rd API
  void getCompanyList(bikeName, bikeSeriesId) {

    apiCall.getCompanyDetails(bikeName, bikeSeriesId).then((response) {
      if(response['status'] == true){

        setState(() {
          _batteryCompanyList = response['bike_company'];
        });
        print('---get company name API -> True');
        print(response);

      }else{
        print('---get company name API -> False');
      }
    });

  }

  /// 4th API
  void getModelList(bikeName, bikeSeriesId, batteryCompany) {

    apiCall.getModelDetails(bikeName, bikeSeriesId, batteryCompany).then((response) {
      if(response['status'] == true){

        setState(() {
          _batteryModelList = response['bike_model'];
        });
        print('---bike _batteryModel API -> True');
        print(response);

      }else{
        print('---batteryModel API -> False');
      }
    });
  }

  /// 5th API
  void getKWList(bikeName, bikeSeriesId, batteryCompany, bikeModel) {

    print(bikeName);
    print(bikeSeriesId);
    print(batteryCompany);
    print(bikeModel);

    apiCall.getKWDetails(bikeName, bikeSeriesId, batteryCompany, bikeModel).then((response) {
      if(response['status'] == true){

        setState(() {
          _batteryKWList = response['bike_kw'];
        });
        print('---KW API -> True');
        print(response);

      }else{
        print('---KW API -> False');
      }
    });
  }

  /// send given data to server - API
  void addUserBikeDetails() {

    print(_bikeName);
    print(_bikeSeries);
    print(_batteryComapny);
    print(_batteryModel);
    print(_batteryKW);

    ProgressBar.show(context);

    apiCall.addUserBikeDetails(_bikeName, _bikeSeries, _batteryComapny, _batteryModel, _batteryKW, kwId).then((response) {

      ProgressBar.dismiss(context);

      if(response['status'] == true){

        getDetailsApi(); ///splash screen api

        pref.putBool(SharedKey().IS_LOGGED_IN, true);

        print('---Add user bike details - True');
        print(response);

 //       FToast.show('Bike details added Successfully');

        if(widget.pageRedirect == 'profile'){
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
        }else{
          Navigator.push(context, MaterialPageRoute(builder: (context) => MapView()));
        }
      }else{

        ShowCustomSnack.getCustomSnack(context, _scaffoldKey, Messages.API_ERROR);

      }
    });
  }

  /// on press of android back button
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

  /// splash screen API - to retrieve all data of user
  void getDetailsApi() {
    apiCall = APICall(state: currentAppState);

    apiCall.getDetailsSplashScreen().then((response) {

      if(response['status'] == true){

        print('- splash[bike info] - true -');

      }else{
        print('- splash[bike info]- false -');
        print('status - false');
      }
    });
  }

}