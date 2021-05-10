/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:itts/constants.dart';
import 'package:itts/graph/SimpleBarChart.dart';
import 'package:itts/login/auth_methods.dart';
import 'package:itts/models/UserDevice.dart';
import 'file:///D:/skromanApp/itts/lib/attendance/attendance_dialog.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
//import 'package:charts_flutter/flutter.dart' as charts;

class AttendanceList extends StatefulWidget {
  String empId, empName;

  AttendanceList(this.empId, this.empName);

  @override
  _AttendanceListState createState() => _AttendanceListState();
}

class _AttendanceListState extends State<AttendanceList> {
  bool isLoading = false;
  FToast utils = new FToast();

  AuthMethods _authMethods = AuthMethods();
  List<UserDevice> _userDeviceList = new List<UserDevice>();

  String status, greenZone, orangeZone, redZone, totalZoneCount;
  bool _loading = false, shareVisible = false;
  ScrollController _sc = new ScrollController();

  int flag = 0;

 // List<GraphModel> _osales = new List<GraphModel>();

//  List<charts.Series> seriesList;
  bool animate;

  @override
  void initState() {
    super.initState();
    checkInternet();
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
          appBar: AppBar(
            title: Text(widget.empName),
          ),
          body: api_seectedListViewShow(context, h, 50, h / 50, 30, 50, 80),
          resizeToAvoidBottomPadding: false,
        ),
      ),
    );
  }

  ///API call
  void getSearchDataByDate() {
    setState(() {
      _loading = true;
    });

    _userDeviceList.clear();
    //_osales.clear();

    _authMethods.attendanceList(widget.empId).then((response) {
      setState(() {
        _loading = false;
      });

      print('gotdateresponse:::');
      print(response);

      setState(() {
        if (response['success'] == "1") {
          for (var user in response['data']['data']) {
           /* _osales.add(GraphModel(
              user['new_date'],
              user['temperature'],
            )); //user['cards']*/

            _userDeviceList.add(UserDevice(
              user['deviceId'],
              user['temperature'],
              user['new_date'],
              user['time'],
              user['devicename'],
              user['timetype'],
              user['Name'],
            )); //user['cards']

          }
        } else if (response['success'] == "0") {
          //  FToast.show("No data to load");

          Navigator.pop(context);

          showDialog(
            context: context,
            builder: (_) => AttendanceDialog(msg1: "No data found!"),
          );
        } else {
          FToast.show("API error");
        }
      });
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

      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _userDeviceList.length,
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
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        _userDeviceList[index].deviceName +
                                            " [ " +
                                            "SKIT" +
                                            _userDeviceList[index]
                                                .deviceId +
                                            " ]",
                                        style: utils.textStyle(
                                            context,
                                            titleFontSize,
                                            Colors.black,
                                            FontWeight.bold,
                                            0.0),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        "  " +
                                            _userDeviceList[index].timetype,
                                        style: utils.textStyle(
                                            context,
                                            40,
                                            Colors.deepOrange,
                                            FontWeight.bold,
                                            0.0),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _userDeviceList[index].temperature +
                                          "  C",
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      _userDeviceList[index].date,
                                      style: utils.textStyle(
                                          context,
                                          subTitleFont,
                                          Colors.black,
                                          FontWeight.normal,
                                          0.0),
                                    ),
                                    Text(
                                      _userDeviceList[index].time,
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
                          ),
                        ],
                      ),
                    ),
                  )),
            );
          }),
    );
  }

  checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
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

}
