/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happyfoods/animation/DelayedAimation.dart';
import 'package:happyfoods/login/auth_methods.dart';
import 'package:happyfoods/models/UserDevice.dart';
import 'package:happyfoods/utils/FToast.dart';
import 'package:happyfoods/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatefulWidget {

  HomeTab();

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  bool isLoading = false;
  FToast utils = new FToast();

  AuthMethods _authMethods = AuthMethods();
  List<UserDevice> _userDeviceList = new List<UserDevice>();

  String status,greenZone,orangeZone,redZone,totalZoneCount;
  bool _loading = false,shareVisible = false;
  ScrollController _sc = new ScrollController();

  int flag = 0;

  SharedPreferences _preferences;
  String fName = "",lName='';

  @override
  void initState() {
    getPreferencesValues();
    super.initState();
 //   checkInternet();
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: AppTheme.BUTTON_BG_COLOR,
          size: 50,
        ),
        dismissible: false,
        child: Scaffold(

          body: Center(

            child: Column(

             //   crossAxisAlignment: CrossAxisAlignment.center,
             //   mainAxisAlignment: MainAxisAlignment.center,

              children: <Widget>[

                Image.asset("images/pic.png"),

                Text('Hi ' + fName + ' ' + lName + ' ', style: utils.textStyle(context,50,Colors.black,FontWeight.bold,1.0),),

                SizedBox(height: 10,),

                Text('Welcome to Happy Food'),

                Text('To order food please check our subscription plans')
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///API call
  void getSearchDataByDate() {

    setState(() {
      _loading =true;
    });

    _userDeviceList.clear();
    _authMethods.attendanceList('10000000').then((response) {

      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      if(response['success'] == "1"){
        //       FToast.show("msg");
        for (var user in response['data']['data']) {
          _userDeviceList.add(UserDevice(user['deviceId'],user['temperature'], user['date'],user['time'],user['devicename']
          ));//user['cards']
        }
      }
      else if(response['success'] == "0"){
        //  FToast.show("No data to load");
        Navigator.pop(context);

      }else{
        FToast.show("API error");
      }
    });
  }

  api_seectedListViewShow(
      BuildContext context,
      double height,
      titleFontSize,
      subTitleFontSize,
      int titleFont,
      int subTitleFont,
      double seeMoreFontSize,
      ) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
      //    color: Colors.red,
      //   height: height / 2.1,

      child: DelayedAimation(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
         //   itemCount: _userDeviceList.length,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[200],
                        ),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[

                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          "Non-veg customized",
                                          style: utils.textStyle(
                                              context,
                                              titleFontSize,
                                              Colors.black,
                                              FontWeight.bold,
                                              0.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "You have subscribed Monthy subscription",
                                        style: utils.textStyle(
                                            context,
                                            subTitleFont,
                                            Colors.black,
                                            FontWeight.normal,
                                            0.0),
                                      ),

                                    ],
                                  ),

                                  SizedBox(height: 20,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Total meals delivered ",
                                        style: utils.textStyle(
                                            context,
                                            subTitleFont,
                                            Colors.black,
                                            FontWeight.normal,
                                            0.0),
                                      ),


                                      Text(
                                        "25",
                                        style: utils.textStyle(
                                            context,
                                            subTitleFont,
                                            Colors.green,
                                            FontWeight.normal,
                                            0.0),
                                      ),

                                    ],
                                  ),


                                  SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            "from: ",
                                            style: utils.textStyle(
                                                context,
                                                subTitleFont,
                                                Colors.black,
                                                FontWeight.normal,
                                                0.0),
                                          ),

                                          Text(
                                            "01-06-2020",
                                            style: utils.textStyle(
                                                context,
                                                subTitleFont,
                                                Colors.black,
                                                FontWeight.normal,
                                                0.0),
                                          ),

                                        ],
                                      ),


                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            "To: ",
                                            style: utils.textStyle(
                                                context,
                                                subTitleFont,
                                                Colors.black,
                                                FontWeight.normal,
                                                0.0),
                                          ),
                                          Text(
                                            "01-06-2020",
                                            style: utils.textStyle(
                                                context,
                                                subTitleFont,
                                                Colors.black,
                                                FontWeight.normal,
                                                0.0),
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),


                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    )),
              );


              /*  return DataTable(
                columns: [
                  DataColumn(label: Text('RollNo')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Class')),
                ],
                rows: <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text(_userDeviceList[index].deviceName + " [ " + _userDeviceList[index].deviceId + " ]",)),
                      DataCell(Text(_userDeviceList[index].date)),
                      DataCell(Text(_userDeviceList[index].time)),
                    ],
                  ),


                ],
              );*/
            }),
      ),
    );
  }

  checkInternet()async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";

        getSearchDataByDate();
      }


    } on SocketException catch (_) {
      print('not connected');

      FToast.show("You are not connected to internet");
      status = "ConnectivityResult.none";

      setState(() {
        _loading = false;
      });
    }
  }

  void getPreferencesValues() async{
    _preferences = await SharedPreferences.getInstance();
    setState(() {

      fName = _preferences.getString("fname");
      lName = _preferences.getString("lname");

      print(fName[0]);

    });

  }
}

