/*
 * Created by Arti Karande in the year of 2020.
 * Copyright (c) 2020 Arti Karande. All rights reserved.
 */

import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:itts/login/auth_methods.dart';
import 'package:itts/login/verifyOtp.dart';
import 'package:itts/screens/DashboardGrid.dart';
import 'package:itts/screens/fail_dialog.dart';
import 'package:itts/utils/FToast.dart';
import 'package:itts/utils/StyleColor.dart';
import 'package:itts/utils/toast_snack.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attendance_dialog.dart';

class Attendance extends StatefulWidget {
  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> with TickerProviderStateMixin {
  TextEditingController ssidController = TextEditingController();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  int newIcon = 0;
  TextEditingController passwordController = TextEditingController();
  String desc, title;
  String result = "Hey there !";
  AuthMethods _authMethods = AuthMethods();
  bool _loading = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SharedPreferences _preferences;
  String userId = '', formatted;
  var formatter_date, time;
  String formatQR = "";

  String status;
  FToast utils = new FToast();

  int _counter = 0;
  AnimationController _controller;
  int levelClock = 10;
  bool dontVisible = false;
  bool retryVisible = false;

  String attendanceType = "";

  @override
  void initState() {
    preferencesUserId();

    var now = new DateTime.now();
    formatter_date = new DateFormat('yyyy-MM-dd');
    formatted = formatter_date.format(now);
    print(formatted + "dateprint");

    print("-----");
    time = new DateFormat("H:m:s").format(now);
    print(new DateFormat("H:m:s").format(now));

    super.initState();
  }

  @override
  void dispose() {
    ssidController?.dispose();
    passwordController?.dispose();

    print("in dispose::");
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
            key: _scaffoldKey,
            //    resizeToAvoidBottomPadding:false,
            appBar: AppBar(
              title: Text('Attendance : ' + formatQR),
            ),
            body: Form(
              key: _formKey,
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[

                      Container(
                          height: 45,
                          width: w,
                          color: Colors.red[50],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Text('Please find the QR code located on device and scan it.'),

                              Text(
                                  'Select appropriate option [ IN / OUT ]'),
                            ],
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              /*FToast.showCenter(
                                  "Scan ITTS device located on Device");*/
                              _scanQR('In');
                            },
                            child: AvatarGlow(
                              startDelay: Duration(milliseconds: 500),
                              glowColor: AppTheme.bottle,
                              endRadius: 70.0,
                              duration: Duration(milliseconds: 2000),
                              repeat: true,
                              showTwoGlows: true,
                              repeatPauseDuration: Duration(milliseconds: 100),
                              child: Material(
                                elevation: 8.0,
                                shape: CircleBorder(),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 4.7,
                                  height:
                                      MediaQuery.of(context).size.width / 4.7,
                                  //     color: AppTheme.SUB_TITLE_COLOR,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red[50],
                                  ),

                                  child: Center(
                                      child: Text(
                                    "IN",
                                    style: utils.textStyle(context, 30,
                                        Colors.black, FontWeight.bold, 0.0),
                                  )),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                             /* FToast.showCenter(
                                  "Scan ITTS device located on Device");*/
                              _scanQR('Out');
                            },
                            child: AvatarGlow(
                              startDelay: Duration(milliseconds: 500),
                              glowColor: AppTheme.bottle,
                              endRadius: 70.0,
                              duration: Duration(milliseconds: 2000),
                              repeat: true,
                              showTwoGlows: true,
                              repeatPauseDuration: Duration(milliseconds: 100),
                              child: Material(
                                elevation: 8.0,
                                shape: CircleBorder(),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 4.7,
                                  height:
                                      MediaQuery.of(context).size.width / 4.7,
                                  //     color: AppTheme.SUB_TITLE_COLOR,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red[50],
                                  ),

                                  child: Center(
                                      child: Text(
                                    "OUT",
                                    style: utils.textStyle(context, 30,
                                        Colors.black, FontWeight.bold, 0.0),
                                  )),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //     Text(ssidController.text),
                      SizedBox(
                        height: h / 10,
                      ),

                      Visibility(
                        visible: dontVisible, //dontVisible
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Scan temperature within ",
                              style: utils.textStyle(context, 30, Colors.black,
                                  FontWeight.bold, 0.0),
                            ),
                            Countdown(
                              animation: StepTween(
                                begin: levelClock,
                                // THIS IS A USER ENTERED NUMBER
                                end: 0,
                              ).animate(_controller),
                            ),
                          ],
                        ),
                      ),

                      Visibility(
                          visible: retryVisible,
                          child:
                          Text(
                            "Timeup, please try again",
                            style: utils.textStyle(
                                context, 35, Colors.black, FontWeight.normal, 0.0),
                          )

                         // failDialog(),
                      ),


                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }

  addUser(String attendanceType) async {
    setState(() {
      _loading = true;
    });

    _authMethods
        .addAttendance(ssidController.text, passwordController.text, formatted,
            time, attendanceType)
        .then((response) {
      setState(() {
        _loading = false;
      });

      print('gotattendanceesponse:::');
      print(response);

      if (response['success'] == "1") {
        _controller = AnimationController(
            vsync: this, duration: Duration(seconds: levelClock));
        _controller.forward();

        ShowCustomSnack.getCustomSnack(
            context, _scaffoldKey, "Device Scan successfully!");

        Future.delayed(Duration(seconds: 10), () {
          setState(() {
            retryVisible = true;
            dontVisible = false;
          });
        });

        setState(() {
          dontVisible = true;
        });

        /* showDialog(
          context: context,
          builder: (_) => AttendanceDialog(msg1: "Device Scan successfully!",),
        );*/

      } else if (response['success'] == "0") {
        dontVisible = false;

        showDialog(
          context: context,
          builder: (_) => FailDialog(
              msg1: "You are not added by admin / please contact Admin!",
              msg2: "Scanning failed"),
        );
      } else {
        FToast.show("API error");
      }
    });
  }

  Future _scanQR(String attendanceType) async {

    try {
      String qrResult = await BarcodeScanner.scan();

      setState(() {
        retryVisible =false;   //retry option disable
        result = qrResult;
        print("result:::$result");
      });
      //   FToast.showCenter(result);
      ssidController.text = result;
      if (result.startsWith('D?') && result.endsWith('?D')) {
        final List<String> _qrSP = result.split('?');
        if (_qrSP.length > 3) {
          result = _qrSP[1] +
              '-' +
              _qrSP[1] +
              '-Today-' +
              _qrSP[2] +
              '-' +
              result +
              '-' +
              _qrSP[1];

          ssidController.text = 'KI-' + _qrSP[1].substring(4);
          passwordController.text = _qrSP[2];

          print("---------");
          print(_qrSP[1].substring(4));
          print('QRS: $result');

          setState(() {
            formatQR='KI-'+_qrSP[1].substring(4);
          });

          final List<String> qrStringParts = result.split('-');
          print('111: $qrStringParts');

          checkInternet(attendanceType);

        }
      } else {
        FToast.showCenter("QR code does not match with our pattern");
      }
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }

  void preferencesUserId() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      userId = _preferences.getString("user_id");

      print('Adddevice:gotUserId:::$userId');
    });
  }

  checkInternet(String attendanceType) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        status = "ConnectivityResult.mobile";
        status = "ConnectivityResult.wifi";
      }

      addUser(attendanceType);
    } on SocketException catch (_) {
      print('not connected');

      FToast.show("You are not connected to internet");
      status = "ConnectivityResult.none";

      setState(() {
        _loading = false;
      });
    }
  }

  failDialog() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Fail'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => exit(0),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }
}
